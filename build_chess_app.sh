#!/bin/bash
set -e

# Очистка старых версий
rm -rf chess-app chess-app.zip
mkdir -p chess-app

# ---------- backend ----------
mkdir -p chess-app/backend/app/api chess-app/backend/app/ws chess-app/backend/app/game_engine

# backend/Dockerfile
cat > chess-app/backend/Dockerfile <<'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
EOF

# backend/requirements.txt
cat > chess-app/backend/requirements.txt <<'EOF'
fastapi
uvicorn[standard]
python-dotenv
asyncpg
databases[postgresql]
SQLAlchemy
alembic
pydantic
redis
aioredis
psycopg2-binary
python-jose
passlib[bcrypt]
EOF

# backend/app/main.py
cat > chess-app/backend/app/main.py <<'EOF'
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, matches, history
from app.ws.match import match_ws

app = FastAPI(title="Chess App")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth")
app.include_router(matches.router, prefix="/matches")
app.include_router(history.router, prefix="/history")

@app.websocket("/match/{match_id}")
async def websocket_endpoint(websocket: WebSocket, match_id: str):
    await match_ws(websocket, match_id)
EOF

# backend/app/api/auth.py
cat > chess-app/backend/app/api/auth.py <<'EOF'
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import uuid

router = APIRouter()

class UserIn(BaseModel):
    username: str
    password: str

@router.post("/register")
async def register(payload: UserIn):
    user_id = str(uuid.uuid4())
    return {"id": user_id, "username": payload.username}

@router.post("/login")
async def login(payload: UserIn):
    if payload.username:
        return {"access_token": "fake-jwt-token", "token_type": "bearer"}
    raise HTTPException(status_code=400, detail="Bad credentials")
EOF

# backend/app/api/matches.py
cat > chess-app/backend/app/api/matches.py <<'EOF'
from fastapi import APIRouter
from pydantic import BaseModel
import uuid

router = APIRouter()

class CreateMatch(BaseModel):
    name: str | None = None

LOBBY = {}

@router.post("/")
async def create_match(payload: CreateMatch):
    match_id = str(uuid.uuid4())
    LOBBY[match_id] = {"id": match_id, "name": payload.name or "Match", "players": []}
    return LOBBY[match_id]

@router.get("/")
async def list_matches():
    return list(LOBBY.values())

@router.post("/{match_id}/join")
async def join_match(match_id: str, username: str):
    match = LOBBY.get(match_id)
    if not match:
        return {"error": "not found"}
    match["players"].append(username)
    return match
EOF

# backend/app/api/history.py
cat > chess-app/backend/app/api/history.py <<'EOF'
from fastapi import APIRouter
router = APIRouter()

@router.get("/")
async def get_history():
    return []
EOF

# backend/app/ws/match.py
cat > chess-app/backend/app/ws/match.py <<'EOF'
from fastapi import WebSocket
from app.game_engine.engine import Game

GAMES: dict[str, Game] = {}

async def match_ws(websocket: WebSocket, match_id: str):
    await websocket.accept()
    if match_id not in GAMES:
        GAMES[match_id] = Game()
    game = GAMES[match_id]

    try:
        while True:
            msg = await websocket.receive_json()
            if msg.get("type") == "move":
                frm = msg.get("from")
                to = msg.get("to")
                valid, reason = game.is_valid_move(frm, to)
                if valid:
                    game.make_move(frm, to)
                    await websocket.send_json({"type": "update", "state": game.get_state()})
                else:
                    await websocket.send_json({"type": "error", "message": reason})
            elif msg.get("type") == "ping":
                await websocket.send_json({"type": "pong"})
    except Exception:
        pass
EOF

# backend/app/game_engine/engine.py
cat > chess-app/backend/app/game_engine/engine.py <<'EOF'
from dataclasses import dataclass, field
from typing import List, Any

START_BOARD = [
    ["r","n","b","q","k","b","n","r"],
    ["p"]*8,
    ["."]*8,
    ["."]*8,
    ["."]*8,
    ["."]*8,
    ["P"]*8,
    ["R","N","B","Q","K","B","N","R"],
]

@dataclass
class Game:
    board: List[List[str]] = field(default_factory=lambda: [row.copy() for row in START_BOARD])
    turn: str = "white"
    history: List[str] = field(default_factory=list)

    def coord_to_idx(self, coord: str):
        if not coord or len(coord) < 2:
            return None
        file = ord(coord[0]) - ord('a')
        rank = 8 - int(coord[1])
        return rank, file

    def is_valid_move(self, frm: str, to: str):
        f = self.coord_to_idx(frm)
        t = self.coord_to_idx(to)
        if f is None or t is None:
            return False, "bad coords"
        fr_piece = self.board[f[0]][f[1]]
        if fr_piece == ".":
            return False, "no piece"
        return True, "ok"

    def make_move(self, frm: str, to: str):
        f = self.coord_to_idx(frm)
        t = self.coord_to_idx(to)
        piece = self.board[f[0]][f[1]]
        self.board[t[0]][t[1]] = piece
        self.board[f[0]][f[1]] = "."
        self.history.append(f"{frm}{to}")
        self.turn = "black" if self.turn == "white" else "white"

    def get_state(self) -> Any:
        return {
            "board": self.board,
            "turn": self.turn,
            "history": self.history,
        }
EOF

# ---------- frontend ----------
mkdir -p chess-app/frontend/pages chess-app/frontend/components chess-app/frontend/styles

cat > chess-app/frontend/package.json <<'EOF'
{
  "name": "chess-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000"
  },
  "dependencies": {
    "next": "13.4.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  }
}
EOF

cat > chess-app/frontend/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": false,
    "forceConsistentCasingInFileNames": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve"
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

cat > chess-app/frontend/pages/_app.tsx <<'EOF'
import '../styles/globals.css'
import type { AppProps } from 'next/app'

export default function App({ Component, pageProps } : AppProps) {
  return <Component {...pageProps} />
}
EOF

cat > chess-app/frontend/pages/index.tsx <<'EOF'
import { useState } from 'react'
import Board from '../components/Board'

export default function Home() {
  const [matchId, setMatchId] = useState('local-1')
  return (
    <div style={{padding:20}}>
      <h1>Chess — demo</h1>
      <Board matchId={matchId} />
    </div>
  )
}
EOF

cat > chess-app/frontend/components/Board.tsx <<'EOF'
import { useEffect, useState } from 'react'

export default function Board({ matchId } : { matchId: string }) {
  const [socket, setSocket] = useState<WebSocket | null>(null)
  const [state, setState] = useState<any>(null)

  useEffect(() => {
    const ws = new WebSocket(`ws://${location.hostname}:8000/match/${matchId}`)
    ws.onmessage = (e) => {
      const msg = JSON.parse(e.data)
      if (msg.type === 'update') setState(msg.state)
    }
    setSocket(ws)
    return () => ws.close()
  }, [matchId])

  function sendMove(from: string, to: string) {
    socket?.send(JSON.stringify({ type: 'move', from, to }))
  }

  return (
    <div>
      <div style={{display:'grid', gridTemplateColumns:'repeat(8,40px)'}}>
        {state?.board?.flatMap((row: any[]) => row.map((cell: string) => (
          <div key={Math.random()} style={{width:40,height:40,border:'1px solid #999',display:'flex',alignItems:'center',justifyContent:'center'}}>
            {cell === '.' ? '' : cell}
          </div>
        ))) }
      </div>
      <div style={{marginTop:10}}>
        <button onClick={() => sendMove('e2','e4')}>send e2e4</button>
      </div>
    </div>
  )
}
EOF

# ---------- docker-compose ----------
cat > chess-app/docker-compose.yml <<'EOF'
version: "3.8"
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
    environment:
      DATABASE_URL: postgresql://chess:chess@db:5432/chess
      REDIS_URL: redis://redis:6379/0
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: chess
      POSTGRES_USER: chess
      POSTGRES_PASSWORD: chess
    volumes:
      - db-data:/var/lib/postgresql/data
  redis:
    image: redis:7
    volumes:
      - redis-data:/data

volumes:
  db-data:
  redis-data:
EOF

# ---------- README ----------
cat > chess-app/README.md <<'EOF'
# Chess App — How to run

## Запуск
```bash
docker-compose up --build
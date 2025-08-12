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

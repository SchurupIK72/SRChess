import uvicorn
from fastapi import FastAPI
from api import lobby
from ws import game as ws_game

app = FastAPI()
app.include_router(lobby.router, prefix="/api/lobby")
app.include_router(ws_game.router, prefix="/ws/game")

if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)

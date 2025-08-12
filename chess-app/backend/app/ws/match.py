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

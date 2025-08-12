from fastapi import APIRouter, WebSocket
from models.game import Match
from services.redis import get_match

router = APIRouter()

@router.websocket("/{match_id}")
async def websocket_endpoint(websocket: WebSocket, match_id: str):
    await websocket.accept()
    match = await get_match(match_id)
    if not match:
        await websocket.send_json({"error": "not found"})
        await websocket.close()
        return
    await websocket.send_json({"status": "connected", "match": match.dict()})
    while True:
        data = await websocket.receive_json()
        # TODO: обработка ходов и обновление состояния
        await websocket.send_json({"echo": data})

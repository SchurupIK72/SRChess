from fastapi import APIRouter
from models.game import Match, MatchStatus
from services.redis import save_match, get_match
import uuid

router = APIRouter()

@router.post("/create")
async def create_match():
    match_id = str(uuid.uuid4())
    match = Match(id=match_id, players=[], status=MatchStatus.waiting)
    await save_match(match)
    return {"id": match_id}

@router.get("/{match_id}")
async def get_match_info(match_id: str):
    match = await get_match(match_id)
    if match:
        return match.dict()
    return {"error": "not found"}

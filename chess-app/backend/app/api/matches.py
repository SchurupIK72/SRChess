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

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

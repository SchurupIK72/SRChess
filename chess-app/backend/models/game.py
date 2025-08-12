from pydantic import BaseModel
from enum import Enum
from typing import List

class MatchStatus(str, Enum):
    waiting = "waiting"
    active = "active"
    finished = "finished"

class Match(BaseModel):
    id: str
    players: List[str]
    status: MatchStatus

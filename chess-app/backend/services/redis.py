import redis.asyncio as redis
from models.game import Match

_redis = None

async def get_redis():
    global _redis
    if _redis is None:
        _redis = await redis.from_url("redis://localhost")
    return _redis

async def save_match(match: Match):
    r = await get_redis()
    await r.set(f"match:{match.id}", match.json())

async def get_match(match_id: str):
    r = await get_redis()
    data = await r.get(f"match:{match_id}")
    if data:
        return Match.parse_raw(data)
    return None

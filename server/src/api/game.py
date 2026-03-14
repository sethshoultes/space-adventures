"""Game API — REST endpoints for game actions."""

from __future__ import annotations

from pydantic import BaseModel, Field
from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse

from ..state.database import GameDatabase
from ..game_master.agent import GameMasterAgent

router = APIRouter()

# These get set during app startup (see main.py)
db: GameDatabase | None = None
agent: GameMasterAgent | None = None


def _db() -> GameDatabase:
    assert db is not None, "Database not initialized"
    return db


def _agent() -> GameMasterAgent:
    assert agent is not None, "Agent not initialized"
    return agent


# ---------------------------------------------------------------------------
# Request/Response models
# ---------------------------------------------------------------------------

class NewGameRequest(BaseModel):
    player_name: str = "Player"


class NewGameResponse(BaseModel):
    session_id: str
    message: str


class PlayerMessageRequest(BaseModel):
    message: str


class GameStateResponse(BaseModel):
    session_id: str
    player: dict
    ship: dict
    world: dict
    turn_count: int


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/new", response_model=NewGameResponse)
async def new_game(request: NewGameRequest):
    """Start a new game session. Returns session ID and opening narrative."""
    session = await _db().new_game(request.player_name)

    # Get opening narrative from the Game Master
    gm_response = await _agent().process_turn(
        session,
        f"A new player named {request.player_name} has started the game. "
        "Introduce them to the world and their situation. This is the beginning of their adventure.",
    )
    _agent().save_to_history(session, "[GAME START]", gm_response)
    await _db().save_game(session)

    return NewGameResponse(session_id=session.session_id, message=gm_response)


@router.get("/state/{session_id}")
async def get_state(session_id: str):
    """Get current game state for a session."""
    session = await _db().load_game(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    return {
        "session_id": session.session_id,
        "player": session.player.model_dump(),
        "ship": {
            "name": session.ship.name,
            "classification": session.ship.classification,
            "hull_hp": session.ship.hull_hp,
            "max_hull_hp": session.ship.max_hull_hp,
            "power_available": session.ship.power_available,
            "power_total": session.ship.power_total,
            "systems": {
                name: sys.model_dump() for name, sys in session.ship.systems.items()
            },
            "inventory": [item.model_dump() for item in session.ship.inventory],
        },
        "world": session.world.model_dump(),
        "turn_count": session.turn_count,
    }


@router.post("/message/{session_id}")
async def player_message(session_id: str, request: PlayerMessageRequest):
    """Send a player message to the Game Master and get a response."""
    session = await _db().load_game(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    gm_response = await _agent().process_turn(session, request.message)
    _agent().save_to_history(session, request.message, gm_response)
    await _db().save_game(session)

    return {
        "session_id": session_id,
        "response": gm_response,
        "turn": session.turn_count,
    }


@router.post("/message/{session_id}/stream")
async def player_message_stream(session_id: str, request: PlayerMessageRequest):
    """Send a player message and get a streaming response."""
    session = await _db().load_game(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    async def generate():
        full_response = []
        async for chunk in _agent().process_turn_streaming(session, request.message):
            full_response.append(chunk)
            yield chunk
        # Save after streaming completes
        response_text = "".join(full_response)
        _agent().save_to_history(session, request.message, response_text)
        await _db().save_game(session)

    return StreamingResponse(generate(), media_type="text/plain")


@router.post("/save/{session_id}")
async def save_game(session_id: str):
    """Explicitly save current game state."""
    session = await _db().load_game(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    await _db().save_game(session)
    return {"status": "saved", "session_id": session_id}


@router.get("/saves")
async def list_saves():
    """List all saved games."""
    saves = await _db().list_saves()
    return {"saves": saves}


@router.post("/load/{session_id}")
async def load_game(session_id: str):
    """Load a saved game and return its state."""
    session = await _db().load_game(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return {
        "session_id": session.session_id,
        "player_name": session.player.name,
        "player_level": session.player.level,
        "turn_count": session.turn_count,
        "phase": session.world.phase,
    }


@router.delete("/save/{session_id}")
async def delete_save(session_id: str):
    """Delete a saved game."""
    deleted = await _db().delete_save(session_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Save not found")
    return {"status": "deleted", "session_id": session_id}

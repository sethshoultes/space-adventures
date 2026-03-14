"""Game API - REST endpoints for game actions."""

from fastapi import APIRouter

router = APIRouter()


@router.post("/new")
async def new_game():
    """Start a new game session."""
    # TODO: Create player, initialize game state, return session ID
    return {"status": "not_implemented"}


@router.get("/state/{session_id}")
async def get_state(session_id: str):
    """Get current game state for a session."""
    # TODO: Load game state from database
    return {"status": "not_implemented"}


@router.post("/action/{session_id}")
async def player_action(session_id: str):
    """Process a player action through the Game Master agent."""
    # TODO: Forward action to Game Master, return narrative + state updates
    return {"status": "not_implemented"}


@router.post("/save/{session_id}")
async def save_game(session_id: str):
    """Save current game state."""
    # TODO: Persist to database
    return {"status": "not_implemented"}


@router.get("/load/{player_id}")
async def load_games(player_id: str):
    """List saved games for a player."""
    # TODO: Query database for saves
    return {"status": "not_implemented"}

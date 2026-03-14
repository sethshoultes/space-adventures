"""WebSocket API - Real-time game communication."""

from fastapi import APIRouter, WebSocket

router = APIRouter()


@router.websocket("/{session_id}")
async def game_ws(websocket: WebSocket, session_id: str):
    """WebSocket connection for real-time game interaction.

    Streams Game Master responses and game state updates to the client.
    """
    await websocket.accept()
    # TODO: Implement WebSocket game loop
    # - Receive player actions
    # - Stream Game Master responses (token by token)
    # - Push game state updates
    # - Handle disconnection/reconnection
    await websocket.close()

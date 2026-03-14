"""WebSocket API — Real-time streaming game communication.

Protocol (aligned with web/src/api/client.ts):
    Client sends: {"type": "message", "content": "player text"}
    Client sends: {"type": "ping"}
    Server sends: {"type": "stream_start", "payload": {}}
    Server sends: {"type": "stream_chunk", "payload": {"chunk": "text"}}
    Server sends: {"type": "stream_end", "payload": {}}
    Server sends: {"type": "state_update", "payload": {...}}
    Server sends: {"type": "narrative", "payload": {"content": "...", "sender": "GM"}}
    Server sends: {"type": "error", "payload": {"content": "msg"}}
    Server sends: {"type": "pong", "payload": {}}
"""

from __future__ import annotations

import json
import logging

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from ..state.database import GameDatabase
from ..game_master.agent import GameMasterAgent

logger = logging.getLogger(__name__)

router = APIRouter()

# Set during app startup (see main.py)
db: GameDatabase | None = None
agent: GameMasterAgent | None = None


def _db() -> GameDatabase:
    assert db is not None
    return db


def _agent() -> GameMasterAgent:
    assert agent is not None
    return agent


def _msg(msg_type: str, payload: dict | None = None) -> dict:
    """Build a WebSocket message in the frontend-expected format."""
    return {"type": msg_type, "payload": payload or {}}


@router.websocket("/{session_id}")
async def game_ws(websocket: WebSocket, session_id: str):
    """WebSocket connection for real-time game interaction."""
    await websocket.accept()

    # Validate session exists
    session = await _db().load_game(session_id)
    if not session:
        await websocket.send_json(_msg("error", {"content": "Session not found"}))
        await websocket.close(code=4004)
        return

    # Send initial state update
    await websocket.send_json(_msg("state_update", {
        "player_name": session.player.name,
        "player_level": session.player.level,
        "credits": session.player.credits,
        "turn": session.turn_count,
        "phase": session.world.phase,
        "active_mission": session.world.active_mission_id,
    }))

    try:
        while True:
            raw = await websocket.receive_text()
            try:
                data = json.loads(raw)
            except json.JSONDecodeError:
                data = {"type": "message", "content": raw}

            msg_type = data.get("type", "message")

            if msg_type == "ping":
                await websocket.send_json(_msg("pong"))
                continue

            # Extract content from either format
            content = data.get("content", "")
            if not content and "payload" in data:
                content = data["payload"].get("action", "") or data["payload"].get("content", "")
            if not content.strip():
                await websocket.send_json(_msg("error", {
                    "content": "Send {\"type\": \"message\", \"content\": \"your text\"}",
                }))
                continue

            # Reload session (may have been saved by REST endpoint)
            session = await _db().load_game(session_id)
            if not session:
                await websocket.send_json(_msg("error", {"content": "Session lost"}))
                break

            # Signal stream start
            await websocket.send_json(_msg("stream_start"))

            # Stream Game Master response
            full_response: list[str] = []
            try:
                async for chunk in _agent().process_turn_streaming(session, content):
                    full_response.append(chunk)
                    await websocket.send_json(_msg("stream_chunk", {"chunk": chunk}))
            except Exception as e:
                logger.exception("Agent error in WS session %s", session_id)
                await websocket.send_json(_msg("error", {
                    "content": f"Game Master error: {e}",
                }))
                continue

            # Signal stream end
            await websocket.send_json(_msg("stream_end"))

            # Save turn
            response_text = "".join(full_response)
            _agent().save_to_history(session, content, response_text)
            await _db().save_game(session)

            # Send state update
            await websocket.send_json(_msg("state_update", {
                "player_name": session.player.name,
                "player_level": session.player.level,
                "credits": session.player.credits,
                "xp": session.player.xp,
                "turn": session.turn_count,
                "phase": session.world.phase,
                "active_mission": session.world.active_mission_id,
            }))

    except WebSocketDisconnect:
        logger.info("WebSocket disconnected: session %s", session_id)
    except Exception:
        logger.exception("WebSocket error: session %s", session_id)
        try:
            await websocket.close(code=1011)
        except Exception:
            pass

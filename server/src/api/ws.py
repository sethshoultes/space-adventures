"""WebSocket API — Real-time streaming game communication."""

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


@router.websocket("/{session_id}")
async def game_ws(websocket: WebSocket, session_id: str):
    """WebSocket connection for real-time game interaction.

    Protocol:
        Client sends: {"type": "message", "content": "player text"}
        Server sends: {"type": "token", "content": "chunk"}  (streaming)
        Server sends: {"type": "done", "turn": N}  (end of response)
        Server sends: {"type": "error", "content": "msg"}  (on error)
        Server sends: {"type": "state_update", "data": {...}}  (after turn)
    """
    await websocket.accept()

    # Validate session exists
    session = await _db().load_game(session_id)
    if not session:
        await websocket.send_json({"type": "error", "content": "Session not found"})
        await websocket.close(code=4004)
        return

    # Send initial state
    await websocket.send_json({
        "type": "state_update",
        "data": {
            "player_name": session.player.name,
            "player_level": session.player.level,
            "credits": session.player.credits,
            "turn": session.turn_count,
            "phase": session.world.phase,
            "active_mission": session.world.active_mission_id,
        },
    })

    try:
        while True:
            # Receive player message
            raw = await websocket.receive_text()
            try:
                data = json.loads(raw)
            except json.JSONDecodeError:
                data = {"type": "message", "content": raw}

            msg_type = data.get("type", "message")
            content = data.get("content", "")

            if msg_type == "ping":
                await websocket.send_json({"type": "pong"})
                continue

            if msg_type != "message" or not content.strip():
                await websocket.send_json({"type": "error", "content": "Send {type: 'message', content: '...'}"})
                continue

            # Reload session (may have been saved by REST endpoint)
            session = await _db().load_game(session_id)
            if not session:
                await websocket.send_json({"type": "error", "content": "Session lost"})
                break

            # Stream Game Master response
            full_response: list[str] = []
            try:
                async for chunk in _agent().process_turn_streaming(session, content):
                    full_response.append(chunk)
                    await websocket.send_json({"type": "token", "content": chunk})
            except Exception as e:
                logger.exception("Agent error in WS session %s", session_id)
                await websocket.send_json({"type": "error", "content": f"Game Master error: {e}"})
                continue

            # Save turn
            response_text = "".join(full_response)
            _agent().save_to_history(session, content, response_text)
            await _db().save_game(session)

            # Send completion + state update
            await websocket.send_json({"type": "done", "turn": session.turn_count})
            await websocket.send_json({
                "type": "state_update",
                "data": {
                    "player_name": session.player.name,
                    "player_level": session.player.level,
                    "credits": session.player.credits,
                    "xp": session.player.xp,
                    "turn": session.turn_count,
                    "phase": session.world.phase,
                    "active_mission": session.world.active_mission_id,
                },
            })

    except WebSocketDisconnect:
        logger.info("WebSocket disconnected: session %s", session_id)
    except Exception:
        logger.exception("WebSocket error: session %s", session_id)
        try:
            await websocket.close(code=1011)
        except Exception:
            pass

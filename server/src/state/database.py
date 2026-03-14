"""Database — Async SQLite for game state persistence.

Uses aiosqlite to store game sessions as JSON blobs with metadata
for fast listing and lookup.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import aiosqlite

from .models import GameSession, create_new_game

# ---------------------------------------------------------------------------
# Schema
# ---------------------------------------------------------------------------

_SCHEMA = """
CREATE TABLE IF NOT EXISTS game_saves (
    session_id   TEXT PRIMARY KEY,
    player_name  TEXT NOT NULL,
    player_level INTEGER NOT NULL DEFAULT 1,
    phase        INTEGER NOT NULL DEFAULT 1,
    turn_count   INTEGER NOT NULL DEFAULT 0,
    state_json   TEXT NOT NULL,
    created_at   TEXT NOT NULL,
    updated_at   TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_saves_updated
    ON game_saves(updated_at DESC);
"""


class GameDatabase:
    """Async SQLite wrapper for game persistence."""

    def __init__(self, db_path: str | Path = "space_adventures.db"):
        self.db_path = str(db_path)
        self._db: aiosqlite.Connection | None = None

    async def connect(self) -> None:
        self._db = await aiosqlite.connect(self.db_path)
        self._db.row_factory = aiosqlite.Row
        await self._db.executescript(_SCHEMA)
        await self._db.commit()

    async def close(self) -> None:
        if self._db:
            await self._db.close()
            self._db = None

    # ------------------------------------------------------------------
    # CRUD
    # ------------------------------------------------------------------

    async def new_game(self, player_name: str = "Player") -> GameSession:
        """Create and persist a brand-new game session."""
        session = create_new_game(player_name)
        await self.save_game(session)
        return session

    async def save_game(self, session: GameSession) -> None:
        """Upsert a game session."""
        session.touch()
        state_json = session.model_dump_json()
        assert self._db is not None
        await self._db.execute(
            """
            INSERT INTO game_saves
                (session_id, player_name, player_level, phase, turn_count,
                 state_json, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(session_id) DO UPDATE SET
                player_name  = excluded.player_name,
                player_level = excluded.player_level,
                phase        = excluded.phase,
                turn_count   = excluded.turn_count,
                state_json   = excluded.state_json,
                updated_at   = excluded.updated_at
            """,
            (
                session.session_id,
                session.player.name,
                session.player.level,
                session.world.phase,
                session.turn_count,
                state_json,
                session.created_at,
                session.updated_at,
            ),
        )
        await self._db.commit()

    async def load_game(self, session_id: str) -> GameSession | None:
        """Load a game session by ID."""
        assert self._db is not None
        cursor = await self._db.execute(
            "SELECT state_json FROM game_saves WHERE session_id = ?",
            (session_id,),
        )
        row = await cursor.fetchone()
        if not row:
            return None
        return GameSession.model_validate_json(row["state_json"])

    async def list_saves(self, limit: int = 20) -> list[dict]:
        """Return save metadata (not full state) for listing UI."""
        assert self._db is not None
        cursor = await self._db.execute(
            """
            SELECT session_id, player_name, player_level, phase,
                   turn_count, created_at, updated_at
            FROM game_saves
            ORDER BY updated_at DESC
            LIMIT ?
            """,
            (limit,),
        )
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]

    async def delete_save(self, session_id: str) -> bool:
        """Delete a save. Returns True if it existed."""
        assert self._db is not None
        cursor = await self._db.execute(
            "DELETE FROM game_saves WHERE session_id = ?",
            (session_id,),
        )
        await self._db.commit()
        return cursor.rowcount > 0

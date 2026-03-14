"""Memory Manager — Markdown-based player memory system.

Stores player memories as markdown files that get fed into the Game Master's
context each turn, giving it long-term memory across sessions.

Inspired by OpenClaw's approach: simple markdown files, keyword searchable,
structured by category.
"""

from __future__ import annotations

import re
from datetime import date, datetime, timezone
from pathlib import Path


class MemoryManager:
    """Read/write markdown memory files for a game session."""

    def __init__(self, memory_dir: str | Path = "./memory"):
        self.root = Path(memory_dir)
        self._ensure_structure()

    def _ensure_structure(self) -> None:
        """Create directory structure if missing."""
        (self.root / "daily").mkdir(parents=True, exist_ok=True)
        for fname in ("player_profile.md", "relationships.md", "decisions.md", "world_state.md"):
            fpath = self.root / fname
            if not fpath.exists():
                fpath.write_text(f"# {fname.replace('.md', '').replace('_', ' ').title()}\n\n")

    # ------------------------------------------------------------------
    # Daily session log
    # ------------------------------------------------------------------

    def write_daily_log(self, entry: str, session_id: str = "") -> str:
        """Append an entry to today's daily log. Returns the log path."""
        today = date.today().isoformat()
        log_path = self.root / "daily" / f"{today}.md"
        if not log_path.exists():
            log_path.write_text(f"# Session Log — {today}\n\n")
        timestamp = datetime.now(timezone.utc).strftime("%H:%M UTC")
        prefix = f"[{session_id[:8]}] " if session_id else ""
        with open(log_path, "a") as f:
            f.write(f"- **{timestamp}** {prefix}{entry}\n")
        return str(log_path)

    # ------------------------------------------------------------------
    # Player profile
    # ------------------------------------------------------------------

    def read_player_profile(self) -> str:
        return (self.root / "player_profile.md").read_text()

    def write_player_profile(self, section: str, content: str) -> str:
        """Update a section in player_profile.md (or append if new)."""
        path = self.root / "player_profile.md"
        text = path.read_text()
        # Try to replace existing section
        pattern = rf"(## {re.escape(section)}\n)(.*?)(?=\n## |\Z)"
        match = re.search(pattern, text, re.DOTALL)
        if match:
            text = text[: match.start(2)] + content + "\n" + text[match.end(2) :]
        else:
            text += f"\n## {section}\n{content}\n"
        path.write_text(text)
        return f"Updated player_profile.md section: {section}"

    # ------------------------------------------------------------------
    # Relationships
    # ------------------------------------------------------------------

    def read_relationships(self) -> str:
        return (self.root / "relationships.md").read_text()

    def write_relationship(self, npc: str, update: str) -> str:
        """Update or add an NPC relationship entry."""
        path = self.root / "relationships.md"
        text = path.read_text()
        # Look for existing NPC entry
        pattern = rf"(### {re.escape(npc)}\n)(.*?)(?=\n### |\n## |\Z)"
        match = re.search(pattern, text, re.DOTALL)
        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        if match:
            existing = match.group(2).rstrip()
            new_entry = f"{existing}\n- [{timestamp}] {update}\n"
            text = text[: match.start(2)] + new_entry + text[match.end(2) :]
        else:
            # Find the NPCs section or append
            npc_section = f"\n### {npc}\n- [{timestamp}] {update}\n"
            if "## NPCs" in text:
                text = text.replace("## NPCs\n", f"## NPCs\n{npc_section}", 1)
            else:
                text += f"\n## NPCs\n{npc_section}"
        path.write_text(text)
        return f"Updated relationship: {npc}"

    # ------------------------------------------------------------------
    # Decisions
    # ------------------------------------------------------------------

    def read_decisions(self) -> str:
        return (self.root / "decisions.md").read_text()

    def write_decision(self, choice: str, context: str, consequence: str) -> str:
        """Append a major decision to the log."""
        path = self.root / "decisions.md"
        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
        entry = (
            f"\n### {choice}\n"
            f"- **When:** {timestamp}\n"
            f"- **Context:** {context}\n"
            f"- **Consequence:** {consequence}\n"
        )
        with open(path, "a") as f:
            f.write(entry)
        return f"Recorded decision: {choice}"

    # ------------------------------------------------------------------
    # World state
    # ------------------------------------------------------------------

    def read_world_state(self) -> str:
        return (self.root / "world_state.md").read_text()

    def write_world_state(self, section: str, content: str) -> str:
        """Update a section in world_state.md."""
        path = self.root / "world_state.md"
        text = path.read_text()
        pattern = rf"(## {re.escape(section)}\n)(.*?)(?=\n## |\Z)"
        match = re.search(pattern, text, re.DOTALL)
        if match:
            text = text[: match.start(2)] + content + "\n" + text[match.end(2) :]
        else:
            text += f"\n## {section}\n{content}\n"
        path.write_text(text)
        return f"Updated world_state.md section: {section}"

    # ------------------------------------------------------------------
    # Search
    # ------------------------------------------------------------------

    def search_memory(self, query: str) -> list[dict]:
        """Simple keyword search across all memory files.

        Returns list of {file, line_number, line} dicts.
        """
        results: list[dict] = []
        query_lower = query.lower()
        for md_file in self.root.rglob("*.md"):
            try:
                lines = md_file.read_text().splitlines()
            except Exception:
                continue
            for i, line in enumerate(lines, 1):
                if query_lower in line.lower():
                    results.append({
                        "file": str(md_file.relative_to(self.root)),
                        "line_number": i,
                        "line": line.strip(),
                    })
        return results

    # ------------------------------------------------------------------
    # Context building (fed to agent each turn)
    # ------------------------------------------------------------------

    def load_session_context(self) -> str:
        """Build a context string for the Game Master from memory files.

        Includes: player profile + relationships + recent decisions +
        world state + today's log + yesterday's log.
        """
        parts: list[str] = []

        # Player profile
        parts.append("=== PLAYER PROFILE ===")
        parts.append(self.read_player_profile())

        # Relationships (trimmed)
        rels = self.read_relationships()
        if len(rels.strip().splitlines()) > 2:  # More than just the header
            parts.append("=== RELATIONSHIPS ===")
            parts.append(rels)

        # Recent decisions (last 10 entries)
        decisions = self.read_decisions()
        dec_lines = decisions.strip().splitlines()
        if len(dec_lines) > 3:
            parts.append("=== RECENT DECISIONS ===")
            # Take last ~30 lines to get ~10 decisions
            parts.append("\n".join(dec_lines[-30:]))

        # World state
        parts.append("=== WORLD STATE ===")
        parts.append(self.read_world_state())

        # Daily logs (today + yesterday)
        today = date.today().isoformat()
        yesterday = (date.today().replace(day=date.today().day - 1)).isoformat() if date.today().day > 1 else None
        for day_str in [yesterday, today]:
            if day_str is None:
                continue
            log_path = self.root / "daily" / f"{day_str}.md"
            if log_path.exists():
                parts.append(f"=== SESSION LOG {day_str} ===")
                parts.append(log_path.read_text())

        return "\n\n".join(parts)

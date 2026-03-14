"""Game State Models — Pydantic models for all game data.

Defines the canonical data structures for players, ships, missions,
inventory, and all game entities. References JSON data in server/src/data/.
"""

from __future__ import annotations

import json
import random
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from pydantic import BaseModel, Field

# ---------------------------------------------------------------------------
# Path to bundled game data
# ---------------------------------------------------------------------------
DATA_DIR = Path(__file__).resolve().parent.parent / "data"

# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------

def _load_json(path: Path) -> Any:
    with open(path) as f:
        return json.load(f)


def _utcnow() -> str:
    return datetime.now(timezone.utc).isoformat()


# ---------------------------------------------------------------------------
# Player
# ---------------------------------------------------------------------------

class Skills(BaseModel):
    engineering: int = 0
    diplomacy: int = 0
    combat: int = 0
    science: int = 0


class PlayerState(BaseModel):
    name: str = "Player"
    level: int = 1
    xp: int = 0
    xp_to_next: int = 100
    credits: int = 0
    skill_points: int = 0
    skills: Skills = Field(default_factory=Skills)

    def award_xp(self, amount: int) -> dict:
        """Award XP, handle level-ups. Returns summary dict."""
        xp_curve = [0, 100, 250, 450, 700, 1000]
        self.xp += amount
        leveled_up = False
        while self.level < len(xp_curve) and self.xp >= xp_curve[self.level]:
            self.xp -= xp_curve[self.level]
            self.level += 1
            self.skill_points += 2
            leveled_up = True
        if self.level < len(xp_curve):
            self.xp_to_next = xp_curve[self.level] - self.xp
        else:
            self.xp_to_next = 0
        return {"leveled_up": leveled_up, "new_level": self.level, "xp": self.xp}


# ---------------------------------------------------------------------------
# Ship
# ---------------------------------------------------------------------------

class ShipSystem(BaseModel):
    name: str
    display_name: str = ""
    level: int = 0
    health: int = 100
    active: bool = False
    installed_part: str | None = None
    power_cost: int = 0

    def summary(self) -> str:
        status = "ONLINE" if self.active else "OFFLINE"
        part_info = f" [{self.installed_part}]" if self.installed_part else ""
        return f"{self.display_name} Lv{self.level} ({status}, HP:{self.health}){part_info}"


class InventoryItem(BaseModel):
    item_id: str
    name: str
    description: str = ""
    quantity: int = 1
    rarity: str = "common"
    weight: float = 1.0
    system_type: str | None = None
    level: int = 0
    stats: dict[str, Any] = Field(default_factory=dict)


class ShipState(BaseModel):
    name: str = "Unnamed Vessel"
    systems: dict[str, ShipSystem] = Field(default_factory=dict)
    inventory: list[InventoryItem] = Field(default_factory=list)
    classification: str = "Hulk"
    hull_hp: int = 0
    max_hull_hp: int = 0
    power_available: int = 0
    power_total: int = 0

    def recalculate_power(self) -> None:
        """Recalculate power from ship_systems.json data."""
        systems_data = load_ship_systems()
        sys_map = {s["system_name"]: s for s in systems_data}
        total_output = 0
        total_cost = 0
        for sys_name, sys in self.systems.items():
            data = sys_map.get(sys_name)
            if not data:
                continue
            if sys_name == "power" and sys.level > 0:
                stats = data["stats_per_level"][sys.level]
                total_output = stats.get("power_output", 0)
            if sys.active and sys.level > 0:
                idx = sys.level - 1
                costs = data.get("power_costs", [])
                if idx < len(costs):
                    cost = costs[idx]
                    sys.power_cost = cost
                    total_cost += cost
        self.power_total = total_output
        self.power_available = total_output - total_cost
        # Update hull HP
        hull = self.systems.get("hull")
        if hull:
            hull_data = sys_map.get("hull")
            if hull_data and hull.level > 0:
                stats = hull_data["stats_per_level"][hull.level]
                self.max_hull_hp = stats.get("max_hp", 0)
                self.hull_hp = min(self.hull_hp, self.max_hull_hp) or self.max_hull_hp

    def inventory_weight(self) -> float:
        return sum(item.weight * item.quantity for item in self.inventory)

    def find_item(self, item_id: str) -> InventoryItem | None:
        for item in self.inventory:
            if item.item_id == item_id:
                return item
        return None

    def add_item(self, item: InventoryItem) -> None:
        existing = self.find_item(item.item_id)
        if existing:
            existing.quantity += item.quantity
        else:
            self.inventory.append(item)

    def remove_item(self, item_id: str, quantity: int = 1) -> bool:
        existing = self.find_item(item_id)
        if not existing or existing.quantity < quantity:
            return False
        existing.quantity -= quantity
        if existing.quantity <= 0:
            self.inventory = [i for i in self.inventory if i.item_id != item_id]
        return True


# ---------------------------------------------------------------------------
# World State
# ---------------------------------------------------------------------------

class WorldState(BaseModel):
    phase: int = 1  # 1 = Earthbound, 2 = Space
    completed_missions: list[str] = Field(default_factory=list)
    active_mission_id: str | None = None
    active_stage_id: str | None = None
    discovered_locations: list[str] = Field(default_factory=list)
    discovered_parts: list[str] = Field(default_factory=list)
    major_choices: list[str] = Field(default_factory=list)
    active_effects: list[str] = Field(default_factory=list)
    factions: dict[str, int] = Field(default_factory=dict)  # faction -> reputation
    active_events: list[str] = Field(default_factory=list)
    timeline: list[str] = Field(default_factory=list)


# ---------------------------------------------------------------------------
# Mission (loaded from JSON)
# ---------------------------------------------------------------------------

class MissionChoice(BaseModel):
    choice_id: str
    text: str
    requirements: dict[str, Any] = Field(default_factory=dict)
    success_chance: int | str = 100
    consequences: dict[str, Any] = Field(default_factory=dict)


class MissionStage(BaseModel):
    stage_id: str
    title: str = ""
    description: str = ""
    image: str = ""
    choices: list[MissionChoice] = Field(default_factory=list)


class Mission(BaseModel):
    mission_id: str
    title: str
    type: str = "story"
    location: str = ""
    description: str = ""
    difficulty: int = 1
    estimated_time: str = ""
    requirements: dict[str, Any] = Field(default_factory=dict)
    objectives: list[str] = Field(default_factory=list)
    stages: list[MissionStage] = Field(default_factory=list)
    rewards: dict[str, Any] = Field(default_factory=dict)
    failure_consequences: dict[str, Any] = Field(default_factory=dict)

    def get_stage(self, stage_id: str) -> MissionStage | None:
        for stage in self.stages:
            if stage.stage_id == stage_id:
                return stage
        return None

    def get_choice(self, stage_id: str, choice_id: str) -> MissionChoice | None:
        stage = self.get_stage(stage_id)
        if not stage:
            return None
        for choice in stage.choices:
            if choice.choice_id == choice_id:
                return choice
        return None


# ---------------------------------------------------------------------------
# Full Game Session
# ---------------------------------------------------------------------------

class GameSession(BaseModel):
    session_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    player: PlayerState = Field(default_factory=PlayerState)
    ship: ShipState = Field(default_factory=ShipState)
    world: WorldState = Field(default_factory=WorldState)
    created_at: str = Field(default_factory=_utcnow)
    updated_at: str = Field(default_factory=_utcnow)
    turn_count: int = 0
    conversation_history: list[dict[str, str]] = Field(default_factory=list)

    def touch(self) -> None:
        self.updated_at = _utcnow()
        self.turn_count += 1


# ---------------------------------------------------------------------------
# Data loaders (read from server/src/data/)
# ---------------------------------------------------------------------------

_ship_systems_cache: list[dict] | None = None
_economy_cache: dict | None = None
_missions_cache: dict[str, Mission] | None = None
_parts_cache: dict[str, dict] | None = None


def load_ship_systems() -> list[dict]:
    global _ship_systems_cache
    if _ship_systems_cache is None:
        data = _load_json(DATA_DIR / "systems" / "ship_systems.json")
        _ship_systems_cache = data["systems"]
    return _ship_systems_cache


def load_economy_config() -> dict:
    global _economy_cache
    if _economy_cache is None:
        _economy_cache = _load_json(DATA_DIR / "economy" / "economy_config.json")
    return _economy_cache


def load_all_missions() -> dict[str, Mission]:
    global _missions_cache
    if _missions_cache is None:
        _missions_cache = {}
        missions_dir = DATA_DIR / "missions"
        for f in missions_dir.glob("mission_*.json"):
            data = _load_json(f)
            mission = Mission(**data)
            _missions_cache[mission.mission_id] = mission
    return _missions_cache


def load_all_parts() -> dict[str, dict]:
    global _parts_cache
    if _parts_cache is None:
        _parts_cache = {}
        parts_dir = DATA_DIR / "parts"
        for f in parts_dir.glob("*_parts.json"):
            data = _load_json(f)
            for part in data.get("parts", []):
                _parts_cache[part["id"]] = part
    return _parts_cache


def get_part_as_item(part_id: str) -> InventoryItem | None:
    parts = load_all_parts()
    part = parts.get(part_id)
    if not part:
        return None
    return InventoryItem(
        item_id=part["id"],
        name=part["name"],
        description=part.get("description", ""),
        quantity=1,
        rarity=part.get("rarity", "common"),
        weight=part.get("weight", 1.0),
        system_type=part.get("system_type"),
        level=part.get("level", 0),
        stats=part.get("stats", {}),
    )


# ---------------------------------------------------------------------------
# Factory: new game session with default ship systems
# ---------------------------------------------------------------------------

def create_new_game(player_name: str = "Player") -> GameSession:
    """Create a fresh game session with all 10 ship systems at level 0."""
    systems_data = load_ship_systems()
    economy = load_economy_config()

    systems: dict[str, ShipSystem] = {}
    for sys_data in systems_data:
        name = sys_data["system_name"]
        systems[name] = ShipSystem(
            name=name,
            display_name=sys_data["display_name"],
            level=0,
            health=100,
            active=False,
        )

    starting_credits = economy.get("starting_state", {}).get("credits", 0)

    session = GameSession(
        player=PlayerState(name=player_name, credits=starting_credits),
        ship=ShipState(systems=systems),
    )
    return session


# ---------------------------------------------------------------------------
# Skill check helper
# ---------------------------------------------------------------------------

def roll_skill_check(skill_value: int, difficulty: int) -> dict:
    """Roll a d20 + skill vs difficulty threshold.

    Returns dict with roll, total, difficulty, success, margin.
    """
    roll = random.randint(1, 20)
    total = roll + skill_value
    threshold = 10 + (difficulty * 2)
    success = total >= threshold
    return {
        "roll": roll,
        "skill_bonus": skill_value,
        "total": total,
        "threshold": threshold,
        "difficulty": difficulty,
        "success": success,
        "margin": total - threshold,
        "critical": roll == 20,
        "fumble": roll == 1,
    }

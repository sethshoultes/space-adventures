"""Game State Models - Pydantic models for all game data.

Defines the canonical data structures for players, ships, missions,
inventory, and all game entities.
"""

from pydantic import BaseModel, Field


class Skill(BaseModel):
    engineering: int = 0
    diplomacy: int = 0
    combat: int = 0
    science: int = 0


class Player(BaseModel):
    id: str
    name: str = "Player"
    level: int = 1
    xp: int = 0
    credits: int = 100
    skills: Skill = Field(default_factory=Skill)


class ShipSystem(BaseModel):
    name: str
    level: int = 0
    health: int = 100
    active: bool = False
    installed_part: str | None = None


class Ship(BaseModel):
    name: str = "Unnamed Vessel"
    systems: dict[str, ShipSystem] = Field(default_factory=dict)
    hull_hp: int = 0
    max_hull_hp: int = 0
    power_available: int = 0
    power_total: int = 0


class InventoryItem(BaseModel):
    item_id: str
    name: str
    quantity: int = 1
    rarity: str = "common"
    weight: float = 1.0


class GameState(BaseModel):
    version: str = "2.0.0"
    player: Player
    ship: Ship = Field(default_factory=Ship)
    inventory: list[InventoryItem] = Field(default_factory=list)
    phase: int = 1
    completed_missions: list[str] = Field(default_factory=list)
    discovered_locations: list[str] = Field(default_factory=list)
    major_choices: list[str] = Field(default_factory=list)

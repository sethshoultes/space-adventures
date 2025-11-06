"""
Game State Models.

These models represent the current state of the game from Godot.
Used to provide context to AI generation.
"""

from pydantic import BaseModel, Field
from typing import Dict, List, Optional


class Player(BaseModel):
    """Player state."""
    name: str = "Player"
    level: int = 1
    xp: int = 0
    rank: str = "Cadet"
    skills: Dict[str, int] = Field(
        default_factory=lambda: {
            "engineering": 0,
            "diplomacy": 0,
            "combat": 0,
            "science": 0
        }
    )


class ShipSystem(BaseModel):
    """Individual ship system state."""
    level: int = 0
    health: int = 100
    active: bool = False
    installed_part: Optional[str] = None


class Ship(BaseModel):
    """Ship state."""
    name: str = "Unnamed Vessel"
    ship_class: str = "None"
    systems: Dict[str, ShipSystem] = Field(default_factory=dict)
    hull_hp: int = 0
    max_hull_hp: int = 0
    power_available: int = 0
    power_total: int = 0


class Progress(BaseModel):
    """Player progress state."""
    phase: int = 1  # 1=Earthbound, 2=Space
    completed_missions: List[str] = Field(default_factory=list)
    discovered_locations: List[str] = Field(default_factory=list)
    major_choices: List[str] = Field(default_factory=list)


class GameState(BaseModel):
    """
    Complete game state from Godot.

    This is sent from Godot to provide context for AI generation.
    """
    version: str = "1.0.0"
    player: Player = Field(default_factory=Player)
    ship: Ship = Field(default_factory=Ship)
    progress: Progress = Field(default_factory=Progress)

    def get_operational_systems(self) -> List[str]:
        """Get list of operational ship systems."""
        return [
            name for name, system in self.ship.systems.items()
            if system.active and system.level > 0
        ]

    def get_completed_missions_count(self) -> int:
        """Get count of completed missions."""
        return len(self.progress.completed_missions)

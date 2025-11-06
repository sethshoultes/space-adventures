"""
Mission Models.

Models for mission generation requests and responses.
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from .game_state import GameState


class MissionRequest(BaseModel):
    """Request to generate a mission."""
    game_state: GameState
    difficulty: str = Field(
        ...,
        description="Mission difficulty: easy, medium, hard, extreme"
    )
    mission_type: Optional[str] = Field(
        None,
        description="Optional mission type: salvage, exploration, trade, rescue, combat, story"
    )
    location: Optional[str] = Field(
        None,
        description="Optional specific location for the mission"
    )
    required_reward_type: Optional[str] = Field(
        None,
        description="Optional required reward (e.g., 'warp_drive_part')"
    )


class Consequence(BaseModel):
    """Consequence of a choice."""
    success_condition: Optional[str] = None
    next_stage: Optional[str] = None
    xp_bonus: int = 0
    damage: int = 0
    reward_items: List[str] = Field(default_factory=list)
    description: str


class Choice(BaseModel):
    """A choice the player can make."""
    choice_id: str
    text: str
    requirements: Dict[str, Any] = Field(
        default_factory=dict,
        description="Requirements like {'skill': 'engineering', 'level': 3}"
    )
    consequence: Consequence


class MissionStage(BaseModel):
    """A stage in the mission."""
    stage_id: str
    description: str
    choices: List[Choice]


class Mission(BaseModel):
    """Complete mission structure."""
    mission_id: str
    title: str
    type: str
    location: str
    description: str
    difficulty: str
    stages: List[MissionStage]
    rewards: Dict[str, Any] = Field(
        default_factory=lambda: {"xp": 0, "items": []}
    )


class MissionResponse(BaseModel):
    """Response from mission generation."""
    success: bool = True
    mission: Optional[Mission] = None
    error: Optional[str] = None
    cached: bool = False
    generation_time_ms: Optional[float] = None

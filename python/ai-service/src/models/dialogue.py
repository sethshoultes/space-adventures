"""
Dialogue Models.

Models for NPC dialogue generation.
"""

from pydantic import BaseModel, Field
from typing import Optional


class DialogueRequest(BaseModel):
    """Request to generate NPC dialogue."""
    npc_name: str = Field(..., description="Name of the NPC")
    npc_role: str = Field(
        ...,
        description="NPC's role (e.g., 'Scrap dealer', 'Station commander')"
    )
    location: str = Field(..., description="Current location")
    context: str = Field(
        ...,
        description="Context of the conversation or situation"
    )
    player_message: str = Field(..., description="What the player said")


class DialogueResponse(BaseModel):
    """Response with NPC dialogue."""
    success: bool = True
    npc_name: str
    npc_dialogue: str
    error: Optional[str] = None
    cached: bool = False
    generation_time_ms: Optional[float] = None

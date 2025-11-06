"""
Chat Models.

Models for chat/conversation system with AI personalities.
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from .game_state import GameState


class ChatMessage(BaseModel):
    """A single chat message."""
    role: str = Field(..., description="user or assistant")
    content: str
    timestamp: Optional[str] = None


class ChatRequest(BaseModel):
    """Request to process a chat message."""
    message: str = Field(..., description="Player's message")
    session_id: str = Field(..., description="Unique session/save ID")
    ai_personality: str = Field(
        default="atlas",
        description="AI personality: atlas, companion, mentor, engineer"
    )
    game_state: GameState
    conversation_context: List[ChatMessage] = Field(
        default_factory=list,
        description="Recent conversation history (last 10 messages)"
    )


class ChatResponse(BaseModel):
    """Response from chat system."""
    success: bool = True
    ai_personality: str
    ai_name: str  # Display name (e.g., "ATLAS", "Companion")
    message: str
    command_executed: Optional[str] = Field(
        None,
        description="If a command was parsed (e.g., 'fuel_status')"
    )
    actions: Optional[Dict[str, Any]] = Field(
        None,
        description="Optional actions for game to execute"
    )
    error: Optional[str] = None
    cached: bool = False
    generation_time_ms: Optional[float] = None


class SpontaneousEventRequest(BaseModel):
    """Request for a spontaneous AI event/comment."""
    session_id: str
    ai_personality: str = "companion"
    game_state: GameState
    recent_action: Optional[str] = Field(
        None,
        description="What player just did"
    )
    time_elapsed_minutes: int = Field(
        default=0,
        description="Minutes since last spontaneous event"
    )


class SpontaneousEventResponse(BaseModel):
    """Response for spontaneous event."""
    success: bool = True
    should_trigger: bool = Field(
        description="Whether to show this event to player"
    )
    ai_personality: str
    ai_name: str
    message: Optional[str] = None
    event_type: Optional[str] = Field(
        None,
        description="Type: info, support, ambient, warning"
    )
    error: Optional[str] = None

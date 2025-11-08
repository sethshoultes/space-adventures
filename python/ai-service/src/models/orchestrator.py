"""
Pydantic models for orchestrator API endpoints
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from enum import Enum


class AgentName(str, Enum):
    """Available agent names"""
    ATLAS = "atlas"
    STORYTELLER = "storyteller"
    TACTICAL = "tactical"
    COMPANION = "companion"


class ChatRequest(BaseModel):
    """Request model for chat endpoint"""
    agent: AgentName = Field(..., description="Name of the AI agent to chat with")
    message: str = Field(..., min_length=1, description="User message to send to the agent")
    conversation_id: Optional[str] = Field(None, description="Optional conversation ID for persistence")
    include_functions: bool = Field(True, description="Enable function calling (ATLAS only)")
    game_state: Optional[Dict[str, Any]] = Field(None, description="Current game state for context")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "agent": "atlas",
                    "message": "What is the current ship status?",
                    "include_functions": True
                }
            ]
        }
    }


class FunctionCall(BaseModel):
    """Function call made by agent"""
    name: str = Field(..., description="Name of the function called")
    arguments: Dict[str, Any] = Field(..., description="Arguments passed to the function")
    result: Dict[str, Any] = Field(..., description="Result returned by the function")


class ChatResponse(BaseModel):
    """Response model for chat endpoint"""
    success: bool = Field(..., description="Whether the request was successful")
    agent: str = Field(..., description="Agent that responded")
    model: Optional[str] = Field(None, description="Model used for response")
    response: Optional[str] = Field(None, description="Agent's text response")
    function_call: Optional[FunctionCall] = Field(None, description="Function call made by agent (if any)")
    conversation_id: Optional[str] = Field(None, description="Conversation ID")
    error: Optional[str] = Field(None, description="Error message if request failed")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "success": True,
                    "agent": "atlas",
                    "model": "ollama/llama3.2:3b",
                    "response": "All systems operational. Ship status nominal."
                }
            ]
        }
    }


class RouteRequest(BaseModel):
    """Request model for intelligent routing"""
    message: str = Field(..., min_length=1, description="User message to route")
    conversation_id: Optional[str] = Field(None, description="Optional conversation ID")
    game_state: Optional[Dict[str, Any]] = Field(None, description="Current game state")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "message": "What's the ship status?",
                }
            ]
        }
    }


class HandoffRequest(BaseModel):
    """Request model for agent handoff"""
    from_agent: AgentName = Field(..., description="Agent initiating handoff")
    to_agent: AgentName = Field(..., description="Agent receiving handoff")
    context: str = Field(..., min_length=1, description="Context to pass to new agent")
    conversation_id: Optional[str] = Field(None, description="Optional conversation ID")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "from_agent": "atlas",
                    "to_agent": "tactical",
                    "context": "Enemy vessels detected. Please provide tactical analysis."
                }
            ]
        }
    }


class AgentInfo(BaseModel):
    """Information about an available agent"""
    name: str = Field(..., description="Agent name")
    description: str = Field(..., description="Agent description")
    capabilities: List[str] = Field(..., description="List of agent capabilities")


class AgentsListResponse(BaseModel):
    """Response model for listing available agents"""
    success: bool = Field(..., description="Whether the request was successful")
    agents: List[AgentInfo] = Field(..., description="List of available agents")


class HealthCheckResponse(BaseModel):
    """Response model for orchestrator health check"""
    orchestrator: str = Field(..., description="Orchestrator status")
    providers: Dict[str, str] = Field(..., description="Provider availability")
    agents: Dict[str, Any] = Field(..., description="Agent configuration status")
    functions_available: int = Field(..., description="Number of callable functions")


class ConversationMessage(BaseModel):
    """Single message in a conversation"""
    role: str = Field(..., description="Message role (user, assistant, system)")
    content: str = Field(..., description="Message content")
    timestamp: Optional[str] = Field(None, description="Message timestamp")


class ConversationHistoryResponse(BaseModel):
    """Response model for conversation history"""
    success: bool = Field(..., description="Whether the request was successful")
    agent: str = Field(..., description="Agent name")
    conversation_id: Optional[str] = Field(None, description="Conversation ID")
    messages: List[ConversationMessage] = Field(..., description="List of messages")
    error: Optional[str] = Field(None, description="Error message if request failed")


class ClearHistoryRequest(BaseModel):
    """Request model for clearing conversation history"""
    agent: Optional[AgentName] = Field(None, description="Specific agent to clear, or None for all")
    conversation_id: Optional[str] = Field(None, description="Optional conversation ID to clear")


class ClearHistoryResponse(BaseModel):
    """Response model for clear history"""
    success: bool = Field(..., description="Whether the request was successful")
    message: str = Field(..., description="Success message")
    agent: Optional[str] = Field(None, description="Agent cleared (if specific)")


class UrgencyLevel(str, Enum):
    """Urgency levels for agent messages"""
    INFO = "INFO"
    MEDIUM = "MEDIUM"
    URGENT = "URGENT"
    CRITICAL = "CRITICAL"


class AgentLoopRequest(BaseModel):
    """Request model for agent loop endpoint"""
    agent: str = Field(..., description="Name of the agent to check (e.g., 'atlas')")
    game_state: Dict[str, Any] = Field(..., description="Current game state for agent to analyze")
    force_check: bool = Field(False, description="Override throttling for testing")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "agent": "atlas",
                    "game_state": {
                        "player": {"level": 3, "rank": "Lieutenant"},
                        "ship": {"hull_hp": 45, "max_hull_hp": 100, "power": 80},
                        "mission": {"title": "Cargo Escort", "stage": "route_planning"},
                        "environment": {"location": "Gamma Route", "threats": []}
                    },
                    "force_check": False
                }
            ]
        }
    }


class AgentLoopResponse(BaseModel):
    """Response model for agent loop endpoint"""
    success: bool = Field(..., description="Whether the check was successful")
    data: Optional[Dict[str, Any]] = Field(None, description="Agent response data if successful")
    error: Optional[str] = Field(None, description="Error message if failed")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "success": True,
                    "data": {
                        "should_act": True,
                        "message": "Captain, hull integrity at 45%. Micrometeorite impacts detected...",
                        "urgency": "MEDIUM",
                        "tools_used": ["get_system_status"],
                        "reasoning": "Hull below 50% threshold",
                        "next_check_in": 45
                    }
                },
                {
                    "success": True,
                    "data": {
                        "should_act": False,
                        "message": None,
                        "reasoning": "All systems nominal, no changes since last check",
                        "next_check_in": 60
                    }
                },
                {
                    "success": False,
                    "error": "Agent error: LLM timeout"
                }
            ]
        }
    }

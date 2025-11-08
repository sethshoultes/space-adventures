"""
Orchestrator API Router

FastAPI endpoints for multi-agent AI orchestration.

Endpoints:
- POST /api/orchestrator/chat - Chat with a specific agent
- POST /api/orchestrator/route - Intelligently route message to best agent
- POST /api/orchestrator/handoff - Hand off conversation between agents
- GET /api/orchestrator/agents - List available agents
- GET /api/orchestrator/history/{agent} - Get conversation history
- DELETE /api/orchestrator/history - Clear conversation history
- GET /api/orchestrator/health - Orchestrator health check
"""

import logging
from fastapi import APIRouter, HTTPException, status
from typing import Dict, Any

from ..models.orchestrator import (
    ChatRequest,
    ChatResponse,
    RouteRequest,
    HandoffRequest,
    AgentsListResponse,
    AgentInfo,
    HealthCheckResponse,
    ConversationHistoryResponse,
    ConversationMessage,
    ClearHistoryRequest,
    ClearHistoryResponse,
    AgentLoopRequest,
    AgentLoopResponse
)
from ..orchestrator import get_orchestrator

logger = logging.getLogger(__name__)

# Create router
router = APIRouter(
    prefix="/api/orchestrator",
    tags=["orchestrator"],
    responses={
        500: {"description": "Internal server error"},
        400: {"description": "Bad request"}
    }
)


@router.post("/chat", response_model=ChatResponse)
async def chat_with_agent(request: ChatRequest) -> ChatResponse:
    """
    Chat with a specific AI agent

    Send a message to a specific agent and get a response. ATLAS can call
    game functions if include_functions is True.

    Args:
        request: Chat request with agent name, message, and options

    Returns:
        Agent's response (text and/or function call)

    Raises:
        HTTPException: If agent is unknown or request fails
    """
    try:
        orchestrator = get_orchestrator(game_state=request.game_state)

        result = await orchestrator.chat(
            agent_name=request.agent.value,
            message=request.message,
            include_functions=request.include_functions,
            conversation_id=request.conversation_id
        )

        if not result.get("success", False):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=result.get("error", "Chat request failed")
            )

        # Build response
        response_data = {
            "success": True,
            "agent": result["agent"],
            "model": result.get("model"),
            "response": result.get("response"),
            "conversation_id": result.get("conversation_id")
        }

        # Add function call if present
        if "function_call" in result:
            from ..models.orchestrator import FunctionCall
            response_data["function_call"] = FunctionCall(
                name=result["function_call"]["name"],
                arguments=result["function_call"]["arguments"],
                result=result["function_call"]["result"]
            )

        return ChatResponse(**response_data)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in chat endpoint: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.post("/route", response_model=ChatResponse)
async def route_message(request: RouteRequest) -> ChatResponse:
    """
    Intelligently route a message to the most appropriate agent

    Uses keyword matching to determine which agent is best suited to
    handle the message. Falls back to ATLAS if unclear.

    Args:
        request: Message to route

    Returns:
        Response from the selected agent

    Raises:
        HTTPException: If routing fails
    """
    try:
        orchestrator = get_orchestrator(game_state=request.game_state)

        result = await orchestrator.route_message(
            message=request.message,
            conversation_id=request.conversation_id
        )

        if not result.get("success", False):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=result.get("error", "Routing failed")
            )

        response_data = {
            "success": True,
            "agent": result["agent"],
            "model": result.get("model"),
            "response": result.get("response"),
            "conversation_id": result.get("conversation_id")
        }

        if "function_call" in result:
            from ..models.orchestrator import FunctionCall
            response_data["function_call"] = FunctionCall(
                name=result["function_call"]["name"],
                arguments=result["function_call"]["arguments"],
                result=result["function_call"]["result"]
            )

        return ChatResponse(**response_data)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in route endpoint: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.post("/handoff", response_model=ChatResponse)
async def handoff_conversation(request: HandoffRequest) -> ChatResponse:
    """
    Hand off a conversation from one agent to another

    Transfer context from one agent to another for collaborative
    problem-solving.

    Args:
        request: Handoff request with source/target agents and context

    Returns:
        Response from the target agent

    Raises:
        HTTPException: If handoff fails
    """
    try:
        orchestrator = get_orchestrator()

        result = await orchestrator.handoff(
            from_agent=request.from_agent.value,
            to_agent=request.to_agent.value,
            context=request.context,
            conversation_id=request.conversation_id
        )

        if not result.get("success", False):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=result.get("error", "Handoff failed")
            )

        response_data = {
            "success": True,
            "agent": result["agent"],
            "model": result.get("model"),
            "response": result.get("response"),
            "conversation_id": result.get("conversation_id")
        }

        if "function_call" in result:
            from ..models.orchestrator import FunctionCall
            response_data["function_call"] = FunctionCall(
                name=result["function_call"]["name"],
                arguments=result["function_call"]["arguments"],
                result=result["function_call"]["result"]
            )

        return ChatResponse(**response_data)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in handoff endpoint: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.get("/agents", response_model=AgentsListResponse)
async def list_agents() -> AgentsListResponse:
    """
    List all available AI agents

    Returns information about each agent including their name, description,
    and capabilities.

    Returns:
        List of available agents
    """
    try:
        orchestrator = get_orchestrator()
        agents_info = orchestrator.get_available_agents()

        return AgentsListResponse(
            success=True,
            agents=[
                AgentInfo(**agent)
                for agent in agents_info
            ]
        )

    except Exception as e:
        logger.error(f"Error listing agents: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.get("/history/{agent}", response_model=ConversationHistoryResponse)
async def get_conversation_history(agent: str) -> ConversationHistoryResponse:
    """
    Get conversation history for an agent

    Retrieves the conversation history for a specific agent in the current
    session. For persistent history, use conversation_id.

    Args:
        agent: Agent name (atlas, storyteller, tactical, companion)

    Returns:
        Conversation history

    Raises:
        HTTPException: If agent is unknown
    """
    try:
        orchestrator = get_orchestrator()

        # Validate agent
        from ..orchestrator.agents import is_valid_agent
        if not is_valid_agent(agent):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unknown agent: {agent}"
            )

        history = orchestrator.get_history(agent)

        return ConversationHistoryResponse(
            success=True,
            agent=agent,
            messages=[
                ConversationMessage(
                    role=msg["role"],
                    content=msg["content"]
                )
                for msg in history
            ]
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting history: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.delete("/history", response_model=ClearHistoryResponse)
async def clear_conversation_history(request: ClearHistoryRequest) -> ClearHistoryResponse:
    """
    Clear conversation history

    Clear conversation history for a specific agent or all agents.

    Args:
        request: Clear history request (agent optional)

    Returns:
        Success confirmation
    """
    try:
        orchestrator = get_orchestrator()

        if request.agent:
            orchestrator.clear_history(request.agent.value)
            message = f"Cleared history for {request.agent.value}"
        else:
            orchestrator.clear_history()
            message = "Cleared history for all agents"

        return ClearHistoryResponse(
            success=True,
            message=message,
            agent=request.agent.value if request.agent else None
        )

    except Exception as e:
        logger.error(f"Error clearing history: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.get("/health", response_model=HealthCheckResponse)
async def health_check() -> HealthCheckResponse:
    """
    Check orchestrator health

    Returns status of the orchestrator, configured providers, and available
    agents.

    Returns:
        Health check results
    """
    try:
        orchestrator = get_orchestrator()
        health = await orchestrator.health_check()

        return HealthCheckResponse(**health)

    except Exception as e:
        logger.error(f"Error in health check: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal error: {str(e)}"
        )


@router.post("/agent_loop", response_model=AgentLoopResponse)
async def agent_loop_check(request: AgentLoopRequest) -> AgentLoopResponse:
    """
    Agent Loop - Autonomous agent periodic check

    This endpoint is called periodically (every 45-60s) by the Godot client
    to allow autonomous agents to monitor game state and provide proactive
    interjections.

    The agent will:
    1. Observe the current game state
    2. Reason whether intervention is needed
    3. Act (run tools if necessary)
    4. Reflect on importance
    5. Communicate (generate message or stay silent)

    Args:
        request: Agent name, game state, and options

    Returns:
        Agent decision (should_act, message, urgency, etc.) or silent response

    Raises:
        HTTPException: If agent is unknown or check fails
    """
    try:
        logger.info(f"Agent loop check for {request.agent}")

        # Validate agent name
        from ..orchestrator.agents import is_valid_agent
        if not is_valid_agent(request.agent):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unknown agent: {request.agent}. Valid agents: atlas, storyteller, tactical, companion"
            )

        # Get orchestrator with game state context
        orchestrator = get_orchestrator(game_state=request.game_state)

        # For Phase 1, we only support ATLAS
        if request.agent != "atlas":
            logger.warning(f"Agent {request.agent} not yet implemented, returning silent response")
            return AgentLoopResponse(
                success=True,
                data={
                    "should_act": False,
                    "message": None,
                    "reasoning": f"Agent {request.agent} not yet implemented (Phase 2)",
                    "next_check_in": 60
                }
            )

        # TODO: Implement actual agent loop logic
        # For now, return a placeholder response
        # This will be replaced with actual LangGraph ReAct loop implementation

        # Check throttling (unless force_check is True)
        if not request.force_check:
            # TODO: Implement Redis-based throttling check
            # Check if agent sent message in last 60 seconds
            # Check if hourly rate limit exceeded
            pass

        # Placeholder: Analyze game state
        hull_hp = request.game_state.get("ship", {}).get("hull_hp", 100)
        max_hull_hp = request.game_state.get("ship", {}).get("max_hull_hp", 100)
        hull_percentage = (hull_hp / max_hull_hp * 100) if max_hull_hp > 0 else 100

        # Simple logic for demonstration
        if hull_percentage < 50:
            # Agent should act - hull critical
            return AgentLoopResponse(
                success=True,
                data={
                    "should_act": True,
                    "message": f"Captain, hull integrity at {int(hull_percentage)}%. Recommend immediate repair.",
                    "urgency": "MEDIUM" if hull_percentage > 30 else "URGENT",
                    "tools_used": ["get_system_status"],
                    "reasoning": f"Hull below 50% threshold ({int(hull_percentage)}%)",
                    "next_check_in": 45
                }
            )
        else:
            # Agent stays silent - all nominal
            return AgentLoopResponse(
                success=True,
                data={
                    "should_act": False,
                    "message": None,
                    "reasoning": "All systems nominal, no changes requiring attention",
                    "next_check_in": 60
                }
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in agent loop check: {e}", exc_info=True)
        return AgentLoopResponse(
            success=False,
            error=f"Agent error: {str(e)}"
        )


# Export router
__all__ = ["router"]

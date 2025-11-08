"""
AI Orchestrator - Main orchestration logic

Manages multi-agent AI system using LiteLLM for provider-agnostic orchestration.
"""

import json
import logging
from typing import Dict, Any, List, Optional
from litellm import completion

from .config import OrchestratorConfig, get_config
from .agents import AgentType, get_agent_prompt, is_valid_agent
from .functions import get_functions_for_agent, execute_function, FUNCTION_REGISTRY
from .persistence import get_conversation_store, ConversationStore

logger = logging.getLogger(__name__)


class AIOrchestrator:
    """
    Multi-agent AI orchestrator using LiteLLM

    Manages 4 AI personalities:
    - ATLAS: Ship's computer (operational tasks, function calling)
    - Storyteller: Narrative engine (missions, story content)
    - Tactical: Combat advisor (tactical analysis, strategy)
    - Companion: Personal AI friend (emotional support)
    """

    def __init__(
        self,
        config: Optional[OrchestratorConfig] = None,
        game_state: Optional[Dict[str, Any]] = None,
        enable_persistence: bool = True
    ):
        """
        Initialize orchestrator

        Args:
            config: Configuration (uses global config if not provided)
            game_state: Current game state (optional, used for function calling)
            enable_persistence: Whether to enable conversation persistence
        """
        self.config = config or get_config()
        self.game_state = game_state or {}
        self.enable_persistence = enable_persistence

        # Conversation history per agent (in-memory cache)
        self.conversation_history: Dict[str, List[Dict[str, str]]] = {
            AgentType.ATLAS: [],
            AgentType.STORYTELLER: [],
            AgentType.TACTICAL: [],
            AgentType.COMPANION: []
        }

        # Conversation store for persistence
        self.store: Optional[ConversationStore] = None
        if enable_persistence:
            try:
                self.store = get_conversation_store()
                logger.info("Conversation persistence enabled")
            except Exception as e:
                logger.warning(f"Failed to initialize persistence: {e}")
                self.enable_persistence = False

        logger.info("AI Orchestrator initialized")

    async def chat(
        self,
        agent_name: str,
        message: str,
        include_functions: bool = True,
        conversation_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Send a message to an agent and get a response

        Args:
            agent_name: Name of the agent (atlas, storyteller, tactical, companion)
            message: User message
            include_functions: Whether to enable function calling (ATLAS only)
            conversation_id: Optional conversation ID for persistence

        Returns:
            Response dictionary with agent's reply
        """
        agent_name_lower = agent_name.lower()

        # Validate agent
        if not is_valid_agent(agent_name_lower):
            return {
                "success": False,
                "error": f"Unknown agent: {agent_name}",
                "available_agents": [a.value for a in AgentType]
            }

        try:
            # Load conversation history if conversation_id provided and persistence enabled
            if conversation_id and self.enable_persistence and self.store:
                try:
                    db_history = self.store.get_conversation_history(
                        conversation_id,
                        agent_name_lower
                    )
                    # Update in-memory cache with database history
                    self.conversation_history[AgentType(agent_name_lower)] = db_history
                except Exception as e:
                    logger.warning(f"Failed to load conversation history: {e}")

            # Build messages
            system_prompt = get_agent_prompt(AgentType(agent_name_lower))
            messages = [{"role": "system", "content": system_prompt}]

            # Add conversation history
            history = self.conversation_history[AgentType(agent_name_lower)]
            messages.extend(history)

            # Add current message
            messages.append({"role": "user", "content": message})

            # Get model configuration
            model = self.config.get_model_for_agent(agent_name_lower)
            temperature = self.config.get_temperature(agent_name_lower)
            api_base = self.config.get_api_base(agent_name_lower)

            # Get functions for this agent (ATLAS only)
            functions = None
            if include_functions and self.config.enable_function_calling:
                functions = get_functions_for_agent(agent_name_lower)

            logger.info(f"Calling {agent_name_lower} agent with model: {model}")

            # Call LiteLLM
            response = completion(
                model=model,
                messages=messages,
                temperature=temperature,
                max_tokens=self.config.max_tokens,
                functions=functions if functions else None,
                api_base=api_base,
                timeout=self.config.timeout
            )

            # Extract response
            choice = response.choices[0]

            # Check if function call was made (support both old and new OpenAI formats)
            has_function_call = (
                (hasattr(choice.message, 'function_call') and choice.message.function_call) or
                (hasattr(choice.message, 'tool_calls') and choice.message.tool_calls)
            )

            if has_function_call:
                # Extract function name and arguments from either format
                if hasattr(choice.message, 'tool_calls') and choice.message.tool_calls:
                    # New format (OpenAI tool_calls)
                    tool_call = choice.message.tool_calls[0]
                    function_name = tool_call.function.name
                    function_args = tool_call.function.arguments
                else:
                    # Old format (OpenAI function_call)
                    function_name = choice.message.function_call.name
                    function_args = choice.message.function_call.arguments

                logger.info(f"Agent requested function call: {function_name}")

                # Parse arguments
                try:
                    arguments = json.loads(function_args)
                except json.JSONDecodeError:
                    arguments = {}

                # Execute function
                function_result = await execute_function(
                    function_name,
                    arguments,
                    game_state=self.game_state
                )

                logger.info(f"Function {function_name} returned: {function_result}")

                # Add user message to history
                self.conversation_history[AgentType(agent_name_lower)].append(
                    {"role": "user", "content": message}
                )

                # Add assistant's function call to history (with empty content if needed)
                assistant_fc_message = choice.message.content if choice.message.content else ""
                self.conversation_history[AgentType(agent_name_lower)].append(
                    {"role": "assistant", "content": assistant_fc_message, "function_call": {"name": function_name, "arguments": json.dumps(arguments)}}
                )

                # Add function result to history
                self.conversation_history[AgentType(agent_name_lower)].append(
                    {"role": "function", "name": function_name, "content": json.dumps(function_result)}
                )

                # Make second LLM call to get natural language response based on function result
                logger.info("Making second LLM call to interpret function result")

                second_messages = [{"role": "system", "content": system_prompt}]
                second_messages.extend(self.conversation_history[AgentType(agent_name_lower)])

                second_response = completion(
                    model=model,
                    messages=second_messages,
                    temperature=temperature,
                    max_tokens=self.config.max_tokens,
                    api_base=api_base,
                    timeout=self.config.timeout
                )

                # Get the natural language response
                final_message = second_response.choices[0].message.content

                # Add final response to history
                self.conversation_history[AgentType(agent_name_lower)].append(
                    {"role": "assistant", "content": final_message}
                )

                # Save to persistence if enabled
                if conversation_id and self.enable_persistence and self.store:
                    try:
                        self.store.add_message(
                            conversation_id,
                            agent_name_lower,
                            "user",
                            message
                        )
                        self.store.add_message(
                            conversation_id,
                            agent_name_lower,
                            "assistant",
                            final_message,
                            function_call={
                                "name": function_name,
                                "arguments": arguments,
                                "result": function_result
                            }
                        )
                    except Exception as e:
                        logger.warning(f"Failed to persist messages: {e}")

                return {
                    "success": True,
                    "agent": agent_name_lower,
                    "model": model,
                    "response": final_message,
                    "function_call": {
                        "name": function_name,
                        "arguments": arguments,
                        "result": function_result
                    },
                    "conversation_id": conversation_id
                }
            else:
                # Regular text response
                assistant_message = choice.message.content

                # Save to history (in-memory)
                self.conversation_history[AgentType(agent_name_lower)].append(
                    {"role": "user", "content": message}
                )
                self.conversation_history[AgentType(agent_name_lower)].append(
                    {"role": "assistant", "content": assistant_message}
                )

                # Save to persistence if enabled
                if conversation_id and self.enable_persistence and self.store:
                    try:
                        self.store.add_message(
                            conversation_id,
                            agent_name_lower,
                            "user",
                            message
                        )
                        self.store.add_message(
                            conversation_id,
                            agent_name_lower,
                            "assistant",
                            assistant_message
                        )
                    except Exception as e:
                        logger.warning(f"Failed to persist messages: {e}")

                return {
                    "success": True,
                    "agent": agent_name_lower,
                    "model": model,
                    "response": assistant_message,
                    "conversation_id": conversation_id
                }

        except Exception as e:
            logger.error(f"Error in chat with {agent_name}: {e}", exc_info=True)
            return {
                "success": False,
                "agent": agent_name_lower,
                "error": str(e)
            }

    async def handoff(
        self,
        from_agent: str,
        to_agent: str,
        context: str,
        conversation_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Hand off conversation from one agent to another

        Args:
            from_agent: Agent initiating handoff
            to_agent: Agent receiving handoff
            context: Context to pass to new agent
            conversation_id: Optional conversation ID

        Returns:
            Response from the new agent
        """
        handoff_message = f"[Handoff from {from_agent.upper()}] {context}"
        logger.info(f"Agent handoff: {from_agent} → {to_agent}")

        return await self.chat(
            to_agent,
            handoff_message,
            conversation_id=conversation_id
        )

    async def route_message(
        self,
        message: str,
        conversation_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Intelligently route a message to the most appropriate agent

        This is a simple implementation. In production, this would use
        intent classification to determine the best agent.

        Args:
            message: User message
            conversation_id: Optional conversation ID

        Returns:
            Agent response
        """
        # Simple keyword-based routing for now
        message_lower = message.lower()

        # Keywords for each agent
        routing_keywords = {
            AgentType.ATLAS: [
                "status", "system", "power", "upgrade", "ship", "systems",
                "hull", "shields", "weapons", "inventory", "check", "scan",
                "repair", "install", "activate", "deactivate"
            ],
            AgentType.STORYTELLER: [
                "mission", "story", "quest", "explore", "discovery", "narrative",
                "adventure", "encounter", "event", "planet", "station", "npc",
                "dialogue", "choice", "consequence"
            ],
            AgentType.TACTICAL: [
                "combat", "attack", "defend", "enemy", "hostile", "threat",
                "strategy", "tactics", "weapons", "target", "maneuver",
                "shields", "damage", "risk", "probability"
            ],
            AgentType.COMPANION: [
                "feel", "think", "worry", "stress", "decision", "help me",
                "what should i", "advice", "talk", "chat", "friend",
                "support", "encourage", "celebrate"
            ]
        }

        # Score each agent
        scores = {agent: 0 for agent in AgentType}

        for agent, keywords in routing_keywords.items():
            for keyword in keywords:
                if keyword in message_lower:
                    scores[agent] += 1

        # Get agent with highest score
        best_agent = max(scores, key=scores.get)

        # If no clear winner (tie or zero), default to ATLAS
        if scores[best_agent] == 0 or list(scores.values()).count(scores[best_agent]) > 1:
            best_agent = AgentType.ATLAS

        logger.info(f"Routed message to {best_agent.value} (scores: {scores})")

        return await self.chat(
            best_agent.value,
            message,
            conversation_id=conversation_id
        )

    def clear_history(self, agent_name: Optional[str] = None):
        """
        Clear conversation history

        Args:
            agent_name: Specific agent to clear, or None to clear all
        """
        if agent_name:
            if is_valid_agent(agent_name):
                self.conversation_history[AgentType(agent_name.lower())] = []
                logger.info(f"Cleared history for {agent_name}")
        else:
            for agent in AgentType:
                self.conversation_history[agent] = []
            logger.info("Cleared all conversation history")

    def get_history(self, agent_name: str) -> List[Dict[str, str]]:
        """
        Get conversation history for an agent

        Args:
            agent_name: Name of the agent

        Returns:
            List of messages (dicts with 'role' and 'content')
        """
        if not is_valid_agent(agent_name):
            return []

        return self.conversation_history[AgentType(agent_name.lower())]

    def set_game_state(self, game_state: Dict[str, Any]):
        """
        Update game state (used for function calling)

        Args:
            game_state: New game state dictionary
        """
        self.game_state = game_state
        logger.debug("Game state updated")

    def get_available_agents(self) -> List[Dict[str, str]]:
        """
        Get list of available agents

        Returns:
            List of agent info dictionaries
        """
        return [
            {
                "name": AgentType.ATLAS,
                "description": "Ship's computer - Operational tasks and system management",
                "capabilities": ["status_reports", "system_upgrades", "function_calling"]
            },
            {
                "name": AgentType.STORYTELLER,
                "description": "Narrative engine - Mission generation and story content",
                "capabilities": ["mission_generation", "npc_dialogue", "story_events"]
            },
            {
                "name": AgentType.TACTICAL,
                "description": "Combat advisor - Tactical analysis and strategy",
                "capabilities": ["threat_assessment", "tactical_recommendations", "risk_analysis"]
            },
            {
                "name": AgentType.COMPANION,
                "description": "Personal AI - Emotional support and casual conversation",
                "capabilities": ["emotional_support", "personal_advice", "casual_chat"]
            }
        ]

    def get_available_functions(self) -> List[Dict[str, Any]]:
        """
        Get list of available functions

        Returns:
            List of function definitions
        """
        from .functions import FUNCTION_DEFINITIONS
        return FUNCTION_DEFINITIONS

    async def health_check(self) -> Dict[str, Any]:
        """
        Check health of orchestrator and providers

        Returns:
            Health check results
        """
        health_status = {
            "orchestrator": "healthy",
            "providers": {},
            "agents": {},
            "functions_available": len(FUNCTION_REGISTRY)
        }

        # Test each agent's provider
        for agent in AgentType:
            try:
                model = self.config.get_model_for_agent(agent.value)
                health_status["agents"][agent.value] = {
                    "status": "configured",
                    "model": model
                }

                # Extract provider from model string
                if "/" in model:
                    provider = model.split("/")[0]
                else:
                    provider = "openai"

                if provider not in health_status["providers"]:
                    health_status["providers"][provider] = "available"

            except Exception as e:
                health_status["agents"][agent.value] = {
                    "status": "error",
                    "error": str(e)
                }

        return health_status


# =============================================================================
# GLOBAL ORCHESTRATOR INSTANCE
# =============================================================================

_orchestrator: Optional[AIOrchestrator] = None


def get_orchestrator(game_state: Optional[Dict[str, Any]] = None) -> AIOrchestrator:
    """
    Get or create global orchestrator instance

    Args:
        game_state: Optional game state to set

    Returns:
        AIOrchestrator instance
    """
    global _orchestrator
    if _orchestrator is None:
        _orchestrator = AIOrchestrator(game_state=game_state)
    elif game_state is not None:
        _orchestrator.set_game_state(game_state)
    return _orchestrator


def reset_orchestrator():
    """Reset global orchestrator (for testing)"""
    global _orchestrator
    _orchestrator = None

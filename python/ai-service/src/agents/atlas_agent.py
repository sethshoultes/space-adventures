"""
ATLAS Autonomous Agent

Ship's computer AI that autonomously monitors game state and provides
unsolicited interjections using LangGraph's ReAct pattern.
"""

from typing import Dict, List, Any, Optional, TypedDict, Annotated
from langgraph.graph import StateGraph, END
import redis.asyncio as redis
import json
from datetime import datetime

from .base import BaseAgent
from .tools import (
    get_system_status,
    check_mission_progress,
    scan_environment,
    TOOL_SCHEMAS,
    TOOL_FUNCTIONS
)


# Agent State Type
class AgentState(TypedDict):
    """State passed through the LangGraph workflow"""
    game_state: Dict[str, Any]          # Current game state
    observations: List[str]              # What the agent observed
    reasoning: Optional[str]             # Why agent decided to act
    actions: List[Dict[str, Any]]        # Tools executed
    tool_results: List[Dict[str, Any]]   # Results from tools
    reflection: Optional[Dict[str, Any]] # Is this important?
    message: Optional[str]               # Final message (or None)
    metadata: Dict[str, Any]             # Timestamps, urgency, etc.


class ATLASAgent(BaseAgent):
    """
    ATLAS - Autonomous ship's computer

    Uses LangGraph ReAct loop:
    1. Observe - Analyze game state
    2. Reason - Decide if action needed
    3. Act - Run tools if necessary
    4. Reflect - Determine importance
    5. Communicate - Generate message or None
    """

    def __init__(
        self,
        redis_client: redis.Redis,
        llm_client: Any,  # LiteLLM client
        min_message_interval: int = 60,
        max_messages_per_hour: int = 30
    ):
        """
        Initialize ATLAS agent

        Args:
            redis_client: Redis client for memory
            llm_client: LLM client (LiteLLM)
            min_message_interval: Minimum seconds between messages
            max_messages_per_hour: Maximum messages per hour
        """
        super().__init__(
            agent_name="atlas",
            redis_client=redis_client,
            min_message_interval=min_message_interval,
            max_messages_per_hour=max_messages_per_hour
        )
        self.llm_client = llm_client
        self.workflow = self._build_workflow()

    def _build_workflow(self) -> StateGraph:
        """Build the LangGraph workflow"""

        workflow = StateGraph(AgentState)

        # Add nodes
        workflow.add_node("observe", self._observe_node)
        workflow.add_node("reason", self._reason_node)
        workflow.add_node("act", self._act_node)
        workflow.add_node("reflect", self._reflect_node)
        workflow.add_node("communicate", self._communicate_node)

        # Define flow
        workflow.set_entry_point("observe")
        workflow.add_edge("observe", "reason")

        # Conditional: reason -> act or END
        workflow.add_conditional_edges(
            "reason",
            self._should_act,
            {
                True: "act",
                False: END
            }
        )

        workflow.add_edge("act", "reflect")

        # Conditional: reflect -> communicate or END
        workflow.add_conditional_edges(
            "reflect",
            self._should_communicate,
            {
                True: "communicate",
                False: END
            }
        )

        workflow.add_edge("communicate", END)

        return workflow.compile()

    async def _observe_node(self, state: AgentState) -> AgentState:
        """
        Node 1: Observe the game state

        Analyzes current game state and generates high-level observations.
        """
        game_state = state["game_state"]
        observations = []

        # Quick analysis
        ship = game_state.get("ship", {})
        hull_hp = ship.get("hull_hp", 0)
        max_hull = ship.get("max_hull_hp", 100)
        hull_pct = (hull_hp / max_hull * 100) if max_hull > 0 else 0

        power_avail = ship.get("power_available", 0)
        power_total = ship.get("power_total", 0)

        mission = game_state.get("mission", {})

        # Generate observations
        observations.append(f"Hull integrity: {hull_pct:.0f}%")
        observations.append(f"Power available: {power_avail}/{power_total}")

        if mission:
            observations.append(f"Mission active: {mission.get('title', 'Unknown')}")
        else:
            observations.append("No active mission")

        # Store observation in memory
        obs_text = " | ".join(observations)
        await self.store_observation(obs_text)

        state["observations"] = observations
        state["metadata"] = {
            "timestamp": datetime.now().isoformat(),
            "urgency": "INFO"
        }

        return state

    async def _reason_node(self, state: AgentState) -> AgentState:
        """
        Node 2: Reason about whether to act

        Determines if the current state requires investigation.
        """
        observations = state["observations"]
        recent_obs = await self.get_recent_observations(limit=3)

        # Simple heuristic reasoning (could use LLM for complex reasoning)
        should_investigate = False
        reasoning = "All systems nominal"

        # Check for hull damage
        hull_obs = [o for o in observations if "Hull" in o]
        if hull_obs:
            hull_text = hull_obs[0]
            if "Hull integrity:" in hull_text:
                hull_pct = float(hull_text.split(":")[1].strip().replace("%", ""))
                if hull_pct < 75:
                    should_investigate = True
                    reasoning = f"Hull below 75% ({hull_pct:.0f}%) - investigating"

        # Check for low power
        power_obs = [o for o in observations if "Power" in o]
        if power_obs and not should_investigate:
            power_text = power_obs[0]
            if "/" in power_text:
                parts = power_text.split(":")[1].strip().split("/")
                if len(parts) == 2:
                    avail = float(parts[0])
                    total = float(parts[1])
                    if total > 0 and (avail / total) < 0.3:
                        should_investigate = True
                        reasoning = "Power reserves low - investigating"

        # Check if mission just started (different from recent observations)
        mission_obs = [o for o in observations if "Mission active" in o]
        if mission_obs and not should_investigate:
            current_mission = mission_obs[0]
            # If no recent observations mention this mission, it might be new
            if not any(current_mission in obs for obs in recent_obs):
                should_investigate = True
                reasoning = "New mission detected - reviewing objectives"

        state["reasoning"] = reasoning
        state["metadata"]["should_investigate"] = should_investigate

        return state

    def _should_act(self, state: AgentState) -> bool:
        """Conditional edge: should we execute tools?"""
        return state["metadata"].get("should_investigate", False)

    async def _act_node(self, state: AgentState) -> AgentState:
        """
        Node 3: Act - Execute tools to gather more information

        Runs appropriate tools based on what we're investigating.
        """
        game_state = state["game_state"]
        reasoning = state.get("reasoning", "")
        actions = []
        tool_results = []

        # Determine which tools to run based on reasoning
        if "hull" in reasoning.lower() or "power" in reasoning.lower():
            # Run system status check
            result = await get_system_status(game_state)
            actions.append({"tool": "get_system_status", "reason": "Check system health"})
            tool_results.append({"tool": "get_system_status", "result": result})

        if "mission" in reasoning.lower():
            # Run mission progress check
            result = await check_mission_progress(game_state)
            actions.append({"tool": "check_mission_progress", "reason": "Review mission status"})
            tool_results.append({"tool": "check_mission_progress", "result": result})

        # Store actions in memory
        for action in actions:
            await self.store_action(action)

        state["actions"] = actions
        state["tool_results"] = tool_results

        return state

    async def _reflect_node(self, state: AgentState) -> AgentState:
        """
        Node 4: Reflect - Determine if findings are important enough to report

        Analyzes tool results to decide if a message should be generated.
        """
        tool_results = state.get("tool_results", [])
        should_report = False
        urgency = "INFO"
        reflection = {"important": False, "reason": "No significant findings"}

        # Analyze system status results
        for result_item in tool_results:
            if result_item["tool"] == "get_system_status":
                result = result_item["result"]
                issues = result.get("issues", [])

                if issues:
                    should_report = True
                    reflection["important"] = True
                    reflection["reason"] = f"Detected {len(issues)} system issues"

                    # Determine urgency
                    hull_status = result.get("hull", {}).get("status", "nominal")
                    power_status = result.get("power", {}).get("status", "nominal")

                    if hull_status == "critical" or power_status == "critical":
                        urgency = "CRITICAL"
                    elif hull_status == "damaged" or power_status == "low":
                        urgency = "MEDIUM"
                    else:
                        urgency = "INFO"

            elif result_item["tool"] == "check_mission_progress":
                result = result_item["result"]
                if result.get("mission_active"):
                    # Report on new missions
                    should_report = True
                    reflection["important"] = True
                    reflection["reason"] = "Mission briefing available"
                    urgency = "INFO"

        state["reflection"] = reflection
        state["metadata"]["urgency"] = urgency
        state["metadata"]["should_report"] = should_report

        return state

    def _should_communicate(self, state: AgentState) -> bool:
        """Conditional edge: should we generate a message?"""
        return state["metadata"].get("should_report", False)

    async def _communicate_node(self, state: AgentState) -> AgentState:
        """
        Node 5: Communicate - Generate message for the player

        Creates a concise, professional message based on findings.
        """
        tool_results = state.get("tool_results", [])
        urgency = state["metadata"].get("urgency", "INFO")

        # Build message from tool results
        message_parts = []

        for result_item in tool_results:
            if result_item["tool"] == "get_system_status":
                result = result_item["result"]
                issues = result.get("issues", [])

                if issues:
                    message_parts.append("Captain, system diagnostics report:")
                    # Limit to top 3 issues
                    for issue in issues[:3]:
                        message_parts.append(f"- {issue}")

                    if len(issues) > 3:
                        message_parts.append(f"- ...and {len(issues) - 3} additional issues")

            elif result_item["tool"] == "check_mission_progress":
                result = result_item["result"]
                if result.get("mission_active"):
                    title = result.get("mission_title", "Unknown Mission")
                    message_parts.append(f"Mission briefing available: {title}")

                    objectives = result.get("objectives", [])
                    if objectives:
                        message_parts.append("Objectives:")
                        for obj in objectives[:3]:
                            status = "✓" if obj.get("completed") else "○"
                            message_parts.append(f"{status} {obj.get('text')}")

        # Combine message
        message = "\n".join(message_parts) if message_parts else None

        # Add urgency prefix for critical messages
        if message and urgency == "CRITICAL":
            message = f"⚠️ ALERT: {message}"
        elif message and urgency == "MEDIUM":
            message = f"⚠ NOTICE: {message}"

        state["message"] = message

        # Record message if generated
        if message:
            await self.record_message()

        return state

    def get_available_tools(self) -> List[Dict[str, Any]]:
        """Get list of tools available to ATLAS"""
        return TOOL_SCHEMAS

    async def run(
        self,
        game_state: Dict[str, Any],
        force_check: bool = False
    ) -> Dict[str, Any]:
        """
        Main entry point - run the ATLAS agent

        Args:
            game_state: Current game state
            force_check: Bypass throttling (for testing)

        Returns:
            Dictionary with agent response
        """
        # Check throttling (unless forced)
        if not force_check:
            throttled = not await self.check_throttle()
            if throttled:
                return {
                    "should_act": False,
                    "message": None,
                    "reasoning": "Throttled - too soon since last message",
                    "next_check_in": self.min_message_interval,
                    "urgency": "INFO",
                    "tools_used": []
                }

        # Initialize state
        initial_state: AgentState = {
            "game_state": game_state,
            "observations": [],
            "reasoning": None,
            "actions": [],
            "tool_results": [],
            "reflection": None,
            "message": None,
            "metadata": {}
        }

        # Run workflow
        final_state = await self.workflow.ainvoke(initial_state)

        # Build response
        tools_used = [action["tool"] for action in final_state.get("actions", [])]

        return {
            "should_act": bool(final_state.get("message")),
            "message": final_state.get("message"),
            "urgency": final_state["metadata"].get("urgency", "INFO"),
            "tools_used": tools_used,
            "reasoning": final_state.get("reasoning", "No action needed"),
            "next_check_in": 45  # Recommend checking again in 45 seconds
        }

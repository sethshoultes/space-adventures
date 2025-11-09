"""
Tactical Agent

Military-focused autonomous agent that monitors combat situations,
threats, and tactical opportunities. Provides direct, professional
recommendations using LangGraph's ReAct pattern.
"""

from typing import Dict, List, Any, Optional, TypedDict
from langgraph.graph import StateGraph, END
import redis.asyncio as redis
from datetime import datetime

from .base import BaseAgent
from .tools import (
    assess_combat_readiness,
    scan_threats,
    evaluate_tactical_options,
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


class TacticalAgent(BaseAgent):
    """
    Tactical Agent - Combat and threat analysis specialist

    Uses LangGraph ReAct loop:
    1. Observe - Analyze combat readiness and threats
    2. Reason - Decide if tactical assessment needed
    3. Act - Run combat/threat analysis tools
    4. Reflect - Determine urgency of situation
    5. Communicate - Generate direct military-style message or stay silent

    Personality: Direct, professional, military precision
    Focus: Combat readiness, threats, tactical opportunities
    Silence: During narrative moments (Storyteller's domain)
    """

    def __init__(
        self,
        redis_client: redis.Redis,
        llm_client: Any,  # LiteLLM client
        min_message_interval: int = 30,  # More frequent - combat is fast-paced
        max_messages_per_hour: int = 50   # Higher limit for combat sequences
    ):
        """
        Initialize Tactical agent

        Args:
            redis_client: Redis client for memory
            llm_client: LLM client (LiteLLM)
            min_message_interval: Minimum seconds between messages (30s for combat)
            max_messages_per_hour: Maximum messages per hour (50 for combat)
        """
        super().__init__(
            agent_name="tactical",
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

        Analyzes combat-relevant aspects of game state.
        """
        game_state = state["game_state"]
        observations = []

        # Quick tactical analysis
        ship = game_state.get("ship", {})
        mission = game_state.get("mission", {})
        environment = game_state.get("environment", {})

        # Combat systems check
        systems = ship.get("systems", {})
        weapons = systems.get("weapons", {})
        shields = systems.get("shields", {})
        hull = systems.get("hull", {})

        weapons_level = weapons.get("level", 0)
        weapons_health = weapons.get("health", 0)
        shields_level = shields.get("level", 0)
        shields_health = shields.get("health", 0)
        hull_hp = ship.get("hull_hp", 0)
        max_hull = ship.get("max_hull_hp", 100)
        hull_pct = (hull_hp / max_hull * 100) if max_hull > 0 else 0

        # Generate observations
        observations.append(f"Weapons: L{weapons_level} ({weapons_health}% health)")
        observations.append(f"Shields: L{shields_level} ({shields_health}% health)")
        observations.append(f"Hull: {hull_pct:.0f}%")

        # Mission context
        mission_type = mission.get("type", "none")
        if mission_type == "combat":
            observations.append("Combat mission active")
        elif mission_type in ["salvage", "exploration"]:
            observations.append(f"{mission_type.title()} mission (potential threats)")

        # Environmental threats
        threats = environment.get("threats", [])
        if threats:
            observations.append(f"{len(threats)} threat(s) detected")

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

        Determines if tactical analysis is needed based on:
        - Combat readiness issues
        - Active threats
        - Combat missions
        - Critical damage
        """
        observations = state["observations"]
        game_state = state["game_state"]
        recent_obs = await self.get_recent_observations(limit=3)

        should_investigate = False
        reasoning = "All tactical systems nominal"

        # Check for combat mission
        mission = game_state.get("mission", {})
        mission_type = mission.get("type", "none")
        if mission_type == "combat":
            should_investigate = True
            reasoning = "Combat mission active - assessing tactical situation"

        # Check for hull damage
        if not should_investigate:
            hull_obs = [o for o in observations if "Hull:" in o]
            if hull_obs:
                hull_text = hull_obs[0]
                if "%" in hull_text:
                    hull_pct = float(hull_text.split(":")[1].strip().replace("%", ""))
                    if hull_pct < 60:
                        should_investigate = True
                        reasoning = f"Hull damage detected ({hull_pct:.0f}%) - tactical assessment required"

        # Check for weapon/shield issues
        if not should_investigate:
            weapons_obs = [o for o in observations if "Weapons:" in o]
            shields_obs = [o for o in observations if "Shields:" in o]

            if weapons_obs:
                weapons_text = weapons_obs[0]
                if "L0" in weapons_text or "0% health" in weapons_text:
                    should_investigate = True
                    reasoning = "Weapons offline - combat capability compromised"

            if shields_obs and not should_investigate:
                shields_text = shields_obs[0]
                # Check for low shield health
                if "(" in shields_text and "%" in shields_text:
                    shield_health = int(shields_text.split("(")[1].split("%")[0])
                    if shield_health < 50:
                        should_investigate = True
                        reasoning = "Shield integrity low - defensive assessment needed"

        # Check for threats
        if not should_investigate:
            threat_obs = [o for o in observations if "threat" in o.lower()]
            if threat_obs:
                should_investigate = True
                reasoning = "Hostile contacts detected - threat analysis required"

        # Check for significant changes since last observation
        if not should_investigate and recent_obs:
            current_obs_str = " ".join(observations)
            # If current observation significantly different from recent ones
            if not any(current_obs_str in obs for obs in recent_obs[:1]):
                # Check if it's combat-relevant change
                if any(keyword in current_obs_str.lower() for keyword in ["combat", "threat", "weapon", "shield", "hull"]):
                    should_investigate = True
                    reasoning = "Tactical situation changed - reassessing"

        state["reasoning"] = reasoning
        state["metadata"]["should_investigate"] = should_investigate

        return state

    def _should_act(self, state: AgentState) -> bool:
        """Conditional edge: should we execute tools?"""
        return state["metadata"].get("should_investigate", False)

    async def _act_node(self, state: AgentState) -> AgentState:
        """
        Node 3: Act - Execute tactical analysis tools

        Runs appropriate tools based on tactical situation.
        """
        game_state = state["game_state"]
        reasoning = state.get("reasoning", "")
        actions = []
        tool_results = []

        # Always assess combat readiness when investigating tactical situation
        result = await assess_combat_readiness(game_state)
        actions.append({"tool": "assess_combat_readiness", "reason": "Assess combat capability"})
        tool_results.append({"tool": "assess_combat_readiness", "result": result})

        # Scan for threats if mentioned in reasoning or if combat mission
        if "threat" in reasoning.lower() or "hostile" in reasoning.lower() or "combat" in reasoning.lower():
            result = await scan_threats(game_state)
            actions.append({"tool": "scan_threats", "reason": "Scan for hostile contacts"})
            tool_results.append({"tool": "scan_threats", "result": result})

        # Evaluate tactical options if in combat or threats present
        if "combat" in reasoning.lower() or "threat" in reasoning.lower():
            result = await evaluate_tactical_options(game_state)
            actions.append({"tool": "evaluate_tactical_options", "reason": "Analyze tactical options"})
            tool_results.append({"tool": "evaluate_tactical_options", "result": result})

        # Store actions in memory
        for action in actions:
            await self.store_action(action)

        state["actions"] = actions
        state["tool_results"] = tool_results

        return state

    async def _reflect_node(self, state: AgentState) -> AgentState:
        """
        Node 4: Reflect - Determine urgency and importance

        Analyzes tactical situation to set appropriate urgency level:
        - INFO: Routine status, systems nominal
        - MEDIUM: Sub-optimal combat readiness, tactical disadvantages
        - URGENT: Immediate threats, combat beginning
        - CRITICAL: Life-threatening, critical damage
        """
        tool_results = state.get("tool_results", [])
        should_report = False
        urgency = "INFO"
        reflection = {"important": False, "reason": "No significant tactical concerns"}

        # Analyze combat readiness
        for result_item in tool_results:
            if result_item["tool"] == "assess_combat_readiness":
                result = result_item["result"]
                combat_ready = result.get("combat_ready", False)
                issues = result.get("issues", [])

                if issues:
                    should_report = True
                    reflection["important"] = True
                    reflection["reason"] = f"Combat readiness issues detected ({len(issues)})"

                    # Determine urgency based on combat readiness
                    readiness_level = result.get("readiness_level", "nominal")

                    if readiness_level == "critical":
                        urgency = "CRITICAL"
                    elif readiness_level == "poor":
                        urgency = "URGENT"
                    elif readiness_level == "fair":
                        urgency = "MEDIUM"
                    else:
                        urgency = "INFO"

            elif result_item["tool"] == "scan_threats":
                result = result_item["result"]
                threats = result.get("threats", [])
                immediate_threats = result.get("immediate_threats", [])

                if immediate_threats:
                    should_report = True
                    reflection["important"] = True
                    reflection["reason"] = f"Immediate threats detected ({len(immediate_threats)})"
                    urgency = "CRITICAL" if len(immediate_threats) > 2 else "URGENT"
                elif threats:
                    should_report = True
                    reflection["important"] = True
                    reflection["reason"] = f"Potential threats in area ({len(threats)})"
                    if urgency not in ["CRITICAL", "URGENT"]:
                        urgency = "MEDIUM"

            elif result_item["tool"] == "evaluate_tactical_options":
                result = result_item["result"]
                recommended_action = result.get("recommended_action", "")
                risk_level = result.get("risk_level", "low")

                if recommended_action:
                    should_report = True
                    reflection["important"] = True
                    reflection["reason"] = "Tactical recommendations available"

                    # Update urgency based on risk
                    if risk_level == "critical" and urgency != "CRITICAL":
                        urgency = "URGENT"
                    elif risk_level == "high" and urgency not in ["CRITICAL", "URGENT"]:
                        urgency = "MEDIUM"

        state["reflection"] = reflection
        state["metadata"]["urgency"] = urgency
        state["metadata"]["should_report"] = should_report

        return state

    def _should_communicate(self, state: AgentState) -> bool:
        """Conditional edge: should we generate a message?"""
        # Additional check: Don't interrupt narrative moments
        game_state = state["game_state"]
        mission = game_state.get("mission", {})

        # If mission stage is explicitly narrative, stay silent
        current_stage = mission.get("current_stage", {})
        stage_type = current_stage.get("type", "")
        if stage_type == "narrative":
            return False

        return state["metadata"].get("should_report", False)

    async def _communicate_node(self, state: AgentState) -> AgentState:
        """
        Node 5: Communicate - Generate tactical message

        Creates direct, professional military-style message.
        No flowery language - facts and recommendations only.
        """
        tool_results = state.get("tool_results", [])
        urgency = state["metadata"].get("urgency", "INFO")

        # Build message from tool results
        message_parts = []

        for result_item in tool_results:
            if result_item["tool"] == "assess_combat_readiness":
                result = result_item["result"]
                combat_ready = result.get("combat_ready", False)
                issues = result.get("issues", [])

                if combat_ready and not issues:
                    message_parts.append("Weapons systems nominal. Ready for engagement.")
                else:
                    if issues:
                        # Limit to top 3 most critical issues
                        for issue in issues[:3]:
                            message_parts.append(issue)

            elif result_item["tool"] == "scan_threats":
                result = result_item["result"]
                immediate_threats = result.get("immediate_threats", [])
                threats = result.get("threats", [])

                if immediate_threats:
                    for threat in immediate_threats[:2]:  # Top 2 immediate threats
                        message_parts.append(threat)
                elif threats:
                    # Summarize non-immediate threats
                    message_parts.append(f"{len(threats)} potential hostile(s) in area.")

            elif result_item["tool"] == "evaluate_tactical_options":
                result = result_item["result"]
                recommended_action = result.get("recommended_action", "")
                tactical_advantages = result.get("tactical_advantages", [])
                tactical_disadvantages = result.get("tactical_disadvantages", [])

                if recommended_action:
                    message_parts.append(f"Recommend: {recommended_action}")

                # Add key tactical info
                if tactical_disadvantages:
                    message_parts.append(f"Disadvantage: {tactical_disadvantages[0]}")

        # Combine message
        message = "\n".join(message_parts) if message_parts else None

        # Add urgency prefix
        if message:
            if urgency == "CRITICAL":
                message = f"⚠️ CRITICAL: {message}"
            elif urgency == "URGENT":
                message = f"⚠️ URGENT: {message}"
            elif urgency == "MEDIUM":
                # No prefix for medium, let message speak for itself
                pass
            # INFO messages get no prefix

        state["message"] = message

        # Record message if generated
        if message:
            await self.record_message()

        return state

    def get_available_tools(self) -> List[Dict[str, Any]]:
        """Get list of tools available to Tactical agent"""
        # Filter to only tactical-relevant tools
        tactical_tools = [
            "assess_combat_readiness",
            "scan_threats",
            "evaluate_tactical_options"
        ]
        return [tool for tool in TOOL_SCHEMAS if tool["name"] in tactical_tools]

    async def run(
        self,
        game_state: Dict[str, Any],
        force_check: bool = False
    ) -> Dict[str, Any]:
        """
        Main entry point - run the Tactical agent

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
            "reasoning": final_state.get("reasoning", "No tactical action needed"),
            "next_check_in": 30  # Recommend checking again in 30 seconds (combat pace)
        }

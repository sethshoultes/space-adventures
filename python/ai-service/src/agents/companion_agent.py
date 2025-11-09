"""
Companion Autonomous Agent

Empathetic AI companion that monitors crew morale and player emotional state,
providing encouragement, support, and celebrating achievements.
"""

from typing import Dict, List, Any, Optional, TypedDict
from langgraph.graph import StateGraph, END
import redis.asyncio as redis
from datetime import datetime

from .base import BaseAgent
from .tools import (
    check_crew_morale,
    evaluate_player_progress,
    assess_emotional_tone,
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


class CompanionAgent(BaseAgent):
    """
    Companion - Empathetic AI companion

    Uses LangGraph ReAct loop:
    1. Observe - Monitor emotional state and crew morale
    2. Reason - Decide if support/encouragement needed
    3. Act - Evaluate player progress and morale
    4. Reflect - Determine if intervention is helpful
    5. Communicate - Generate supportive message or stay silent
    """

    def __init__(
        self,
        redis_client: redis.Redis,
        llm_client: Any,  # LiteLLM client
        min_message_interval: int = 120,  # Most selective - avoids being annoying
        max_messages_per_hour: int = 15   # Companion is thoughtful, not chatty
    ):
        """
        Initialize Companion agent

        Args:
            redis_client: Redis client for memory
            llm_client: LLM client (LiteLLM)
            min_message_interval: Minimum seconds between messages (120 default)
            max_messages_per_hour: Maximum messages per hour (15 default)
        """
        super().__init__(
            agent_name="companion",
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
        Node 1: Observe the game state for emotional cues

        Analyzes player progress, crew state, and recent events for
        opportunities to provide encouragement or support.
        """
        game_state = state["game_state"]
        observations = []

        # Player state
        player = game_state.get("player", {})
        player_level = player.get("level", 1)
        player_xp = player.get("xp", 0)

        # Progress markers
        progress = game_state.get("progress", {})
        completed_missions = progress.get("completed_missions", [])
        mission_count = len(completed_missions)

        # Current mission state
        mission = game_state.get("mission", {})
        mission_active = bool(mission)

        # Ship state
        ship = game_state.get("ship", {})
        hull_hp = ship.get("hull_hp", 0)
        max_hull = ship.get("max_hull_hp", 100)
        hull_pct = (hull_hp / max_hull * 100) if max_hull > 0 else 0

        # Generate observations
        observations.append(f"Player level: {player_level}, XP: {player_xp}")
        observations.append(f"Completed missions: {mission_count}")

        if mission_active:
            mission_difficulty = mission.get("difficulty", 1)
            observations.append(f"Active mission difficulty: {mission_difficulty}")
        else:
            observations.append("No active mission")

        if hull_pct < 50:
            observations.append(f"Recent damage detected: hull at {hull_pct:.0f}%")

        # Check for recent achievements
        recent_actions = await self.get_recent_actions(limit=3)
        if recent_actions:
            observations.append(f"Recent player actions: {len(recent_actions)}")

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
        Node 2: Reason about whether emotional support is needed

        Determines if the current state suggests player might benefit
        from encouragement, celebration, or emotional support.
        """
        observations = state["observations"]
        recent_obs = await self.get_recent_observations(limit=3)
        game_state = state["game_state"]

        should_check_morale = False
        reasoning = "Player seems engaged and doing well"

        # Check for damage/setbacks
        damage_obs = [o for o in observations if "damage" in o.lower()]
        if damage_obs:
            should_check_morale = True
            reasoning = "Player recently took damage - may need encouragement"

        # Check for high difficulty missions
        difficulty_obs = [o for o in observations if "difficulty:" in o]
        if difficulty_obs and not should_check_morale:
            difficulty_text = difficulty_obs[0]
            if "difficulty: 4" in difficulty_text or "difficulty: 5" in difficulty_text:
                should_check_morale = True
                reasoning = "Player tackling difficult mission - worth acknowledging"

        # Check for milestones (level ups, mission counts)
        level_obs = [o for o in observations if "Player level:" in o]
        if level_obs and not should_check_morale:
            current_level_text = level_obs[0]
            # Compare with recent observations to detect level up
            level_in_recent = any("Player level:" in obs for obs in recent_obs)
            if not level_in_recent:
                # First time seeing this player level - might be new
                should_check_morale = True
                reasoning = "Potential player progress detected - checking achievements"

        # Check for mission completion
        mission_count_obs = [o for o in observations if "Completed missions:" in o]
        if mission_count_obs and not should_check_morale:
            current_count = mission_count_obs[0]
            # Compare with recent observations
            if not any(current_count in obs for obs in recent_obs):
                should_check_morale = True
                reasoning = "Mission completion detected - celebrating player achievement"

        # Check for extended playtime without active mission
        no_mission_obs = [o for o in observations if "No active mission" in o]
        if no_mission_obs and len(recent_obs) >= 2:
            recent_no_mission = sum(1 for obs in recent_obs if "No active mission" in obs)
            if recent_no_mission >= 2 and not should_check_morale:
                # Player has been idle for a while
                should_check_morale = True
                reasoning = "Player between missions - gentle encouragement may help"

        state["reasoning"] = reasoning
        state["metadata"]["should_check_morale"] = should_check_morale

        return state

    def _should_act(self, state: AgentState) -> bool:
        """Conditional edge: should we evaluate morale?"""
        return state["metadata"].get("should_check_morale", False)

    async def _act_node(self, state: AgentState) -> AgentState:
        """
        Node 3: Act - Evaluate player emotional state and progress

        Runs appropriate tools to assess morale, progress, and emotional tone.
        """
        game_state = state["game_state"]
        reasoning = state.get("reasoning", "")
        actions = []
        tool_results = []

        # Always check morale when acting
        morale_result = await check_crew_morale(game_state)
        actions.append({"tool": "check_crew_morale", "reason": "Assess crew emotional state"})
        tool_results.append({"tool": "check_crew_morale", "result": morale_result})

        # Check player progress for achievements
        if "achievement" in reasoning.lower() or "progress" in reasoning.lower() or "mission completion" in reasoning.lower():
            progress_result = await evaluate_player_progress(game_state)
            actions.append({"tool": "evaluate_player_progress", "reason": "Check for achievements"})
            tool_results.append({"tool": "evaluate_player_progress", "result": progress_result})

        # Assess overall emotional tone
        tone_result = await assess_emotional_tone(game_state)
        actions.append({"tool": "assess_emotional_tone", "reason": "Determine emotional support needs"})
        tool_results.append({"tool": "assess_emotional_tone", "result": tone_result})

        # Store actions in memory
        for action in actions:
            await self.store_action(action)

        state["actions"] = actions
        state["tool_results"] = tool_results

        return state

    async def _reflect_node(self, state: AgentState) -> AgentState:
        """
        Node 4: Reflect - Determine if emotional support would be helpful

        Analyzes tool results to decide if a supportive message should be generated.
        """
        tool_results = state.get("tool_results", [])
        should_offer_support = False
        urgency = "INFO"
        reflection = {"important": False, "reason": "No support needed at this time"}

        morale_data = None
        progress_data = None
        tone_data = None

        # Extract tool results
        for result_item in tool_results:
            if result_item["tool"] == "check_crew_morale":
                morale_data = result_item["result"]
            elif result_item["tool"] == "evaluate_player_progress":
                progress_data = result_item["result"]
            elif result_item["tool"] == "assess_emotional_tone":
                tone_data = result_item["result"]

        # Analyze morale
        if morale_data:
            morale_status = morale_data.get("overall_morale", "good")
            crew_losses = morale_data.get("recent_crew_losses", 0)
            mission_failures = morale_data.get("recent_mission_failures", 0)

            if morale_status == "critical" or crew_losses > 2:
                should_offer_support = True
                urgency = "CRITICAL"
                reflection["important"] = True
                reflection["reason"] = "Crew morale critical - player needs encouragement"
            elif morale_status == "low" or mission_failures > 1:
                should_offer_support = True
                urgency = "MEDIUM"
                reflection["important"] = True
                reflection["reason"] = "Morale low after setbacks - offering perspective"
            elif morale_status == "excellent":
                should_offer_support = True
                urgency = "INFO"
                reflection["important"] = True
                reflection["reason"] = "Morale high - acknowledging good leadership"

        # Analyze progress (achievements take priority)
        if progress_data and not should_offer_support:
            achievements = progress_data.get("recent_achievements", [])
            level_up = progress_data.get("recent_level_up", False)
            major_milestone = progress_data.get("major_milestone", False)

            if major_milestone:
                should_offer_support = True
                urgency = "URGENT"
                reflection["important"] = True
                reflection["reason"] = "Major milestone reached - celebration warranted"
            elif level_up or len(achievements) > 0:
                should_offer_support = True
                urgency = "MEDIUM"
                reflection["important"] = True
                reflection["reason"] = "Player achievement detected - recognizing progress"

        # Analyze emotional tone
        if tone_data and not should_offer_support:
            needs_encouragement = tone_data.get("needs_encouragement", False)
            recent_difficulty = tone_data.get("facing_difficult_challenge", False)

            if needs_encouragement:
                should_offer_support = True
                urgency = "MEDIUM"
                reflection["important"] = True
                reflection["reason"] = "Player may benefit from encouragement"
            elif recent_difficulty:
                should_offer_support = True
                urgency = "INFO"
                reflection["important"] = True
                reflection["reason"] = "Player facing challenge - gentle support appropriate"

        state["reflection"] = reflection
        state["metadata"]["urgency"] = urgency
        state["metadata"]["should_offer_support"] = should_offer_support

        return state

    def _should_communicate(self, state: AgentState) -> bool:
        """Conditional edge: should we generate a supportive message?"""
        return state["metadata"].get("should_offer_support", False)

    async def _communicate_node(self, state: AgentState) -> AgentState:
        """
        Node 5: Communicate - Generate supportive message for the player

        Creates warm, empathetic message based on emotional assessment.
        """
        tool_results = state.get("tool_results", [])
        urgency = state["metadata"].get("urgency", "INFO")
        message_parts = []

        morale_data = None
        progress_data = None
        tone_data = None

        # Extract tool results
        for result_item in tool_results:
            if result_item["tool"] == "check_crew_morale":
                morale_data = result_item["result"]
            elif result_item["tool"] == "evaluate_player_progress":
                progress_data = result_item["result"]
            elif result_item["tool"] == "assess_emotional_tone":
                tone_data = result_item["result"]

        # Build message based on situation
        if urgency == "CRITICAL":
            # Player struggling - strong encouragement
            if morale_data:
                message_parts.append("I know things have been difficult.")
                crew_losses = morale_data.get("recent_crew_losses", 0)
                if crew_losses > 0:
                    message_parts.append("Every loss weighs heavy. But you're still here, still fighting.")
                message_parts.append("I believe in you. We all do. You can do this.")

        elif urgency == "URGENT":
            # Major achievement
            if progress_data:
                milestone = progress_data.get("milestone_name", "")
                if milestone:
                    message_parts.append(f"Captain, you've accomplished something remarkable: {milestone}")
                else:
                    message_parts.append("You've accomplished something remarkable.")
                message_parts.append("Take a moment to appreciate how far you've come.")

        elif urgency == "MEDIUM":
            # Moderate support/recognition needed
            if morale_data and morale_data.get("overall_morale") == "low":
                message_parts.append("I know that last mission was rough.")
                message_parts.append("But you made the right call. The crew trusts your judgment.")
            elif progress_data:
                achievements = progress_data.get("recent_achievements", [])
                level_up = progress_data.get("recent_level_up", False)
                if level_up:
                    new_level = progress_data.get("current_level", 0)
                    message_parts.append(f"Level {new_level}. Your experience is showing, captain.")
                elif achievements:
                    message_parts.append(f"Noticed you {achievements[0]}. Well done.")

        elif urgency == "INFO":
            # Gentle encouragement or observation
            if morale_data and morale_data.get("overall_morale") == "excellent":
                message_parts.append("The crew seems in good spirits today.")
                message_parts.append("Your leadership is showing.")
            elif tone_data and tone_data.get("facing_difficult_challenge"):
                message_parts.append("This one's challenging, I know.")
                message_parts.append("Take your time. You've handled worse.")
            elif tone_data and tone_data.get("needs_encouragement"):
                message_parts.append("You're doing fine, captain.")
                message_parts.append("One step at a time.")

        # Combine message
        message = " ".join(message_parts) if message_parts else None

        state["message"] = message

        # Record message if generated
        if message:
            await self.record_message()

        return state

    def get_available_tools(self) -> List[Dict[str, Any]]:
        """Get list of tools available to Companion"""
        return [
            schema for schema in TOOL_SCHEMAS
            if schema["name"] in ["check_crew_morale", "evaluate_player_progress", "assess_emotional_tone"]
        ]

    async def run(
        self,
        game_state: Dict[str, Any],
        force_check: bool = False
    ) -> Dict[str, Any]:
        """
        Main entry point - run the Companion agent

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
            "reasoning": final_state.get("reasoning", "No support needed at this time"),
            "next_check_in": 120  # Recommend checking again in 2 minutes
        }

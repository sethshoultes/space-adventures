"""
Storyteller Autonomous Agent

Creative narrative AI that monitors for story opportunities, character development
moments, and atmospheric descriptions using LangGraph's ReAct pattern.
"""

from typing import Dict, List, Any, Optional, TypedDict, Annotated
from langgraph.graph import StateGraph, END
import redis.asyncio as redis
import json
from datetime import datetime

from .base import BaseAgent
from .tools import (
    analyze_narrative_context,
    check_character_development,
    evaluate_atmosphere,
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


class StorytellerAgent(BaseAgent):
    """
    Storyteller - Creative narrative AI

    Uses LangGraph ReAct loop:
    1. Observe - Analyze game state for narrative opportunities
    2. Reason - Decide if story moment exists
    3. Act - Run narrative analysis tools
    4. Reflect - Determine if moment is meaningful
    5. Communicate - Generate evocative message or stay silent
    """

    def __init__(
        self,
        redis_client: redis.Redis,
        llm_client: Any,  # LiteLLM client
        min_message_interval: int = 90,
        max_messages_per_hour: int = 20
    ):
        """
        Initialize Storyteller agent

        Args:
            redis_client: Redis client for memory
            llm_client: LLM client (LiteLLM)
            min_message_interval: Minimum seconds between messages (90s - more selective)
            max_messages_per_hour: Maximum messages per hour (20 - less frequent than ATLAS)
        """
        super().__init__(
            agent_name="storyteller",
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
        Node 1: Observe the game state for narrative opportunities

        Analyzes current game state through a storytelling lens.
        """
        game_state = state["game_state"]
        observations = []

        # Quick narrative analysis
        progress = game_state.get("progress", {})
        mission = game_state.get("mission", {})
        player = game_state.get("player", {})

        # Mission context
        if mission:
            mission_title = mission.get("title", "Unknown")
            mission_type = mission.get("type", "unknown")
            mission_stage = mission.get("stage", "unknown")

            observations.append(f"Mission: {mission_title} ({mission_type})")
            observations.append(f"Stage: {mission_stage}")
        else:
            observations.append("Between missions")

        # Player journey
        completed_missions = progress.get("completed_missions", [])
        mission_count = len(completed_missions) if isinstance(completed_missions, list) else 0
        player_level = player.get("level", 1)

        observations.append(f"Journey: Level {player_level}, {mission_count} missions")

        # Location/atmosphere
        environment = game_state.get("environment", {})
        location = environment.get("location") or mission.get("location", "Unknown")
        observations.append(f"Location: {location}")

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
        Node 2: Reason about whether a narrative moment exists

        Determines if the current state warrants deeper narrative analysis.
        """
        observations = state["observations"]
        game_state = state["game_state"]
        recent_obs = await self.get_recent_observations(limit=3)

        should_investigate = False
        reasoning = "No significant narrative moment detected"

        # Check for mission events
        mission = game_state.get("mission", {})
        if mission:
            mission_stage = mission.get("stage", "unknown")
            mission_type = mission.get("type", "unknown")

            # Story missions are always worth investigating
            if mission_type == "story":
                should_investigate = True
                reasoning = "Story mission active - narrative opportunity"

            # Mission completion is a good narrative moment
            if mission_stage == "complete" or "complete" in mission_stage.lower():
                should_investigate = True
                reasoning = "Mission completion - reflect on achievement"

        # Check for character development opportunities
        player = game_state.get("player", {})
        player_level = player.get("level", 1)
        player_xp = player.get("xp", 0)

        # Just leveled up (low XP in current level)
        if player_level > 1 and player_xp < 50 and not should_investigate:
            should_investigate = True
            reasoning = "Player level up - character growth moment"

        # Mission milestones
        progress = game_state.get("progress", {})
        completed_missions = progress.get("completed_missions", [])
        mission_count = len(completed_missions) if isinstance(completed_missions, list) else 0

        if mission_count > 0 and mission_count % 5 == 0 and not should_investigate:
            # Check if we haven't already commented on this milestone
            milestone_obs = f"{mission_count} missions"
            if not any(milestone_obs in obs for obs in recent_obs):
                should_investigate = True
                reasoning = f"Milestone reached: {mission_count} missions completed"

        # Exploration moments
        discovered_locations = progress.get("discovered_locations", [])
        if len(discovered_locations) > 0 and len(discovered_locations) % 3 == 0 and not should_investigate:
            location_milestone = f"{len(discovered_locations)} locations"
            if not any(location_milestone in obs for obs in recent_obs):
                should_investigate = True
                reasoning = "Explorer's milestone - new discoveries"

        # Significant time passing (between missions)
        if not mission and mission_count > 0 and not should_investigate:
            # Quiet moment for atmospheric description
            should_investigate = True
            reasoning = "Quiet moment - opportunity for atmospheric reflection"

        state["reasoning"] = reasoning
        state["metadata"]["should_investigate"] = should_investigate

        return state

    def _should_act(self, state: AgentState) -> bool:
        """Conditional edge: should we execute tools?"""
        return state["metadata"].get("should_investigate", False)

    async def _act_node(self, state: AgentState) -> AgentState:
        """
        Node 3: Act - Execute narrative analysis tools

        Runs storytelling-focused tools to gather narrative context.
        """
        game_state = state["game_state"]
        reasoning = state.get("reasoning", "")
        actions = []
        tool_results = []

        # Always analyze narrative context for story opportunities
        result = await analyze_narrative_context(game_state)
        actions.append({"tool": "analyze_narrative_context", "reason": "Identify story opportunities"})
        tool_results.append({"tool": "analyze_narrative_context", "result": result})

        # Check for character development moments
        if "level" in reasoning.lower() or "milestone" in reasoning.lower() or "growth" in reasoning.lower():
            result = await check_character_development(game_state)
            actions.append({"tool": "check_character_development", "reason": "Assess character progression"})
            tool_results.append({"tool": "check_character_development", "result": result})

        # Evaluate atmosphere for descriptive opportunities
        if "mission" in reasoning.lower() or "quiet" in reasoning.lower() or "atmospheric" in reasoning.lower():
            result = await evaluate_atmosphere(game_state)
            actions.append({"tool": "evaluate_atmosphere", "reason": "Assess scene atmosphere"})
            tool_results.append({"tool": "evaluate_atmosphere", "result": result})

        # Store actions in memory
        for action in actions:
            await self.store_action(action)

        state["actions"] = actions
        state["tool_results"] = tool_results

        return state

    async def _reflect_node(self, state: AgentState) -> AgentState:
        """
        Node 4: Reflect - Determine if narrative moment is meaningful

        Analyzes narrative findings to decide if a message should be generated.
        """
        tool_results = state.get("tool_results", [])
        should_report = False
        urgency = "INFO"
        reflection = {"important": False, "reason": "No meaningful narrative moment"}

        narrative_data = None
        character_data = None
        atmosphere_data = None

        # Extract tool results
        for result_item in tool_results:
            if result_item["tool"] == "analyze_narrative_context":
                narrative_data = result_item["result"]
            elif result_item["tool"] == "check_character_development":
                character_data = result_item["result"]
            elif result_item["tool"] == "evaluate_atmosphere":
                atmosphere_data = result_item["result"]

        # Check narrative opportunities
        if narrative_data:
            story_opportunities = narrative_data.get("story_opportunities", [])
            narrative_themes = narrative_data.get("narrative_themes", [])

            if story_opportunities:
                should_report = True
                reflection["important"] = True
                reflection["reason"] = f"Narrative opportunity: {story_opportunities[0]}"
                urgency = "MEDIUM"

            # Major thematic moments
            if len(narrative_themes) >= 2:
                should_report = True
                reflection["important"] = True
                reflection["reason"] = f"Multiple narrative themes converging"
                urgency = "MEDIUM"

        # Check character development
        if character_data:
            if character_data.get("character_moment_opportunity"):
                should_report = True
                reflection["important"] = True
                moment_reason = character_data.get("moment_reason", "Character development")
                reflection["reason"] = moment_reason
                urgency = "MEDIUM"

        # Check atmosphere for critical moments
        if atmosphere_data:
            tension_level = atmosphere_data.get("tension_level", 0)
            descriptive_opportunities = atmosphere_data.get("descriptive_opportunities", [])
            scene_type = atmosphere_data.get("scene_type", "")

            # High tension or dramatic scenes
            if tension_level >= 7:
                should_report = True
                reflection["important"] = True
                reflection["reason"] = f"High tension scene: {scene_type}"
                urgency = "URGENT"

            # Meaningful quiet moments
            elif descriptive_opportunities and "quiet" in scene_type.lower():
                should_report = True
                reflection["important"] = True
                reflection["reason"] = "Atmospheric moment for reflection"
                urgency = "INFO"

            # Discovery moments
            elif "discovery" in scene_type.lower() or "wonder" in atmosphere_data.get("current_mood", "").lower():
                should_report = True
                reflection["important"] = True
                reflection["reason"] = "Moment of wonder and discovery"
                urgency = "MEDIUM"

        # Mission milestones are always meaningful
        if narrative_data:
            mission_count = narrative_data.get("mission_count", 0)
            if mission_count > 0 and mission_count % 10 == 0:
                should_report = True
                reflection["important"] = True
                reflection["reason"] = f"Major milestone: {mission_count} missions"
                urgency = "URGENT"

        state["reflection"] = reflection
        state["metadata"]["urgency"] = urgency
        state["metadata"]["should_report"] = should_report
        state["metadata"]["narrative_data"] = narrative_data
        state["metadata"]["character_data"] = character_data
        state["metadata"]["atmosphere_data"] = atmosphere_data

        return state

    def _should_communicate(self, state: AgentState) -> bool:
        """Conditional edge: should we generate a message?"""
        return state["metadata"].get("should_report", False)

    async def _communicate_node(self, state: AgentState) -> AgentState:
        """
        Node 5: Communicate - Generate evocative narrative message

        Creates poetic but grounded messages focused on atmosphere, emotion, and meaning.
        """
        urgency = state["metadata"].get("urgency", "INFO")
        narrative_data = state["metadata"].get("narrative_data")
        character_data = state["metadata"].get("character_data")
        atmosphere_data = state["metadata"].get("atmosphere_data")

        message_parts = []

        # Build message based on what we discovered
        if atmosphere_data:
            scene_type = atmosphere_data.get("scene_type", "")
            current_mood = atmosphere_data.get("current_mood", "")
            location = atmosphere_data.get("location", "Unknown")
            tension_level = atmosphere_data.get("tension_level", 0)

            # High tension moments - brief, visceral
            if tension_level >= 7:
                if "crisis" in scene_type.lower():
                    message_parts.append(f"The {location} feels oppressive now. Every decision matters.")
                elif "action" in scene_type.lower():
                    message_parts.append(f"Time slows. The stars themselves seem to watch.")
                elif "urgent" in current_mood.lower():
                    message_parts.append(f"Pressure builds. There's no room for hesitation.")

            # Discovery and wonder
            elif "discovery" in scene_type.lower() or "wonder" in current_mood.lower():
                message_parts.append(f"{location} reveals itself before you.")
                message_parts.append("In moments like these, you remember why you came out here.")

            # Quiet atmospheric moments
            elif "quiet" in scene_type.lower():
                message_parts.append(f"Silence at {location}. A rare moment of peace.")
                if narrative_data:
                    themes = narrative_data.get("narrative_themes", [])
                    if "exploration" in themes:
                        message_parts.append("The vastness doesn't feel quite so empty anymore.")

            # Contemplative story moments
            elif "narrative" in scene_type.lower() or "contemplative" in current_mood.lower():
                message_parts.append("Some choices echo longer than others.")

        # Character development moments
        if character_data and character_data.get("character_moment_opportunity"):
            personality_indicators = character_data.get("personality_indicators", [])
            dominant_skills = character_data.get("dominant_skills", [])
            moment_reason = character_data.get("moment_reason", "")

            if "level up" in moment_reason.lower():
                if dominant_skills:
                    skill_name = dominant_skills[0].title()
                    message_parts.append(f"Your {skill_name} expertise is becoming second nature.")
                else:
                    message_parts.append("You're not the same person who started this journey.")

            elif "skill mastery" in moment_reason.lower():
                if dominant_skills:
                    skill_name = dominant_skills[0].title()
                    message_parts.append(f"Master of {skill_name}. It defines you now.")

            elif "milestone" in moment_reason.lower():
                message_parts.append("Look how far you've come.")

        # Narrative opportunities
        if narrative_data:
            story_opportunities = narrative_data.get("story_opportunities", [])
            emotional_tone = narrative_data.get("emotional_tone", "")

            if story_opportunities:
                opportunity = story_opportunities[0]

                # Mission milestones
                if "milestone" in opportunity.lower():
                    mission_count = narrative_data.get("mission_count", 0)
                    if mission_count >= 10:
                        message_parts.append(f"{mission_count} missions. Each one a story worth telling.")
                    else:
                        message_parts.append(f"{mission_count} down. The journey continues.")

                # First major upgrade
                elif "first major upgrade" in opportunity.lower():
                    system_name = opportunity.split(":")[1].split("-")[0].strip()
                    message_parts.append(f"Your {system_name} hums with new power.")
                    message_parts.append("The ship is becoming what you need it to be.")

                # Survival moments
                elif "survival" in opportunity.lower():
                    if emotional_tone == "desperate":
                        message_parts.append("Desperation can sharpen the mind. Or break it.")
                    else:
                        message_parts.append("You've survived worse. Haven't you?")

                # Explorer moments
                elif "explorer" in opportunity.lower():
                    exploration_count = narrative_data.get("exploration_count", 0)
                    message_parts.append(f"{exploration_count} new places. {exploration_count} new perspectives.")

        # Combine message
        message = "\n".join(message_parts) if message_parts else None

        # Add urgency prefix for critical narrative moments
        if message and urgency == "URGENT":
            message = f"✨ {message}"
        elif message and urgency == "MEDIUM":
            message = f"~ {message}"

        # Fallback message if nothing specific generated
        if not message and state["metadata"].get("should_report"):
            message = "The universe is vast. But you're still here."

        state["message"] = message

        # Record message if generated
        if message:
            await self.record_message()

        return state

    def get_available_tools(self) -> List[Dict[str, Any]]:
        """Get list of tools available to Storyteller"""
        # Return only storyteller-specific tools
        return [
            schema for schema in TOOL_SCHEMAS
            if schema["name"] in [
                "analyze_narrative_context",
                "check_character_development",
                "evaluate_atmosphere"
            ]
        ]

    async def run(
        self,
        game_state: Dict[str, Any],
        force_check: bool = False
    ) -> Dict[str, Any]:
        """
        Main entry point - run the Storyteller agent

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
                    "reasoning": "Storyteller resting - too soon since last tale",
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
            "reasoning": final_state.get("reasoning", "No narrative moment detected"),
            "next_check_in": 90  # Recommend checking again in 90 seconds
        }

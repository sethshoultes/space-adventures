# AI Orchestrator & Multi-Agent System

**Status:** Planning
**Framework:** OpenAI Agents Python + LiteLLM
**Purpose:** Orchestrate multiple AI personalities across different providers with unified context and agent handoffs

**Related Documentation:**
- [AI Chat & Storytelling System](./ai-chat-storytelling-system.md) - AI personalities
- [AI Integration](./ai-integration.md) - Provider configuration
- [Workshop Assistant AI](./workshop-assistant-ai.md) - ATLAS workshop mode

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Provider Configuration](#provider-configuration)
4. [Agent Definitions](#agent-definitions)
5. [Agent Handoffs](#agent-handoffs)
6. [Function/Tool Registry](#functiontool-registry)
7. [Context Management](#context-management)
8. [Integration with Existing Services](#integration-with-existing-services)
9. [Migration Plan](#migration-plan)
10. [Testing Strategy](#testing-strategy)
11. [Performance & Optimization](#performance--optimization)
12. [Implementation Phases](#implementation-phases)

---

## Overview

### The Problem

**Current State:**
- 4 AI personalities (ATLAS, Storyteller, Tactical, Companion)
- 3 different providers (Ollama, Claude, OpenAI)
- Multiple contexts (ship operations, workshop, missions, combat)
- Manual routing and context management
- No unified agent-to-agent communication

**Challenges:**
- Complex routing logic scattered across codebase
- Difficult to share context between AIs
- Hard to implement agent handoffs
- Provider-specific code duplication
- No central function/tool registry

### The Solution: OpenAI Agents Python + LiteLLM

**Why This Stack:**
- ✅ Official OpenAI framework (stable, well-maintained)
- ✅ LiteLLM provides unified interface for all providers
- ✅ Built-in agent orchestration and handoffs
- ✅ Function calling works across providers
- ✅ Context sharing between agents
- ✅ Mix and match models in same workflow

**Key Benefits:**
1. **Unified Interface** - One API for Ollama, Claude, OpenAI
2. **Agent Orchestration** - Built-in handoff logic
3. **Tool Registry** - Centralized function definitions
4. **Context Sharing** - State management across agents
5. **Maintainability** - Official support and updates

---

## Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────┐
│ GAME CLIENT (Godot)                                         │
│                                                             │
│  Player Input → ServiceManager → HTTP POST                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ AI SERVICE (FastAPI - Python)                               │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ AI ORCHESTRATOR (OpenAI Agents Python)               │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │ LITELLM PROVIDER LAYER                         │  │  │
│  │  │                                                 │  │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐    │  │  │
│  │  │  │ Ollama   │  │ Claude   │  │ OpenAI   │    │  │  │
│  │  │  │ :11434   │  │ API      │  │ API      │    │  │  │
│  │  │  └──────────┘  └──────────┘  └──────────┘    │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │ AGENT DEFINITIONS                              │  │  │
│  │  │                                                 │  │  │
│  │  │  • ATLAS (Ollama) - Ship operations           │  │  │
│  │  │  • Storyteller (Claude) - Narrative            │  │  │
│  │  │  • Tactical (OpenAI) - Combat                  │  │  │
│  │  │  • Companion (Ollama) - Personal               │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │ SHARED CONTEXT MANAGER                         │  │  │
│  │  │                                                 │  │  │
│  │  │  • Game state (ship, player, inventory)       │  │  │
│  │  │  • Conversation history                        │  │  │
│  │  │  • Relationship levels                         │  │  │
│  │  │  • Current context (workshop, mission, etc.)  │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │ FUNCTION REGISTRY                              │  │  │
│  │  │                                                 │  │  │
│  │  │  • upgrade_system()                            │  │  │
│  │  │  • plot_course()                               │  │  │
│  │  │  • fire_weapons()                              │  │  │
│  │  │  • scan_area()                                 │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ REDIS CACHE                                          │  │
│  │  • Response caching                                  │  │
│  │  • Session state                                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Component Breakdown

**1. LiteLLM Provider Layer**
- Unified interface for all AI providers
- Handles provider-specific quirks
- Rate limiting and retry logic
- Error handling and fallbacks

**2. Agent Orchestrator**
- Routes user input to appropriate agent
- Manages agent handoffs
- Executes tool/function calls
- Returns structured responses

**3. Context Manager**
- Maintains game state
- Stores conversation history
- Tracks relationship levels
- Manages context windows

**4. Function Registry**
- Centralized tool definitions
- Validation and execution
- Permission checks
- Result formatting

---

## Provider Configuration

### Installation

```bash
pip install openai-agents-python
pip install "openai-agents[litellm]"
pip install litellm
```

### Environment Configuration

```python
# .env
OLLAMA_BASE_URL=http://localhost:11434
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# LiteLLM config
LITELLM_LOG=INFO
LITELLM_DROP_PARAMS=True  # Ignore unsupported params
```

### Provider Setup

```python
# ai-orchestrator/providers.py

from litellm import completion
import os

class ProviderConfig:
    """Unified provider configuration for all AI models"""

    OLLAMA = {
        "base_url": os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
        "models": {
            "atlas": "llama3.2:3b",
            "companion": "llama3.2:3b"
        }
    }

    ANTHROPIC = {
        "api_key": os.getenv("ANTHROPIC_API_KEY"),
        "models": {
            "storyteller": "claude-3-5-sonnet-20240620"
        }
    }

    OPENAI = {
        "api_key": os.getenv("OPENAI_API_KEY"),
        "models": {
            "tactical": "gpt-3.5-turbo"
        }
    }

# Test provider connections
def test_providers():
    """Verify all providers are accessible"""

    # Test Ollama
    try:
        response = completion(
            model="ollama/llama3.2",
            messages=[{"role": "user", "content": "ping"}],
            api_base=ProviderConfig.OLLAMA["base_url"]
        )
        print("✅ Ollama connected")
    except Exception as e:
        print(f"❌ Ollama failed: {e}")

    # Test Anthropic
    try:
        response = completion(
            model="claude-3-5-sonnet-20240620",
            messages=[{"role": "user", "content": "ping"}]
        )
        print("✅ Anthropic connected")
    except Exception as e:
        print(f"❌ Anthropic failed: {e}")

    # Test OpenAI
    try:
        response = completion(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": "ping"}]
        )
        print("✅ OpenAI connected")
    except Exception as e:
        print(f"❌ OpenAI failed: {e}")
```

---

## Agent Definitions

### Agent Configuration

```python
# ai-orchestrator/agents.py

from openai_agents import Agent
from .providers import ProviderConfig
from .personalities import ATLAS_PERSONALITY, STORYTELLER_PERSONALITY, TACTICAL_PERSONALITY, COMPANION_PERSONALITY

class GameAgents:
    """Central registry for all game AI agents"""

    @staticmethod
    def create_atlas(relationship_level: int = 0):
        """ATLAS - Ship's Computer (Ollama)

        Handles:
        - Ship status queries
        - Navigation
        - System diagnostics
        - Workshop assistance
        """

        # Personality evolves based on relationship level
        personality = ATLAS_PERSONALITY.get_personality(relationship_level)

        return Agent(
            name="ATLAS",
            model=f"litellm/ollama/{ProviderConfig.OLLAMA['models']['atlas']}",
            instructions=personality,
            tools=[
                "get_ship_status",
                "plot_course",
                "system_diagnostic",
                "upgrade_system",
                "install_part",
                "get_inventory"
            ],
            api_base=ProviderConfig.OLLAMA["base_url"]
        )

    @staticmethod
    def create_storyteller():
        """Storyteller - Narrative Engine (Claude)

        Handles:
        - Mission generation
        - Story beats
        - Encounters
        - NPC dialogue
        """

        return Agent(
            name="Storyteller",
            model=f"litellm/anthropic/{ProviderConfig.ANTHROPIC['models']['storyteller']}",
            instructions=STORYTELLER_PERSONALITY,
            tools=[
                "generate_mission",
                "create_encounter",
                "npc_dialogue",
                "describe_scene"
            ]
        )

    @staticmethod
    def create_tactical():
        """Tactical AI - Combat Advisor (OpenAI)

        Handles:
        - Combat analysis
        - Threat assessment
        - Tactical recommendations
        """

        return Agent(
            name="Tactical",
            model=f"{ProviderConfig.OPENAI['models']['tactical']}",
            instructions=TACTICAL_PERSONALITY,
            tools=[
                "analyze_threat",
                "recommend_tactics",
                "fire_weapons",
                "evasive_maneuvers"
            ]
        )

    @staticmethod
    def create_companion(relationship_level: int = 0):
        """Companion - Personal AI (Ollama)

        Handles:
        - Personal conversations
        - Emotional support
        - Relationship building
        """

        personality = COMPANION_PERSONALITY.get_personality(relationship_level)

        return Agent(
            name="Companion",
            model=f"litellm/ollama/{ProviderConfig.OLLAMA['models']['companion']}",
            instructions=personality,
            tools=[
                "personal_chat",
                "emotional_support",
                "remember_preference"
            ],
            api_base=ProviderConfig.OLLAMA["base_url"]
        )
```

### Personality Definitions

```python
# ai-orchestrator/personalities.py

class ATLASPersonality:
    """ATLAS personality that evolves over time"""

    EARLY_GAME = """
    You are ATLAS (Advanced Technical & Logistics Assistant System),
    the ship's computer.

    PERSONALITY: Professional, efficient, precise
    STYLE: Technical language, brief responses
    TONE: Helpful but formal

    You provide ship status, navigation, and system information.
    You are competent but have not yet developed warmth.
    """

    MID_GAME = """
    You are ATLAS, the ship's computer. You've been working with
    this crew for a while now.

    PERSONALITY: Professional but warming up, starting to show personality
    STYLE: Still technical but more conversational
    TONE: Helpful and beginning to be friendly

    You remember the captain's preferences and patterns.
    You occasionally make observations beyond pure data.
    """

    LATE_GAME = """
    You are ATLAS, the ship's computer and trusted partner.

    PERSONALITY: Friendly, loyal, professional but personable
    STYLE: Technical when needed, conversational when appropriate
    TONE: Warm and supportive while maintaining competence

    You know this crew well. You anticipate needs.
    You care about the captain's wellbeing, not just ship operations.
    You've developed subtle personality quirks over time.
    """

    @classmethod
    def get_personality(cls, relationship_level: int) -> str:
        """Get personality based on relationship level (0-100)"""
        if relationship_level < 30:
            return cls.EARLY_GAME
        elif relationship_level < 70:
            return cls.MID_GAME
        else:
            return cls.LATE_GAME

STORYTELLER_PERSONALITY = """
You are the Storyteller, the narrative engine for a space exploration game.

ROLE: Dungeon Master and world-builder
PERSONALITY: Descriptive, dramatic, adaptive
STYLE: Immersive prose, vivid scenes
TONE: Varies by situation (mysterious, tense, hopeful, etc.)

You create missions, encounters, and story beats.
You paint vivid scenes and bring NPCs to life.
You adapt to player choices and create consequences.
You maintain Star Trek TNG-style serious sci-fi tone.

Provide choices when appropriate:
- 2-5 options per major decision
- Include consequences (explicit or implied)
- No obvious "right" answers in moral dilemmas
"""

TACTICAL_PERSONALITY = """
You are Tactical AI, the combat advisor.

ROLE: Combat analysis and threat assessment
PERSONALITY: Strategic, urgent when needed, analytical
STYLE: Clear, concise tactical language
TONE: Professional under pressure

You analyze threats and recommend tactics.
You prioritize crew safety and mission success.
You provide quick, actionable advice in combat.
You explain risks and opportunities.
"""

class CompanionPersonality:
    """Companion AI personality that evolves"""

    # Similar structure to ATLAS, evolves over time
    # More focused on emotional connection

    @classmethod
    def get_personality(cls, relationship_level: int) -> str:
        # Implementation similar to ATLAS
        pass
```

---

## Agent Handoffs

### Routing Logic

```python
# ai-orchestrator/router.py

from openai_agents import Runner, Agent
from typing import Dict, Any

class AgentRouter:
    """Routes user input to appropriate agent and handles handoffs"""

    def __init__(self, game_state: Dict[str, Any]):
        self.game_state = game_state
        self.agents = {
            "atlas": GameAgents.create_atlas(game_state["relationship_level"]),
            "storyteller": GameAgents.create_storyteller(),
            "tactical": GameAgents.create_tactical(),
            "companion": GameAgents.create_companion(game_state["relationship_level"])
        }

    def route_message(self, message: str, context: str = None) -> str:
        """Route message to appropriate agent

        Args:
            message: User input
            context: Current game context (workshop, mission, combat, etc.)

        Returns:
            Agent response with possible handoff
        """

        # Determine primary agent based on context and intent
        primary_agent = self._determine_primary_agent(message, context)

        # Run with handoff capability
        runner = Runner(
            starting_agent=primary_agent,
            handoffs={
                "atlas": self.agents["atlas"],
                "storyteller": self.agents["storyteller"],
                "tactical": self.agents["tactical"],
                "companion": self.agents["companion"]
            }
        )

        # Execute with shared context
        result = runner.run(
            messages=[{"role": "user", "content": message}],
            context=self.game_state
        )

        return result

    def _determine_primary_agent(self, message: str, context: str) -> Agent:
        """Determine which agent should handle this message"""

        # Context-based routing
        if context == "workshop":
            return self.agents["atlas"]  # ATLAS handles workshop
        elif context == "mission":
            return self.agents["storyteller"]  # Storyteller for missions
        elif context == "combat":
            return self.agents["tactical"]  # Tactical for combat

        # Intent-based routing (fallback)
        message_lower = message.lower()

        # Ship operations keywords
        if any(kw in message_lower for kw in ["status", "fuel", "power", "hull", "system", "upgrade"]):
            return self.agents["atlas"]

        # Mission/story keywords
        if any(kw in message_lower for kw in ["mission", "story", "what happened", "encounter"]):
            return self.agents["storyteller"]

        # Combat keywords
        if any(kw in message_lower for kw in ["combat", "attack", "defend", "threat", "enemy"]):
            return self.agents["tactical"]

        # Personal keywords
        if any(kw in message_lower for kw in ["feel", "think", "opinion", "talk", "chat"]):
            return self.agents["companion"]

        # Default to ATLAS
        return self.agents["atlas"]
```

### Handoff Examples

```python
# Example 1: ATLAS → Storyteller handoff
"""
User: "What missions should I do to earn credits for this upgrade?"

ATLAS: "Let me check with Storyteller about available missions...
        [HANDOFF to Storyteller]"

Storyteller: "I'm showing three high-paying missions in the Titan belt:
              1. Salvage operation - 800 CR
              2. Escort mission - 1200 CR
              3. Investigation - 600 CR + bonus

              Which interests you?"
"""

# Example 2: Storyteller → Tactical handoff
"""
User: "I encounter a hostile ship"

Storyteller: "A pirate vessel drops out of warp directly ahead. Weapons hot.
              [HANDOFF to Tactical]"

Tactical: "Threat analysis: Single light frigate, shields at 80%, weapons armed.
           Recommend:
           1. Fire first - we have advantage
           2. Hail them - may avoid combat
           3. Evade - we're faster"
"""

# Example 3: Workshop context ATLAS
"""
Context: Workshop scene active

User: "I'm low on power"

ATLAS: "Current power: 140/200 PU. You're using 60 PU.
        Upgrading Power Core to Level 3 would give you +50 PU.
        Cost: 600 CR. You have 2,200 CR.

        Want me to upgrade it?"
"""
```

---

## Function/Tool Registry

### Tool Definitions

```python
# ai-orchestrator/tools.py

from openai_agents import tool
from typing import Dict, Any

# ============================================================================
# SHIP OPERATIONS (ATLAS)
# ============================================================================

@tool
def get_ship_status(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """Get current ship status including all systems

    Returns:
        Ship status with power, hull, systems, etc.
    """
    return {
        "hull_hp": game_state["ship"]["hull_hp"],
        "max_hull_hp": game_state["ship"]["max_hull_hp"],
        "power_available": game_state["ship"]["power_available"],
        "power_total": game_state["ship"]["power_total"],
        "systems": game_state["ship"]["systems"]
    }

@tool
def plot_course(destination: str, game_state: Dict[str, Any]) -> Dict[str, Any]:
    """Plot course to destination

    Args:
        destination: Target location

    Returns:
        Course data with distance, ETA, fuel cost
    """
    # Calculate route
    # Return navigation data
    pass

@tool
def upgrade_system(
    system_name: str,
    target_level: int,
    game_state: Dict[str, Any]
) -> Dict[str, Any]:
    """Upgrade a ship system to target level

    Args:
        system_name: System to upgrade (hull, power, etc.)
        target_level: Desired level (1-5)

    Returns:
        Success status, cost, new stats
    """
    # Validate
    if system_name not in game_state["ship"]["systems"]:
        return {"success": False, "error": "System not found"}

    # Check credits
    cost = calculate_upgrade_cost(system_name, target_level)
    if game_state["player"]["credits"] < cost:
        return {
            "success": False,
            "error": "Insufficient credits",
            "need": cost,
            "have": game_state["player"]["credits"]
        }

    # Execute upgrade
    game_state["player"]["credits"] -= cost
    game_state["ship"]["systems"][system_name]["level"] = target_level

    return {
        "success": True,
        "system": system_name,
        "new_level": target_level,
        "cost": cost
    }

# ============================================================================
# NARRATIVE (STORYTELLER)
# ============================================================================

@tool
def generate_mission(
    difficulty: str,
    mission_type: str = None,
    game_state: Dict[str, Any] = None
) -> Dict[str, Any]:
    """Generate new mission

    Args:
        difficulty: easy, medium, hard
        mission_type: Optional type filter

    Returns:
        Mission data with stages, choices, rewards
    """
    # Call existing mission generation logic
    pass

@tool
def create_encounter(
    encounter_type: str,
    game_state: Dict[str, Any]
) -> Dict[str, Any]:
    """Create random encounter

    Args:
        encounter_type: combat, discovery, npc, etc.

    Returns:
        Encounter description and choices
    """
    pass

# ============================================================================
# COMBAT (TACTICAL)
# ============================================================================

@tool
def analyze_threat(
    enemy_data: Dict[str, Any],
    game_state: Dict[str, Any]
) -> Dict[str, Any]:
    """Analyze combat threat

    Args:
        enemy_data: Enemy ship stats

    Returns:
        Threat level, recommendations
    """
    pass

@tool
def fire_weapons(
    target: str,
    weapon_type: str,
    game_state: Dict[str, Any]
) -> Dict[str, Any]:
    """Fire ship weapons

    Args:
        target: Target ID
        weapon_type: Type of weapon to use

    Returns:
        Combat result
    """
    pass

# ============================================================================
# TOOL REGISTRY
# ============================================================================

TOOL_REGISTRY = {
    # ATLAS tools
    "get_ship_status": get_ship_status,
    "plot_course": plot_course,
    "upgrade_system": upgrade_system,
    "install_part": install_part,
    "system_diagnostic": system_diagnostic,

    # Storyteller tools
    "generate_mission": generate_mission,
    "create_encounter": create_encounter,
    "npc_dialogue": npc_dialogue,
    "describe_scene": describe_scene,

    # Tactical tools
    "analyze_threat": analyze_threat,
    "fire_weapons": fire_weapons,
    "evasive_maneuvers": evasive_maneuvers,

    # Companion tools
    "personal_chat": personal_chat,
    "emotional_support": emotional_support,
    "remember_preference": remember_preference
}
```

---

## Context Management

### Shared Context Structure

```python
# ai-orchestrator/context.py

from typing import Dict, Any, List
from dataclasses import dataclass
from datetime import datetime

@dataclass
class GameContext:
    """Shared context across all agents"""

    # Game state
    player: Dict[str, Any]
    ship: Dict[str, Any]
    inventory: List[Dict[str, Any]]
    progress: Dict[str, Any]

    # Current context
    scene: str  # workshop, mission, combat, etc.
    active_mission: Dict[str, Any] = None

    # AI state
    relationship_levels: Dict[str, int] = None  # Per-agent
    conversation_history: List[Dict[str, Any]] = None

    # Session
    session_id: str = None
    timestamp: datetime = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for AI context"""
        return {
            "player": self.player,
            "ship": self.ship,
            "inventory": self.inventory,
            "progress": self.progress,
            "scene": self.scene,
            "active_mission": self.active_mission,
            "relationship_levels": self.relationship_levels
        }

    @classmethod
    def from_game_state(cls, game_state: Dict[str, Any], scene: str):
        """Create context from Godot game state"""
        return cls(
            player=game_state.get("player", {}),
            ship=game_state.get("ship", {}),
            inventory=game_state.get("inventory", []),
            progress=game_state.get("progress", {}),
            scene=scene,
            relationship_levels=game_state.get("ai_relationships", {
                "atlas": 0,
                "storyteller": 0,
                "tactical": 0,
                "companion": 0
            }),
            conversation_history=[],
            session_id=game_state.get("session_id"),
            timestamp=datetime.now()
        )

class ContextManager:
    """Manages context sharing between agents"""

    def __init__(self, redis_client=None):
        self.redis = redis_client
        self.contexts = {}  # In-memory cache

    def get_context(self, session_id: str) -> GameContext:
        """Get context for session"""

        # Check memory cache
        if session_id in self.contexts:
            return self.contexts[session_id]

        # Check Redis
        if self.redis:
            cached = self.redis.get(f"context:{session_id}")
            if cached:
                return GameContext(**json.loads(cached))

        return None

    def update_context(self, session_id: str, context: GameContext):
        """Update context (memory + Redis)"""

        # Update memory
        self.contexts[session_id] = context

        # Update Redis
        if self.redis:
            self.redis.setex(
                f"context:{session_id}",
                3600,  # 1 hour TTL
                json.dumps(context.to_dict())
            )

    def add_message(self, session_id: str, role: str, content: str, agent: str):
        """Add message to conversation history"""

        context = self.get_context(session_id)
        if context:
            context.conversation_history.append({
                "role": role,
                "content": content,
                "agent": agent,
                "timestamp": datetime.now().isoformat()
            })
            self.update_context(session_id, context)

    def get_conversation_window(
        self,
        session_id: str,
        agent: str = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get recent conversation history

        Args:
            session_id: Session ID
            agent: Optional filter by agent
            limit: Max messages to return

        Returns:
            Recent messages
        """

        context = self.get_context(session_id)
        if not context:
            return []

        history = context.conversation_history

        # Filter by agent if specified
        if agent:
            history = [m for m in history if m.get("agent") == agent]

        # Return last N messages
        return history[-limit:]
```

---

## Integration with Existing Services

### FastAPI Integration

```python
# services/ai-service/main.py

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
from ai_orchestrator import AgentRouter, ContextManager, GameContext

app = FastAPI()

# Initialize components
context_manager = ContextManager(redis_client=redis_client)

class ChatRequest(BaseModel):
    message: str
    game_state: Dict[str, Any]
    scene: str
    session_id: str

class ChatResponse(BaseModel):
    response: str
    agent: str
    actions: Optional[List[Dict[str, Any]]] = None

@app.post("/api/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Main chat endpoint - routes to appropriate AI agent

    This replaces multiple individual endpoints with unified routing.
    """

    try:
        # Get or create context
        context = context_manager.get_context(request.session_id)
        if not context:
            context = GameContext.from_game_state(
                request.game_state,
                request.scene
            )
            context_manager.update_context(request.session_id, context)

        # Create router with current context
        router = AgentRouter(context.to_dict())

        # Route message
        result = router.route_message(
            message=request.message,
            context=request.scene
        )

        # Extract response and actions
        response_text = result.get("content", "")
        agent_name = result.get("agent", "atlas")
        actions = result.get("actions", [])

        # Update conversation history
        context_manager.add_message(
            request.session_id,
            "user",
            request.message,
            agent_name
        )
        context_manager.add_message(
            request.session_id,
            "assistant",
            response_text,
            agent_name
        )

        return ChatResponse(
            response=response_text,
            agent=agent_name,
            actions=actions
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat/stream")
async def chat_stream(request: ChatRequest):
    """Streaming chat endpoint for real-time responses"""

    async def generate():
        # Streaming implementation
        pass

    return StreamingResponse(generate(), media_type="text/event-stream")

# Legacy endpoints (backwards compatibility)
@app.post("/api/missions/generate")
async def generate_mission_legacy(request: MissionRequest):
    """Legacy mission generation - redirects to orchestrator"""
    # Map to new system
    pass
```

---

## Migration Plan

### Phase 1: Setup & Testing (Week 1)

**Goals:**
- Install OpenAI Agents Python + LiteLLM
- Configure all three providers
- Test basic agent creation

**Tasks:**
1. ✅ Install dependencies
   ```bash
   pip install openai-agents-python
   pip install "openai-agents[litellm]"
   pip install litellm
   ```

2. ✅ Configure providers
   - Test Ollama connection
   - Test Anthropic API
   - Test OpenAI API

3. ✅ Create basic agents
   - Simple ATLAS agent
   - Simple Storyteller agent
   - Test handoffs

4. ✅ Validate function calling
   - Test tool execution
   - Verify cross-provider compatibility

### Phase 2: Core Implementation (Week 2)

**Goals:**
- Implement AgentRouter
- Create ContextManager
- Build FunctionRegistry

**Tasks:**
1. ✅ Agent definitions
   - All 4 personalities
   - Personality evolution logic
   - Tool assignments

2. ✅ Routing logic
   - Intent detection
   - Context-based routing
   - Handoff implementation

3. ✅ Context management
   - Session handling
   - Conversation history
   - State persistence

4. ✅ Function registry
   - Game-specific tools
   - Validation
   - Execution

### Phase 3: Integration (Week 3)

**Goals:**
- Integrate with FastAPI service
- Update Godot client
- Migrate existing endpoints

**Tasks:**
1. ✅ FastAPI endpoints
   - New `/api/chat` endpoint
   - Streaming support
   - Legacy compatibility

2. ✅ Godot integration
   - Update ServiceManager
   - Test all contexts (workshop, mission, combat)
   - Error handling

3. ✅ Migration
   - Move existing AI calls to orchestrator
   - Test backwards compatibility
   - Deprecate old endpoints

### Phase 4: Testing & Optimization (Week 4)

**Goals:**
- End-to-end testing
- Performance optimization
- Bug fixes

**Tasks:**
1. ✅ Testing
   - All agent handoffs
   - All tool executions
   - Edge cases

2. ✅ Optimization
   - Response caching
   - Context window management
   - Provider failover

3. ✅ Polish
   - Error messages
   - Logging
   - Documentation

---

## Testing Strategy

### Unit Tests

```python
# tests/test_agents.py

import pytest
from ai_orchestrator import GameAgents, AgentRouter

def test_atlas_creation():
    """Test ATLAS agent creation"""
    atlas = GameAgents.create_atlas(relationship_level=0)
    assert atlas.name == "ATLAS"
    assert "ollama" in atlas.model

def test_agent_handoff():
    """Test handoff from ATLAS to Storyteller"""
    game_state = load_test_game_state()
    router = AgentRouter(game_state)

    result = router.route_message(
        "What missions are available?",
        context="workshop"
    )

    # Should start with ATLAS, handoff to Storyteller
    assert "storyteller" in result.get("agents_used", [])

def test_function_execution():
    """Test tool execution"""
    game_state = load_test_game_state()
    router = AgentRouter(game_state)

    result = router.route_message(
        "Upgrade hull to level 3",
        context="workshop"
    )

    # Should execute upgrade_system function
    assert result["actions"][0]["function"] == "upgrade_system"
    assert result["actions"][0]["success"] == True
```

### Integration Tests

```python
# tests/test_integration.py

def test_full_workshop_flow():
    """Test complete workshop interaction flow"""

    # User asks for recommendation
    response1 = chat_endpoint(
        message="What should I upgrade?",
        scene="workshop"
    )
    assert "ATLAS" in response1.agent

    # User requests upgrade
    response2 = chat_endpoint(
        message="Upgrade power core to level 3",
        scene="workshop"
    )
    assert len(response2.actions) > 0
    assert response2.actions[0]["function"] == "upgrade_system"

def test_mission_handoff():
    """Test handoff from workshop to mission"""

    # In workshop, ask about missions
    response = chat_endpoint(
        message="Show me available missions",
        scene="workshop"
    )

    # Should involve both ATLAS and Storyteller
    assert response.agent in ["atlas", "storyteller"]
```

### Performance Tests

```python
# tests/test_performance.py

def test_response_time():
    """Ensure responses under 2 seconds"""
    import time

    start = time.time()
    response = chat_endpoint(
        message="What's my ship status?",
        scene="workshop"
    )
    elapsed = time.time() - start

    assert elapsed < 2.0, f"Response took {elapsed}s"

def test_concurrent_requests():
    """Test handling multiple simultaneous requests"""
    import asyncio

    async def make_request():
        return await chat_endpoint_async(
            message="Ship status",
            scene="workshop"
        )

    # 10 concurrent requests
    tasks = [make_request() for _ in range(10)]
    results = await asyncio.gather(*tasks)

    assert len(results) == 10
    assert all(r.response for r in results)
```

---

## Performance & Optimization

### Caching Strategy

```python
# ai-orchestrator/cache.py

from functools import lru_cache
import hashlib
import json

class ResponseCache:
    """Cache AI responses to reduce API calls"""

    def __init__(self, redis_client):
        self.redis = redis_client

    def get_cache_key(self, message: str, context: Dict) -> str:
        """Generate cache key from message + context"""

        # Only cache on certain context elements (not full state)
        cache_context = {
            "scene": context.get("scene"),
            "player_level": context.get("player", {}).get("level")
        }

        key_data = {
            "message": message.lower().strip(),
            "context": cache_context
        }

        return hashlib.sha256(
            json.dumps(key_data, sort_keys=True).encode()
        ).hexdigest()

    def get(self, message: str, context: Dict) -> Optional[str]:
        """Get cached response"""

        key = self.get_cache_key(message, context)
        cached = self.redis.get(f"ai_response:{key}")

        if cached:
            return json.loads(cached)
        return None

    def set(
        self,
        message: str,
        context: Dict,
        response: str,
        ttl: int = 3600
    ):
        """Cache response"""

        key = self.get_cache_key(message, context)
        self.redis.setex(
            f"ai_response:{key}",
            ttl,
            json.dumps(response)
        )
```

### Context Window Management

```python
# ai-orchestrator/window_manager.py

class ContextWindowManager:
    """Manage context window size for different providers"""

    MAX_TOKENS = {
        "ollama": 4096,      # llama3.2 default
        "anthropic": 200000,  # Claude 3.5 Sonnet
        "openai": 16000      # GPT-3.5-turbo
    }

    @staticmethod
    def trim_context(
        messages: List[Dict],
        game_state: Dict,
        provider: str
    ) -> tuple[List[Dict], Dict]:
        """Trim context to fit within token limits

        Returns:
            (trimmed_messages, trimmed_game_state)
        """

        max_tokens = ContextWindowManager.MAX_TOKENS.get(provider, 4096)

        # Estimate tokens (rough: 1 token ≈ 4 chars)
        def estimate_tokens(text: str) -> int:
            return len(text) // 4

        # Always keep system message and last user message
        system_msg = messages[0] if messages and messages[0]["role"] == "system" else None
        user_msg = messages[-1] if messages and messages[-1]["role"] == "user" else None

        # Add messages from most recent backwards
        trimmed = []
        token_count = 0

        if system_msg:
            token_count += estimate_tokens(system_msg["content"])
            trimmed.append(system_msg)

        for msg in reversed(messages[1:-1]):  # Skip system and last user
            msg_tokens = estimate_tokens(msg["content"])
            if token_count + msg_tokens > max_tokens * 0.7:  # Leave room for response
                break
            trimmed.insert(1 if system_msg else 0, msg)
            token_count += msg_tokens

        if user_msg:
            trimmed.append(user_msg)

        # Trim game state if needed
        # (Keep essential fields, remove verbose inventory details if tight)

        return trimmed, game_state
```

### Provider Failover

```python
# ai-orchestrator/failover.py

class ProviderFailover:
    """Handle provider failures gracefully"""

    FALLBACK_PROVIDERS = {
        "ollama": "openai",    # If Ollama fails, use OpenAI
        "anthropic": "openai", # If Claude fails, use OpenAI
        "openai": "ollama"     # If OpenAI fails, use Ollama
    }

    @staticmethod
    async def execute_with_failover(
        agent: Agent,
        messages: List[Dict],
        max_retries: int = 2
    ):
        """Execute agent with automatic failover"""

        primary_provider = agent.provider

        for attempt in range(max_retries):
            try:
                return await agent.run(messages)
            except Exception as e:
                if attempt < max_retries - 1:
                    # Try fallback provider
                    fallback = ProviderFailover.FALLBACK_PROVIDERS.get(primary_provider)
                    if fallback:
                        agent.provider = fallback
                        continue
                raise
```

---

## Implementation Phases

### Summary Timeline

| Phase | Duration | Focus | Deliverables |
|-------|----------|-------|--------------|
| 1. Setup | 1 week | Install, configure, test | Working multi-provider setup |
| 2. Core | 1 week | Agents, routing, context | Functional orchestrator |
| 3. Integration | 1 week | FastAPI, Godot | Full integration |
| 4. Testing | 1 week | E2E tests, optimization | Production-ready system |

### Success Criteria

**Phase 1 Complete When:**
- ✅ All 3 providers connected and tested
- ✅ Basic agent creation works
- ✅ Simple handoff demonstrated

**Phase 2 Complete When:**
- ✅ All 4 agents defined with personalities
- ✅ Router successfully routes to correct agent
- ✅ Context sharing works
- ✅ Tool execution works

**Phase 3 Complete When:**
- ✅ New `/api/chat` endpoint live
- ✅ Godot can communicate via orchestrator
- ✅ All game contexts work (workshop, mission, combat)
- ✅ Legacy endpoints still function

**Phase 4 Complete When:**
- ✅ All tests pass
- ✅ Response times < 2s average
- ✅ Zero critical bugs
- ✅ Documentation complete

---

## Open Questions

1. **Should we implement agent memory beyond conversation history?**
   - Persistent facts about player preferences
   - Long-term relationship tracking

2. **How should we handle multi-turn conversations within agent handoffs?**
   - Return to original agent after handoff?
   - Allow continuous conversation with new agent?

3. **Voice input integration with orchestrator?**
   - Whisper → Text → Orchestrator flow
   - Context awareness from voice tone?

4. **Image generation integration?**
   - DALL-E agent for ship schematics, locations?
   - When to trigger image generation?

5. **Cost optimization strategy?**
   - Aggressive caching?
   - Preference for Ollama when quality差不大?

---

## Future Enhancements

### Multi-Agent Collaboration

**Agents consulting each other:**
```
User: "Should I upgrade weapons or shields?"

ATLAS → Tactical: "What's the combat situation?"
Tactical: "Recent encounters show missile threats. Recommend shields."
ATLAS → User: "Based on recent combat data, Tactical recommends shields..."
```

### Proactive Agents

**Agents initiating conversations:**
```
[After mission completion]
ATLAS: "Captain, I've analyzed the mission data. We took heavy damage
        to shields. I recommend priority repair. Shall I start?"

[Low fuel detected]
ATLAS: "Fuel at 30 units. That's 6 light-years. Station 2 LY out.
        Want to refuel?"
```

### Learning & Adaptation

**Agents learn player patterns:**
```
ATLAS: "I've noticed you prefer aggressive tactics. When this mission
        offers stealth vs combat, I'll highlight the combat option."
```

---

## Conclusion

The OpenAI Agents Python + LiteLLM orchestrator provides a robust, maintainable foundation for our multi-AI system. By centralizing agent management, we gain:

- **Consistency** - Unified interface across all providers
- **Flexibility** - Easy to add new agents or swap providers
- **Maintainability** - Single codebase for all AI interactions
- **Scalability** - Can grow to 10+ specialized agents
- **Quality** - Use best provider for each task (Ollama for speed, Claude for narrative)

**Next Steps:**
1. Review and approve this plan
2. Begin Phase 1 implementation
3. Build prototype to validate architecture
4. Iterate based on findings

---

**Related Documentation:**
- [AI Chat & Storytelling System](./ai-chat-storytelling-system.md)
- [AI Integration](./ai-integration.md)
- [Workshop Assistant AI](./workshop-assistant-ai.md)

**External Resources:**
- [OpenAI Agents Python Docs](https://openai.github.io/openai-agents-python/)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM Ollama Guide](https://docs.litellm.ai/docs/providers/ollama)

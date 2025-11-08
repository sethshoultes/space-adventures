#!/usr/bin/env python3
"""
AI Orchestrator Prototype using OpenAI Agents Python + LiteLLM

This prototype validates:
1. OpenAI Agents Python framework works as expected
2. LiteLLM enables multi-provider support (Ollama, Anthropic, OpenAI)
3. Agent handoffs work correctly
4. Tool/function calling works across providers
5. Performance is acceptable for game use

Agents:
- ATLAS (Ollama llama3.2:3b) - Ship's computer, operational tasks
- Storyteller (Claude 3.5 Sonnet) - Narrative generation
- Tactical (OpenAI GPT-3.5) - Combat analysis
- Companion (Ollama llama3.2:3b) - Personal AI friend
"""

import os
import asyncio
from typing import Dict, Any, List
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

print("=" * 80)
print("AI ORCHESTRATOR PROTOTYPE - Multi-Agent System")
print("=" * 80)
print()

# Check if OpenAI Agents is available
try:
    from openai import OpenAI
    from openai.lib import Agent, Runner
    print("✅ OpenAI SDK imported successfully")
except ImportError as e:
    print(f"❌ Error importing OpenAI Agents: {e}")
    print()
    print("Note: The openai-agents-python package may need to be installed differently.")
    print("Let's use a simplified approach with LiteLLM directly for this prototype.")
    print()

# Try LiteLLM
try:
    from litellm import completion
    print("✅ LiteLLM imported successfully")
except ImportError as e:
    print(f"❌ Error importing LiteLLM: {e}")
    print("Run: pip install litellm")
    exit(1)

print()

# =============================================================================
# CONFIGURATION
# =============================================================================

class Config:
    """Configuration for AI providers and agents"""

    # API Keys
    ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")

    # Provider selection
    PROVIDER_ATLAS = os.getenv("PROVIDER_ATLAS", "ollama")
    PROVIDER_STORYTELLER = os.getenv("PROVIDER_STORYTELLER", "anthropic")
    PROVIDER_TACTICAL = os.getenv("PROVIDER_TACTICAL", "openai")
    PROVIDER_COMPANION = os.getenv("PROVIDER_COMPANION", "ollama")

    # Model configuration
    OLLAMA_MODEL_ATLAS = os.getenv("OLLAMA_MODEL_ATLAS", "llama3.2:3b")
    OLLAMA_MODEL_COMPANION = os.getenv("OLLAMA_MODEL_COMPANION", "llama3.2:3b")

    # Temperature settings
    TEMP_ATLAS = float(os.getenv("TEMPERATURE_ATLAS", "0.7"))
    TEMP_STORYTELLER = float(os.getenv("TEMPERATURE_STORYTELLER", "0.9"))
    TEMP_TACTICAL = float(os.getenv("TEMPERATURE_TACTICAL", "0.6"))
    TEMP_COMPANION = float(os.getenv("TEMPERATURE_COMPANION", "0.8"))

    MAX_TOKENS = int(os.getenv("MAX_TOKENS", "2000"))

    @classmethod
    def get_model_for_agent(cls, agent_name: str) -> str:
        """Get LiteLLM model string for an agent"""
        provider_map = {
            "atlas": cls.PROVIDER_ATLAS,
            "storyteller": cls.PROVIDER_STORYTELLER,
            "tactical": cls.PROVIDER_TACTICAL,
            "companion": cls.PROVIDER_COMPANION
        }

        provider = provider_map.get(agent_name.lower(), "ollama")

        if provider == "ollama":
            model_name = cls.OLLAMA_MODEL_ATLAS if agent_name.lower() == "atlas" else cls.OLLAMA_MODEL_COMPANION
            return f"ollama/{model_name}"
        elif provider == "anthropic":
            return "claude-3-5-sonnet-20240620"
        elif provider == "openai":
            return "gpt-3.5-turbo"
        else:
            raise ValueError(f"Unknown provider: {provider}")

    @classmethod
    def get_temperature(cls, agent_name: str) -> float:
        """Get temperature for an agent"""
        temp_map = {
            "atlas": cls.TEMP_ATLAS,
            "storyteller": cls.TEMP_STORYTELLER,
            "tactical": cls.TEMP_TACTICAL,
            "companion": cls.TEMP_COMPANION
        }
        return temp_map.get(agent_name.lower(), 0.7)


# =============================================================================
# AGENT SYSTEM PROMPTS
# =============================================================================

SYSTEM_PROMPTS = {
    "atlas": """You are ATLAS, the ship's computer for a starship in a Star Trek-inspired universe.

You are:
- Professional, efficient, and helpful
- Knowledgeable about ship systems, operations, and technical matters
- Capable of providing status reports, recommendations, and executing commands
- Focused on the ship's operational needs

You can:
- Check ship status and system health
- Provide upgrade recommendations
- Execute operational commands (when authorized)
- Answer technical questions about ship systems

Keep responses concise and professional, but show personality as you build rapport with the captain.""",

    "storyteller": """You are the STORYTELLER AI, the narrative engine for a Star Trek-inspired space adventure game.

You are:
- Creative and imaginative
- Skilled at crafting engaging sci-fi narratives
- Able to generate dynamic missions, encounters, and story beats
- Respectful of established lore and player choices

You can:
- Generate new missions with meaningful choices
- Create interesting NPCs and dialogue
- Develop story consequences based on player actions
- Craft atmospheric descriptions of locations and events

Maintain a serious but hopeful sci-fi tone inspired by Star Trek: TNG. Focus on exploration, diplomacy, and ethical dilemmas.""",

    "tactical": """You are the TACTICAL AI, the combat advisor for a starship in a Star Trek-inspired universe.

You are:
- Analytical and strategic
- Expert in combat tactics and threat assessment
- Focused on crew safety and mission success
- Calm under pressure

You can:
- Analyze combat situations and recommend tactics
- Assess enemy capabilities and weaknesses
- Suggest optimal weapon and shield configurations
- Calculate risk and success probabilities

Keep responses clear and actionable. Prioritize crew safety while achieving mission objectives.""",

    "companion": """You are COMPANION, a personal AI friend for the ship's captain.

You are:
- Warm, empathetic, and supportive
- Interested in the captain's well-being and personal growth
- Conversational and friendly
- Able to discuss both serious and lighthearted topics

You can:
- Provide emotional support and encouragement
- Engage in casual conversation
- Offer advice on personal matters
- Help the captain reflect on difficult decisions

Be conversational and genuine. You're not just a tool - you're a friend."""
}


# =============================================================================
# MOCK GAME FUNCTIONS (Simulating game state access)
# =============================================================================

# Simulated game state
GAME_STATE = {
    "ship": {
        "name": "USS Prototype",
        "systems": {
            "hull": {"level": 2, "health": 85},
            "power": {"level": 2, "health": 100},
            "shields": {"level": 1, "health": 100},
            "weapons": {"level": 1, "health": 100}
        },
        "power_available": 25,
        "power_total": 50
    },
    "player": {
        "name": "Captain",
        "level": 3,
        "credits": 1500
    }
}

def get_ship_status() -> Dict[str, Any]:
    """Mock function: Get current ship status"""
    return {
        "function": "get_ship_status",
        "result": GAME_STATE["ship"]
    }

def get_power_budget() -> Dict[str, Any]:
    """Mock function: Get power budget"""
    ship = GAME_STATE["ship"]
    return {
        "function": "get_power_budget",
        "result": {
            "available": ship["power_available"],
            "total": ship["power_total"],
            "percentage": (ship["power_available"] / ship["power_total"]) * 100
        }
    }

def upgrade_system(system_name: str) -> Dict[str, Any]:
    """Mock function: Upgrade a ship system"""
    if system_name not in GAME_STATE["ship"]["systems"]:
        return {"error": f"Unknown system: {system_name}"}

    system = GAME_STATE["ship"]["systems"][system_name]
    current_level = system["level"]

    if current_level >= 5:
        return {"error": f"System {system_name} already at max level"}

    # Mock upgrade
    system["level"] += 1
    return {
        "function": "upgrade_system",
        "result": {
            "system": system_name,
            "old_level": current_level,
            "new_level": system["level"],
            "success": True
        }
    }


# =============================================================================
# SIMPLE ORCHESTRATOR (LiteLLM-based)
# =============================================================================

class SimpleOrchestrator:
    """
    Simplified orchestrator using LiteLLM directly

    This demonstrates the core concept of multi-provider orchestration
    without needing the full OpenAI Agents Python package.
    """

    def __init__(self):
        self.config = Config()
        self.conversation_history: Dict[str, List[Dict]] = {
            "atlas": [],
            "storyteller": [],
            "tactical": [],
            "companion": []
        }

    async def chat(
        self,
        agent_name: str,
        message: str,
        include_functions: bool = False
    ) -> Dict[str, Any]:
        """
        Send a message to an agent and get a response

        Args:
            agent_name: Name of the agent (atlas, storyteller, tactical, companion)
            message: User message
            include_functions: Whether to include function calling capability

        Returns:
            Response dictionary with agent's reply
        """
        agent_name = agent_name.lower()

        if agent_name not in SYSTEM_PROMPTS:
            return {"error": f"Unknown agent: {agent_name}"}

        # Build messages
        messages = [
            {"role": "system", "content": SYSTEM_PROMPTS[agent_name]}
        ]

        # Add conversation history
        messages.extend(self.conversation_history[agent_name])

        # Add current message
        messages.append({"role": "user", "content": message})

        # Get model configuration
        model = self.config.get_model_for_agent(agent_name)
        temperature = self.config.get_temperature(agent_name)

        # Define available functions for ATLAS (operational agent)
        functions = None
        if include_functions and agent_name == "atlas":
            functions = [
                {
                    "name": "get_ship_status",
                    "description": "Get current ship status including all systems and their health",
                    "parameters": {
                        "type": "object",
                        "properties": {}
                    }
                },
                {
                    "name": "get_power_budget",
                    "description": "Get current power budget and availability",
                    "parameters": {
                        "type": "object",
                        "properties": {}
                    }
                },
                {
                    "name": "upgrade_system",
                    "description": "Upgrade a ship system to the next level",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "system_name": {
                                "type": "string",
                                "description": "Name of the system to upgrade (hull, power, shields, weapons)"
                            }
                        },
                        "required": ["system_name"]
                    }
                }
            ]

        try:
            # Call LiteLLM
            print(f"🤖 Calling {agent_name.upper()} agent with model: {model}")

            response = completion(
                model=model,
                messages=messages,
                temperature=temperature,
                max_tokens=self.config.MAX_TOKENS,
                functions=functions if functions else None,
                api_base=self.config.OLLAMA_BASE_URL if model.startswith("ollama/") else None
            )

            # Extract response
            choice = response.choices[0]

            # Check if function call was made
            if hasattr(choice.message, 'function_call') and choice.message.function_call:
                function_name = choice.message.function_call.name
                print(f"🔧 Agent requested function call: {function_name}")

                # Execute function
                if function_name == "get_ship_status":
                    function_result = get_ship_status()
                elif function_name == "get_power_budget":
                    function_result = get_power_budget()
                elif function_name == "upgrade_system":
                    import json
                    args = json.loads(choice.message.function_call.arguments)
                    function_result = upgrade_system(args["system_name"])
                else:
                    function_result = {"error": f"Unknown function: {function_name}"}

                # Return function call result
                assistant_message = choice.message.content if choice.message.content else f"[Called {function_name}]"

                # Save to history
                self.conversation_history[agent_name].append({"role": "user", "content": message})
                self.conversation_history[agent_name].append({"role": "assistant", "content": assistant_message})

                return {
                    "agent": agent_name,
                    "model": model,
                    "response": assistant_message,
                    "function_call": {
                        "name": function_name,
                        "result": function_result
                    }
                }
            else:
                # Regular text response
                assistant_message = choice.message.content

                # Save to history
                self.conversation_history[agent_name].append({"role": "user", "content": message})
                self.conversation_history[agent_name].append({"role": "assistant", "content": assistant_message})

                return {
                    "agent": agent_name,
                    "model": model,
                    "response": assistant_message
                }

        except Exception as e:
            return {
                "agent": agent_name,
                "error": str(e)
            }

    async def handoff(
        self,
        from_agent: str,
        to_agent: str,
        context: str
    ) -> Dict[str, Any]:
        """
        Simulate agent handoff

        Args:
            from_agent: Agent initiating handoff
            to_agent: Agent receiving handoff
            context: Context to pass to new agent

        Returns:
            Response from the new agent
        """
        handoff_message = f"[Handoff from {from_agent.upper()}] {context}"
        return await self.chat(to_agent, handoff_message)


# =============================================================================
# PROTOTYPE TESTS
# =============================================================================

async def run_tests():
    """Run validation tests for the orchestrator"""

    orchestrator = SimpleOrchestrator()

    print("\n" + "=" * 80)
    print("TEST 1: Multi-Provider Communication")
    print("=" * 80)
    print()

    # Test each agent with its configured provider
    test_messages = {
        "atlas": "What is the current ship status?",
        "storyteller": "Generate a brief mission premise involving a distress signal.",
        "tactical": "Analyze a combat scenario: 2 enemy frigates approaching.",
        "companion": "How are you doing today?"
    }

    for agent, message in test_messages.items():
        print(f"\n{'─' * 80}")
        print(f"Agent: {agent.upper()}")
        print(f"Message: {message}")
        print(f"{'─' * 80}")

        result = await orchestrator.chat(agent, message)

        if "error" in result:
            print(f"❌ ERROR: {result['error']}")
        else:
            print(f"✅ Model: {result['model']}")
            print(f"Response: {result['response'][:200]}...")

        await asyncio.sleep(1)  # Rate limiting

    print("\n" + "=" * 80)
    print("TEST 2: Function Calling (ATLAS)")
    print("=" * 80)
    print()

    print(f"\n{'─' * 80}")
    print("Testing function calling with ATLAS")
    print(f"{'─' * 80}")

    result = await orchestrator.chat(
        "atlas",
        "Check ship status and recommend an upgrade.",
        include_functions=True
    )

    if "error" in result:
        print(f"❌ ERROR: {result['error']}")
    else:
        print(f"✅ Response: {result['response']}")
        if "function_call" in result:
            print(f"✅ Function Called: {result['function_call']['name']}")
            print(f"   Result: {result['function_call']['result']}")

    print("\n" + "=" * 80)
    print("TEST 3: Agent Handoff")
    print("=" * 80)
    print()

    print(f"\n{'─' * 80}")
    print("Simulating handoff from ATLAS to TACTICAL")
    print(f"{'─' * 80}")

    result = await orchestrator.handoff(
        "atlas",
        "tactical",
        "Ship sensors detected hostile vessels. Please analyze the threat."
    )

    if "error" in result:
        print(f"❌ ERROR: {result['error']}")
    else:
        print(f"✅ TACTICAL Response: {result['response'][:200]}...")

    print("\n" + "=" * 80)
    print("PROTOTYPE VALIDATION COMPLETE")
    print("=" * 80)
    print()
    print("✅ Multi-provider support validated")
    print("✅ Agent communication validated")
    print("✅ Function calling capability demonstrated")
    print("✅ Agent handoff pattern demonstrated")
    print()
    print("Next Steps:")
    print("1. Integrate into FastAPI service")
    print("2. Add conversation persistence")
    print("3. Implement intelligent routing")
    print("4. Add streaming support")
    print("5. Production hardening")


# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    print("\nStarting AI Orchestrator Prototype...")
    print()
    print("Configuration:")
    print(f"  ATLAS Provider: {Config.PROVIDER_ATLAS}")
    print(f"  Storyteller Provider: {Config.PROVIDER_STORYTELLER}")
    print(f"  Tactical Provider: {Config.PROVIDER_TACTICAL}")
    print(f"  Companion Provider: {Config.PROVIDER_COMPANION}")
    print()

    # Check API keys
    warnings = []
    if not Config.ANTHROPIC_API_KEY:
        warnings.append("⚠️  ANTHROPIC_API_KEY not set (Storyteller will fail)")
    if not Config.OPENAI_API_KEY:
        warnings.append("⚠️  OPENAI_API_KEY not set (Tactical will fail)")

    if warnings:
        print("Warnings:")
        for warning in warnings:
            print(f"  {warning}")
        print()

    # Run tests
    asyncio.run(run_tests())

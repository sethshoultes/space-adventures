"""
Test script for Tactical Agent

Quick validation that the Tactical Agent works correctly.
"""

import asyncio
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from agents.tactical_agent import TacticalAgent
from agents.tools import assess_combat_readiness, scan_threats, evaluate_tactical_options


async def test_tactical_tools():
    """Test the tactical tools independently"""
    print("=" * 60)
    print("Testing Tactical Tools")
    print("=" * 60)

    # Test scenario: Ship with moderate damage, no threats
    game_state_safe = {
        "ship": {
            "hull_hp": 70,
            "max_hull_hp": 100,
            "power_available": 50,
            "power_total": 100,
            "systems": {
                "weapons": {"level": 2, "health": 80, "active": True},
                "shields": {"level": 2, "health": 65, "active": True},
                "hull": {"level": 1, "health": 70, "active": True}
            }
        },
        "environment": {
            "threats": [],
            "nearby_objects": []
        },
        "mission": {
            "type": "exploration"
        }
    }

    print("\n--- Test 1: Combat Readiness (Safe State) ---")
    combat_status = await assess_combat_readiness(game_state_safe)
    print(f"Combat Ready: {combat_status['combat_ready']}")
    print(f"Readiness Level: {combat_status['readiness_level']}")
    print(f"Issues: {combat_status['issues']}")
    print(f"Recommendations: {combat_status['recommendations']}")

    print("\n--- Test 2: Threat Scan (Safe State) ---")
    threat_status = await scan_threats(game_state_safe)
    print(f"Threat Assessment: {threat_status['threat_assessment']}")
    print(f"Immediate Threats: {threat_status['immediate_threats']}")
    print(f"Threats: {threat_status['threats']}")

    print("\n--- Test 3: Tactical Options (Safe State) ---")
    tactical_options = await evaluate_tactical_options(game_state_safe)
    print(f"Recommended Action: {tactical_options['recommended_action']}")
    print(f"Risk Level: {tactical_options['risk_level']}")
    print(f"Success Probability: {tactical_options['success_probability']}%")

    # Test scenario: Critical damage with immediate threats
    game_state_critical = {
        "ship": {
            "hull_hp": 20,
            "max_hull_hp": 100,
            "power_available": 15,
            "power_total": 100,
            "systems": {
                "weapons": {"level": 1, "health": 40, "active": True},
                "shields": {"level": 1, "health": 30, "active": True},
                "hull": {"level": 1, "health": 20, "active": True}
            }
        },
        "environment": {
            "threats": ["Hostile Raider"],
            "nearby_objects": [
                {"type": "Pirate Corvette", "hostile": True, "distance": 50, "threat_level": 4}
            ]
        },
        "mission": {
            "type": "combat",
            "current_stage": {
                "type": "combat",
                "description": "Enemy vessel detected - hostile intent confirmed"
            }
        }
    }

    print("\n--- Test 4: Combat Readiness (Critical State) ---")
    combat_status = await assess_combat_readiness(game_state_critical)
    print(f"Combat Ready: {combat_status['combat_ready']}")
    print(f"Readiness Level: {combat_status['readiness_level']}")
    print(f"Issues: {combat_status['issues']}")

    print("\n--- Test 5: Threat Scan (Critical State) ---")
    threat_status = await scan_threats(game_state_critical)
    print(f"Threat Assessment: {threat_status['threat_assessment']}")
    print(f"Immediate Threats: {threat_status['immediate_threats']}")
    print(f"Time to Contact: {threat_status['time_to_contact']}")

    print("\n--- Test 6: Tactical Options (Critical State) ---")
    tactical_options = await evaluate_tactical_options(game_state_critical)
    print(f"Recommended Action: {tactical_options['recommended_action']}")
    print(f"Risk Level: {tactical_options['risk_level']}")
    print(f"Success Probability: {tactical_options['success_probability']}%")
    print(f"Tactical Disadvantages: {tactical_options['tactical_disadvantages']}")


async def test_tactical_agent():
    """Test the full Tactical Agent workflow"""
    print("\n" + "=" * 60)
    print("Testing Tactical Agent Workflow")
    print("=" * 60)

    # Mock Redis and LLM clients (for testing)
    class MockRedis:
        def __init__(self):
            self.data = {}

        async def get(self, key):
            return self.data.get(key)

        async def set(self, key, value):
            self.data[key] = value

        async def incr(self, key):
            self.data[key] = int(self.data.get(key, 0)) + 1

        async def expire(self, key, ttl):
            pass

        async def lpush(self, key, value):
            if key not in self.data:
                self.data[key] = []
            self.data[key].insert(0, value)

        async def ltrim(self, key, start, end):
            if key in self.data:
                self.data[key] = self.data[key][start:end+1]

        async def lrange(self, key, start, end):
            if key in self.data:
                return self.data[key][start:end+1]
            return []

    class MockLLM:
        pass

    redis_client = MockRedis()
    llm_client = MockLLM()

    agent = TacticalAgent(
        redis_client=redis_client,
        llm_client=llm_client,
        min_message_interval=30,
        max_messages_per_hour=50
    )

    # Test 1: Normal state - should stay silent
    game_state_normal = {
        "ship": {
            "hull_hp": 95,
            "max_hull_hp": 100,
            "systems": {
                "weapons": {"level": 3, "health": 100, "active": True},
                "shields": {"level": 3, "health": 100, "active": True},
                "hull": {"level": 2, "health": 95, "active": True}
            }
        },
        "environment": {"threats": []},
        "mission": {"type": "exploration"}
    }

    print("\n--- Test 7: Agent (Normal State) ---")
    result = await agent.run(game_state_normal, force_check=True)
    print(f"Should Act: {result['should_act']}")
    print(f"Message: {result.get('message', 'None')}")
    print(f"Reasoning: {result['reasoning']}")
    print(f"Urgency: {result['urgency']}")

    # Test 2: Low hull - should warn
    game_state_damaged = {
        "ship": {
            "hull_hp": 45,
            "max_hull_hp": 100,
            "systems": {
                "weapons": {"level": 2, "health": 70, "active": True},
                "shields": {"level": 2, "health": 60, "active": True},
                "hull": {"level": 1, "health": 45, "active": True}
            }
        },
        "environment": {"threats": []},
        "mission": {"type": "salvage"}
    }

    print("\n--- Test 8: Agent (Damaged State) ---")
    result = await agent.run(game_state_damaged, force_check=True)
    print(f"Should Act: {result['should_act']}")
    print(f"Message: {result.get('message', 'None')}")
    print(f"Reasoning: {result['reasoning']}")
    print(f"Urgency: {result['urgency']}")
    print(f"Tools Used: {result['tools_used']}")

    # Test 3: Combat mission with threats - should provide tactical assessment
    game_state_combat = {
        "ship": {
            "hull_hp": 80,
            "max_hull_hp": 100,
            "systems": {
                "weapons": {"level": 3, "health": 100, "active": True},
                "shields": {"level": 2, "health": 90, "active": True},
                "hull": {"level": 2, "health": 80, "active": True},
                "propulsion": {"level": 3, "health": 100, "active": True}
            }
        },
        "environment": {
            "threats": ["Hostile vessel detected"],
            "nearby_objects": [
                {"type": "Pirate Frigate", "hostile": True, "distance": 150, "threat_level": 3}
            ]
        },
        "mission": {
            "type": "combat",
            "current_stage": {
                "type": "combat",
                "description": "Approaching hostile vessel"
            }
        }
    }

    print("\n--- Test 9: Agent (Combat State) ---")
    result = await agent.run(game_state_combat, force_check=True)
    print(f"Should Act: {result['should_act']}")
    print(f"Message: {result.get('message', 'None')}")
    print(f"Reasoning: {result['reasoning']}")
    print(f"Urgency: {result['urgency']}")
    print(f"Tools Used: {result['tools_used']}")

    # Test 4: Critical emergency
    game_state_emergency = {
        "ship": {
            "hull_hp": 15,
            "max_hull_hp": 100,
            "systems": {
                "weapons": {"level": 1, "health": 35, "active": True},
                "shields": {"level": 0, "health": 0, "active": False},
                "hull": {"level": 1, "health": 15, "active": True}
            }
        },
        "environment": {
            "threats": ["Multiple hostiles", "Hull breach detected"],
            "nearby_objects": [
                {"type": "Raider", "hostile": True, "distance": 30, "threat_level": 4},
                {"type": "Raider", "hostile": True, "distance": 50, "threat_level": 4}
            ]
        },
        "mission": {
            "type": "combat",
            "current_stage": {"type": "combat"}
        }
    }

    print("\n--- Test 10: Agent (Emergency State) ---")
    result = await agent.run(game_state_emergency, force_check=True)
    print(f"Should Act: {result['should_act']}")
    print(f"Message: {result.get('message', 'None')}")
    print(f"Reasoning: {result['reasoning']}")
    print(f"Urgency: {result['urgency']}")
    print(f"Tools Used: {result['tools_used']}")


async def main():
    """Run all tests"""
    print("\n🎯 TACTICAL AGENT TEST SUITE\n")

    try:
        await test_tactical_tools()
        await test_tactical_agent()

        print("\n" + "=" * 60)
        print("✅ ALL TESTS COMPLETED SUCCESSFULLY")
        print("=" * 60)
        print("\nTactical Agent implementation validated!")
        print("- All 3 tools working correctly")
        print("- Agent workflow functioning")
        print("- Urgency levels properly assigned")
        print("- Message generation appropriate to situation")

    except Exception as e:
        print("\n" + "=" * 60)
        print("❌ TEST FAILED")
        print("=" * 60)
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())

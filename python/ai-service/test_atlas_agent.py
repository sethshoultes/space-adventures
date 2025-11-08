"""
Test ATLAS Agent

Simple test script to verify ATLAS agent works correctly.
"""

import asyncio
import redis.asyncio as redis
from src.agents.atlas_agent import ATLASAgent


# Mock LLM client (for testing without actual LLM)
class MockLLMClient:
    """Simple mock for testing"""
    async def completion(self, **kwargs):
        return {"choices": [{"message": {"content": "Mock response"}}]}


async def test_atlas_low_hull():
    """Test ATLAS detecting low hull"""
    print("\n=== TEST 1: Low Hull Detection ===")

    # Create Redis client
    redis_client = await redis.from_url("redis://localhost:6379", decode_responses=True)

    # Create agent
    agent = ATLASAgent(
        redis_client=redis_client,
        llm_client=MockLLMClient(),
        min_message_interval=1  # Short interval for testing
    )

    # Game state with low hull
    game_state = {
        "ship": {
            "hull_hp": 45,
            "max_hull_hp": 100,
            "power_available": 80,
            "power_total": 100,
            "systems": {
                "hull": {"level": 1, "health": 70, "active": True},
                "power": {"level": 1, "health": 100, "active": True},
                "propulsion": {"level": 1, "health": 50, "active": True}
            }
        },
        "mission": {},
        "environment": {}
    }

    # Run agent
    result = await agent.run(game_state, force_check=True)

    print(f"Should Act: {result['should_act']}")
    print(f"Urgency: {result['urgency']}")
    print(f"Tools Used: {result['tools_used']}")
    print(f"Reasoning: {result['reasoning']}")
    if result['message']:
        print(f"\nMessage:\n{result['message']}")
    else:
        print("\nNo message generated")

    await redis_client.close()


async def test_atlas_nominal():
    """Test ATLAS with nominal systems"""
    print("\n=== TEST 2: Nominal Systems ===")

    redis_client = await redis.from_url("redis://localhost:6379", decode_responses=True)

    agent = ATLASAgent(
        redis_client=redis_client,
        llm_client=MockLLMClient(),
        min_message_interval=1
    )

    # Game state with everything nominal
    game_state = {
        "ship": {
            "hull_hp": 100,
            "max_hull_hp": 100,
            "power_available": 90,
            "power_total": 100,
            "systems": {
                "hull": {"level": 1, "health": 100, "active": True},
                "power": {"level": 1, "health": 100, "active": True}
            }
        },
        "mission": {},
        "environment": {}
    }

    result = await agent.run(game_state, force_check=True)

    print(f"Should Act: {result['should_act']}")
    print(f"Urgency: {result['urgency']}")
    print(f"Tools Used: {result['tools_used']}")
    print(f"Reasoning: {result['reasoning']}")
    if result['message']:
        print(f"\nMessage:\n{result['message']}")
    else:
        print("\nNo message generated (expected)")

    await redis_client.close()


async def test_atlas_new_mission():
    """Test ATLAS detecting new mission"""
    print("\n=== TEST 3: New Mission Detection ===")

    redis_client = await redis.from_url("redis://localhost:6379", decode_responses=True)

    agent = ATLASAgent(
        redis_client=redis_client,
        llm_client=MockLLMClient(),
        min_message_interval=1
    )

    # Game state with active mission
    game_state = {
        "ship": {
            "hull_hp": 100,
            "max_hull_hp": 100,
            "power_available": 90,
            "power_total": 100,
            "systems": {}
        },
        "mission": {
            "title": "Cargo Escort: Gamma Route",
            "stage": "route_planning",
            "objectives": [
                {"text": "Choose safest route", "completed": False},
                {"text": "Protect convoy", "completed": False},
                {"text": "Deliver cargo intact", "completed": False}
            ]
        },
        "environment": {}
    }

    result = await agent.run(game_state, force_check=True)

    print(f"Should Act: {result['should_act']}")
    print(f"Urgency: {result['urgency']}")
    print(f"Tools Used: {result['tools_used']}")
    print(f"Reasoning: {result['reasoning']}")
    if result['message']:
        print(f"\nMessage:\n{result['message']}")
    else:
        print("\nNo message generated")

    await redis_client.close()


async def test_atlas_throttling():
    """Test throttling mechanism"""
    print("\n=== TEST 4: Throttling ===")

    redis_client = await redis.from_url("redis://localhost:6379", decode_responses=True)

    agent = ATLASAgent(
        redis_client=redis_client,
        llm_client=MockLLMClient(),
        min_message_interval=60  # 60 second minimum
    )

    game_state = {
        "ship": {"hull_hp": 40, "max_hull_hp": 100, "power_available": 80, "power_total": 100, "systems": {}},
        "mission": {},
        "environment": {}
    }

    # First call - should work
    result1 = await agent.run(game_state, force_check=True)
    print(f"First call - Should Act: {result1['should_act']}")

    # Second call immediately after - should be throttled
    result2 = await agent.run(game_state, force_check=False)
    print(f"Second call (no force) - Should Act: {result2['should_act']}")
    print(f"Reasoning: {result2['reasoning']}")

    # Third call with force - should work
    result3 = await agent.run(game_state, force_check=True)
    print(f"Third call (forced) - Should Act: {result3['should_act']}")

    await redis_client.close()


async def main():
    """Run all tests"""
    print("=" * 60)
    print("ATLAS Agent Test Suite")
    print("=" * 60)

    try:
        await test_atlas_low_hull()
        await test_atlas_nominal()
        await test_atlas_new_mission()
        await test_atlas_throttling()

        print("\n" + "=" * 60)
        print("All tests completed!")
        print("=" * 60)

    except Exception as e:
        print(f"\n❌ Error during testing: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(main())

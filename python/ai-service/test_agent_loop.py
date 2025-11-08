#!/usr/bin/env python3
"""
Test script for agent_loop endpoint

Tests the /api/orchestrator/agent_loop endpoint with example requests.
"""

import requests
import json
from typing import Dict, Any

BASE_URL = "http://localhost:17011"

def test_agent_loop_silent():
    """Test agent loop with nominal game state (should stay silent)"""
    print("\n" + "="*60)
    print("TEST 1: Agent Loop - Nominal State (Should Stay Silent)")
    print("="*60)

    request_data = {
        "agent": "atlas",
        "game_state": {
            "player": {
                "level": 3,
                "rank": "Lieutenant",
                "skills": {"engineering": 5, "diplomacy": 3}
            },
            "ship": {
                "hull_hp": 100,
                "max_hull_hp": 100,
                "power": 80,
                "max_power": 100,
                "systems": {
                    "hull": {"level": 1, "health": 100, "operational": True},
                    "power": {"level": 1, "health": 100, "operational": True}
                }
            },
            "mission": {
                "title": "Routine Patrol",
                "stage": "patrolling"
            },
            "environment": {
                "location": "Sector 7",
                "threats": []
            }
        },
        "force_check": False
    }

    print(f"\nRequest:")
    print(json.dumps(request_data, indent=2))

    try:
        response = requests.post(
            f"{BASE_URL}/api/orchestrator/agent_loop",
            json=request_data,
            timeout=10
        )

        print(f"\nResponse Status: {response.status_code}")
        print(f"Response:")
        print(json.dumps(response.json(), indent=2))

        # Validate response
        data = response.json()
        assert data["success"] == True, "Request should succeed"
        assert data["data"]["should_act"] == False, "Agent should stay silent with nominal state"
        assert data["data"]["message"] is None, "No message should be sent"
        print("\n✅ TEST PASSED: Agent correctly stayed silent")

    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")


def test_agent_loop_low_hull():
    """Test agent loop with low hull (should trigger message)"""
    print("\n" + "="*60)
    print("TEST 2: Agent Loop - Low Hull (Should Trigger Message)")
    print("="*60)

    request_data = {
        "agent": "atlas",
        "game_state": {
            "player": {
                "level": 3,
                "rank": "Lieutenant"
            },
            "ship": {
                "hull_hp": 45,
                "max_hull_hp": 100,
                "power": 80,
                "max_power": 100
            },
            "mission": {
                "title": "Cargo Escort",
                "stage": "route_planning"
            },
            "environment": {
                "location": "Gamma Route",
                "threats": []
            }
        },
        "force_check": True
    }

    print(f"\nRequest:")
    print(json.dumps(request_data, indent=2))

    try:
        response = requests.post(
            f"{BASE_URL}/api/orchestrator/agent_loop",
            json=request_data,
            timeout=10
        )

        print(f"\nResponse Status: {response.status_code}")
        print(f"Response:")
        print(json.dumps(response.json(), indent=2))

        # Validate response
        data = response.json()
        assert data["success"] == True, "Request should succeed"
        assert data["data"]["should_act"] == True, "Agent should act with low hull"
        assert data["data"]["message"] is not None, "Message should be generated"
        assert "hull" in data["data"]["message"].lower(), "Message should mention hull"
        assert data["data"]["urgency"] in ["MEDIUM", "URGENT"], "Urgency should be MEDIUM or URGENT"
        print("\n✅ TEST PASSED: Agent correctly detected low hull and generated message")

    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")


def test_agent_loop_critical_hull():
    """Test agent loop with critical hull (should trigger urgent message)"""
    print("\n" + "="*60)
    print("TEST 3: Agent Loop - Critical Hull (Should Trigger URGENT)")
    print("="*60)

    request_data = {
        "agent": "atlas",
        "game_state": {
            "player": {
                "level": 3,
                "rank": "Lieutenant"
            },
            "ship": {
                "hull_hp": 25,
                "max_hull_hp": 100,
                "power": 80
            },
            "mission": {
                "title": "Emergency Repair",
                "stage": "searching_for_parts"
            },
            "environment": {
                "location": "Debris Field",
                "threats": ["micrometeorites"]
            }
        },
        "force_check": True
    }

    print(f"\nRequest:")
    print(json.dumps(request_data, indent=2))

    try:
        response = requests.post(
            f"{BASE_URL}/api/orchestrator/agent_loop",
            json=request_data,
            timeout=10
        )

        print(f"\nResponse Status: {response.status_code}")
        print(f"Response:")
        print(json.dumps(response.json(), indent=2))

        # Validate response
        data = response.json()
        assert data["success"] == True, "Request should succeed"
        assert data["data"]["should_act"] == True, "Agent should act with critical hull"
        assert data["data"]["urgency"] == "URGENT", "Urgency should be URGENT"
        print("\n✅ TEST PASSED: Agent correctly detected critical hull")

    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")


def test_agent_loop_invalid_agent():
    """Test agent loop with invalid agent name"""
    print("\n" + "="*60)
    print("TEST 4: Agent Loop - Invalid Agent (Should Fail)")
    print("="*60)

    request_data = {
        "agent": "invalid_agent",
        "game_state": {
            "player": {},
            "ship": {}
        }
    }

    print(f"\nRequest:")
    print(json.dumps(request_data, indent=2))

    try:
        response = requests.post(
            f"{BASE_URL}/api/orchestrator/agent_loop",
            json=request_data,
            timeout=10
        )

        print(f"\nResponse Status: {response.status_code}")
        print(f"Response:")
        print(json.dumps(response.json(), indent=2))

        assert response.status_code == 400, "Should return 400 for invalid agent"
        print("\n✅ TEST PASSED: Invalid agent correctly rejected")

    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")


def test_health_check():
    """Test health check includes scheduler info"""
    print("\n" + "="*60)
    print("TEST 5: Health Check - Scheduler Status")
    print("="*60)

    try:
        response = requests.get(
            f"{BASE_URL}/health",
            timeout=10
        )

        print(f"\nResponse Status: {response.status_code}")
        data = response.json()

        # Check scheduler info
        assert "scheduler" in data, "Health check should include scheduler info"
        assert "status" in data["scheduler"], "Scheduler should have status"
        assert "jobs" in data["scheduler"], "Scheduler should list jobs"

        print(f"\nScheduler Status: {data['scheduler']['status']}")
        print(f"Scheduled Jobs: {len(data['scheduler']['jobs'])}")
        for job in data["scheduler"]["jobs"]:
            print(f"  - {job['name']} (ID: {job['id']}, Next: {job['next_run']})")

        print("\n✅ TEST PASSED: Health check includes scheduler information")

    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")


if __name__ == "__main__":
    print("\n" + "="*60)
    print("AGENT LOOP ENDPOINT TESTS")
    print("="*60)
    print(f"Testing endpoint: {BASE_URL}/api/orchestrator/agent_loop")
    print("\nMake sure the AI service is running:")
    print("  cd python/ai-service && source venv/bin/activate && python main.py")
    print("\n" + "="*60)

    # Run tests
    test_health_check()
    test_agent_loop_silent()
    test_agent_loop_low_hull()
    test_agent_loop_critical_hull()
    test_agent_loop_invalid_agent()

    print("\n" + "="*60)
    print("ALL TESTS COMPLETED")
    print("="*60 + "\n")

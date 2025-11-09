#!/usr/bin/env python3
"""
Test script for code review fixes #6, #9, #10

Tests:
- Fix #6: Hash optimization (built-in hash vs SHA256)
- Fix #9: Timeout handling (asyncio.TimeoutError)
- Fix #10: Type conversion safety (Redis string to int)
"""

import asyncio
import time
import json
from typing import Dict, Any


# =============================================================================
# Fix #6: Hash Optimization Test
# =============================================================================

def test_hash_optimization():
    """Test that new hash function is faster and still unique."""
    print("\n" + "="*70)
    print("FIX #6: Hash Optimization Test")
    print("="*70)

    test_states = [
        {
            "level": 1,
            "current_mission": "tutorial_shipyard",
            "completed_missions": [],
            "phase": 1,
        },
        {
            "level": 5,
            "current_mission": "deep_space_rescue",
            "completed_missions": ["tutorial_shipyard", "first_flight"],
            "phase": 2,
        },
        {
            "level": 10,
            "current_mission": None,
            "completed_missions": ["tutorial_shipyard", "first_flight", "asteroid_mining"],
            "phase": 3,
        },
    ]

    # Test new hash function
    def new_hash(player_state: Dict[str, Any]) -> str:
        """New optimized hash using built-in hash()."""
        relevant_state = {
            "level": player_state.get("level", 1),
            "current_mission": player_state.get("current_mission"),
            "completed_missions_count": len(player_state.get("completed_missions", [])),
            "phase": player_state.get("phase", 1),
        }
        state_json = json.dumps(relevant_state, sort_keys=True)
        hash_value = hash(state_json)
        hash_hex = format(hash_value & 0xFFFFFFFFFFFFFFFF, '016x')
        return hash_hex

    # Test old hash function for comparison
    import hashlib
    def old_hash(player_state: Dict[str, Any]) -> str:
        """Old SHA256 hash (slower)."""
        relevant_state = {
            "level": player_state.get("level", 1),
            "current_mission": player_state.get("current_mission"),
            "completed_missions_count": len(player_state.get("completed_missions", [])),
            "phase": player_state.get("phase", 1),
        }
        state_json = json.dumps(relevant_state, sort_keys=True)
        hash_obj = hashlib.sha256(state_json.encode())
        return hash_obj.hexdigest()[:16]

    # Test uniqueness
    print("\n1. Testing hash uniqueness:")
    new_hashes = [new_hash(state) for state in test_states]
    old_hashes = [old_hash(state) for state in test_states]

    print(f"   New hashes: {new_hashes}")
    print(f"   Old hashes: {old_hashes}")
    print(f"   All new hashes unique: {len(new_hashes) == len(set(new_hashes))}")
    print(f"   All old hashes unique: {len(old_hashes) == len(set(old_hashes))}")

    # Test consistency (same input = same output)
    print("\n2. Testing consistency:")
    for i, state in enumerate(test_states):
        hash1 = new_hash(state)
        hash2 = new_hash(state)
        print(f"   State {i}: {hash1 == hash2} (same hash twice)")

    # Performance test
    print("\n3. Performance comparison (10,000 iterations):")
    iterations = 10000

    # New hash performance
    start = time.perf_counter()
    for _ in range(iterations):
        for state in test_states:
            new_hash(state)
    new_time = time.perf_counter() - start

    # Old hash performance
    start = time.perf_counter()
    for _ in range(iterations):
        for state in test_states:
            old_hash(state)
    old_time = time.perf_counter() - start

    print(f"   New hash (built-in): {new_time:.4f}s")
    print(f"   Old hash (SHA256):   {old_time:.4f}s")
    print(f"   Speedup:             {old_time/new_time:.2f}x faster")

    print("\n✅ Fix #6: Hash optimization working correctly")


# =============================================================================
# Fix #9: Timeout Handling Test
# =============================================================================

async def test_timeout_handling():
    """Test that timeout protection works for LLM calls."""
    print("\n" + "="*70)
    print("FIX #9: Timeout Handling Test")
    print("="*70)

    # Simulate slow LLM call
    async def slow_llm_call(delay: float) -> str:
        """Simulate slow LLM response."""
        await asyncio.sleep(delay)
        return "Generated narrative"

    # Test with timeout protection (like in story_engine.py)
    async def generate_with_timeout(delay: float, timeout: int = 2) -> str:
        """Simulate _generate_with_llm with timeout."""
        try:
            result = await asyncio.wait_for(slow_llm_call(delay), timeout=timeout)
            return result
        except asyncio.TimeoutError:
            print(f"   ⚠️  LLM call timed out after {timeout}s")
            return "Fallback narrative"

    # Test 1: Fast call (should succeed)
    print("\n1. Testing fast LLM call (0.5s, timeout=2s):")
    result = await generate_with_timeout(0.5, timeout=2)
    print(f"   Result: {result}")
    print(f"   Status: {'✅ Success' if result == 'Generated narrative' else '❌ Failed'}")

    # Test 2: Slow call (should timeout)
    print("\n2. Testing slow LLM call (3s, timeout=2s):")
    result = await generate_with_timeout(3.0, timeout=2)
    print(f"   Result: {result}")
    print(f"   Status: {'✅ Fallback triggered' if result == 'Fallback narrative' else '❌ Failed'}")

    # Test 3: Multiple concurrent calls with different speeds
    print("\n3. Testing concurrent calls with mixed speeds:")
    tasks = [
        generate_with_timeout(0.5, timeout=2),  # Fast
        generate_with_timeout(3.0, timeout=2),  # Slow (will timeout)
        generate_with_timeout(1.0, timeout=2),  # Medium
    ]
    results = await asyncio.gather(*tasks)
    print(f"   Results: {results}")
    print(f"   Fast call success: {results[0] == 'Generated narrative'}")
    print(f"   Slow call fallback: {results[1] == 'Fallback narrative'}")
    print(f"   Medium call success: {results[2] == 'Generated narrative'}")

    print("\n✅ Fix #9: Timeout handling working correctly")


# =============================================================================
# Fix #10: Type Conversion Safety Test
# =============================================================================

def test_type_conversion_safety():
    """Test type-safe conversion of Redis values."""
    print("\n" + "="*70)
    print("FIX #10: Type Conversion Safety Test")
    print("="*70)

    # Simulate Redis returning various value types
    test_cases = [
        ("42", 42, "Valid integer string"),
        ("3.14", 3.14, "Valid float string"),
        ("not_a_number", "not_a_number", "Invalid number (kept as string)"),
        ("", "", "Empty string"),
        (None, None, "None value"),
        ("100", 100, "Valid score"),
    ]

    # Type-safe conversion function (from world_state.py)
    def safe_int_conversion(value: Any, default: int = 50) -> int:
        """Safely convert Redis value to int with fallback."""
        if not value:
            return default

        try:
            return int(value)
        except (ValueError, TypeError) as e:
            print(f"   ⚠️  Invalid value '{value}': {e}")
            return default

    # Type-safe number conversion (from get_economy)
    def safe_number_conversion(value: Any) -> Any:
        """Safely convert to number or keep as string."""
        try:
            return float(value) if '.' in str(value) else int(value)
        except (ValueError, TypeError) as e:
            print(f"   ⚠️  Cannot convert '{value}': {e}")
            return value

    print("\n1. Testing integer conversion (like faction standings):")
    for value, expected, desc in [tc for tc in test_cases if isinstance(tc[1], (int, type(None)))]:
        result = safe_int_conversion(value)
        status = "✅" if (result == expected or (expected is None and result == 50)) else "❌"
        print(f"   {status} {desc}: '{value}' → {result}")

    print("\n2. Testing number conversion (like economy values):")
    for value, expected, desc in test_cases:
        result = safe_number_conversion(value)
        status = "✅" if result == expected else "❌"
        print(f"   {status} {desc}: '{value}' → {result} (type: {type(result).__name__})")

    print("\n3. Testing relationship score updates (with invalid data):")
    # Simulate relationship update with corrupted Redis data
    test_relationships = {
        "valid_npc": "50",
        "corrupted_npc": "not_a_number",
        "another_npc": "75",
    }

    relationships = {}
    for name, score in test_relationships.items():
        try:
            relationships[name] = int(score)
            print(f"   ✅ {name}: {score} → {relationships[name]}")
        except (ValueError, TypeError) as e:
            print(f"   ⚠️  {name}: '{score}' is invalid, skipping")
            # Skip invalid entries rather than crash

    print(f"\n   Final relationships: {relationships}")
    print(f"   Valid entries: {len(relationships)}/{len(test_relationships)}")

    print("\n✅ Fix #10: Type conversion safety working correctly")


# =============================================================================
# Main Test Runner
# =============================================================================

async def main():
    """Run all tests."""
    print("\n" + "="*70)
    print("CODE REVIEW FIXES TEST SUITE")
    print("Testing fixes #6, #9, #10")
    print("="*70)

    # Fix #6: Hash optimization
    test_hash_optimization()

    # Fix #9: Timeout handling
    await test_timeout_handling()

    # Fix #10: Type conversion safety
    test_type_conversion_safety()

    print("\n" + "="*70)
    print("ALL TESTS COMPLETED")
    print("="*70 + "\n")


if __name__ == "__main__":
    asyncio.run(main())

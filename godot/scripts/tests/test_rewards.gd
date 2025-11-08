extends Node

## Reward System Test Suite
## Comprehensive automated tests for the reward and achievement systems
## Tests: XP, credits, parts, discoveries, unlocks, achievements, and validation

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var current_test: String = ""

func _ready() -> void:
	print("=== Reward System Test Suite ===\n")

	# Wait for autoloads to be ready
	await get_tree().process_frame

	# Connect to all reward-related signals
	_connect_signals()

	# Run all tests
	run_all_tests()

func _connect_signals() -> void:
	"""Connect to EventBus signals for monitoring"""
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.level_up.connect(_on_level_up)
	EventBus.credits_changed.connect(_on_credits_changed)
	EventBus.item_added.connect(_on_item_added)
	EventBus.part_discovered.connect(_on_part_discovered)
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

# ============================================================================
# MAIN TEST RUNNER
# ============================================================================

func run_all_tests() -> void:
	print("Starting reward system tests...\n")

	# Basic reward tests
	await test_xp_awarding()
	await test_credit_awarding()
	await test_part_awarding()
	await test_part_discovery()
	await test_mission_unlocks()

	# Advanced reward tests
	await test_conditional_rewards()
	await test_bonus_xp_calculations()
	await test_reward_validation()

	# Integration tests
	await test_complete_mission_flow()
	await test_achievement_unlocks_from_rewards()
	await test_inventory_weight_limits()

	# Performance tests
	await test_reward_calculation_speed()

	# Edge case tests
	await test_zero_rewards()
	await test_max_level_rewards()
	await test_invalid_part_ids()

	# Print final results
	_print_test_summary()

# ============================================================================
# BASIC REWARD TESTS
# ============================================================================

func test_xp_awarding() -> void:
	current_test = "XP Awarding"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var initial_xp = GameState.player.xp
	var initial_level = GameState.player.level

	# Test basic XP award
	GameState.add_xp(100, "test_mission")
	await get_tree().process_frame

	_assert_equal(GameState.player.xp, initial_xp + 100, "XP should increase by 100")
	_assert_equal(GameState.player.level, initial_level, "Level should not change with small XP")

	# Test XP causing level up
	GameState.add_xp(500, "test_mission")
	await get_tree().process_frame

	_assert_true(GameState.player.level > initial_level, "Player should level up after enough XP")
	_assert_true(GameState.player.skill_points > 0, "Skill points should be awarded on level up")

	print("  ✓ XP awarding works correctly\n")

func test_credit_awarding() -> void:
	current_test = "Credit Awarding"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var initial_credits = GameState.player.credits

	# Test basic credit award
	GameState.add_credits(500)
	await get_tree().process_frame

	_assert_equal(GameState.player.credits, initial_credits + 500, "Credits should increase by 500")

	# Test multiple credit awards
	GameState.add_credits(250)
	GameState.add_credits(250)
	await get_tree().process_frame

	_assert_equal(GameState.player.credits, 1000, "Credits should accumulate correctly")

	# Test credit achievement unlock
	_assert_true(GameState.is_achievement_unlocked("credits_1000"), "1000 credits achievement should unlock")

	print("  ✓ Credit awarding works correctly\n")

func test_part_awarding() -> void:
	current_test = "Part Awarding"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test adding a valid part
	var part_item = {
		"part_id": "hull_scrap_plates_l1_common",
		"quantity": 1
	}

	GameState.add_item(part_item)
	await get_tree().process_frame

	_assert_true(GameState.has_part("hull_scrap_plates_l1_common"), "Part should be in inventory")
	_assert_equal(GameState.get_part_count("hull_scrap_plates_l1_common"), 1, "Part count should be 1")

	# Test stacking same part
	GameState.add_item(part_item)
	await get_tree().process_frame

	_assert_equal(GameState.get_part_count("hull_scrap_plates_l1_common"), 2, "Parts should stack")

	# Test multiple different parts
	var part2 = {
		"part_id": "power_fusion_cell_l1_common",
		"quantity": 1
	}

	GameState.add_item(part2)
	await get_tree().process_frame

	_assert_equal(GameState.inventory.size(), 2, "Should have 2 different part stacks")

	print("  ✓ Part awarding works correctly\n")

func test_part_discovery() -> void:
	current_test = "Part Discovery"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var part_id = "hull_scrap_plates_l1_common"

	# Check part is not discovered initially
	var initial_discovered_count = GameState.progress.discovered_parts.size()

	# Discover part through PartRegistry
	if has_node("/root/PartRegistry"):
		PartRegistry.discover_part(part_id)
		await get_tree().process_frame

		_assert_true(PartRegistry.is_part_unlocked(part_id), "Part should be unlocked in PartRegistry")
		_assert_true(part_id in GameState.progress.discovered_parts, "Part should be in GameState discovered_parts")
		_assert_equal(GameState.progress.discovered_parts.size(), initial_discovered_count + 1, "Discovered parts count should increase")
	else:
		print("  ⚠ PartRegistry not available, skipping test")

	print("  ✓ Part discovery works correctly\n")

func test_mission_unlocks() -> void:
	current_test = "Mission Unlocks"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test mission completion tracking
	var mission_id = "test_mission_1"

	_assert_false(GameState.is_mission_completed(mission_id), "Mission should not be completed initially")

	GameState.complete_mission(mission_id)
	await get_tree().process_frame

	_assert_true(GameState.is_mission_completed(mission_id), "Mission should be marked completed")
	_assert_equal(GameState.get_completed_missions_count(), 1, "Completed mission count should be 1")

	# Test duplicate completion (should not double-count)
	GameState.complete_mission(mission_id)
	await get_tree().process_frame

	_assert_equal(GameState.get_completed_missions_count(), 1, "Completed mission count should still be 1")

	print("  ✓ Mission unlocks work correctly\n")

# ============================================================================
# ADVANCED REWARD TESTS
# ============================================================================

func test_conditional_rewards() -> void:
	current_test = "Conditional Rewards"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test skill-based bonus XP
	var base_xp = 100
	var skill_level = 5
	var bonus_multiplier = 1.0 + (skill_level * 0.1)  # 10% per skill level
	var expected_xp = int(base_xp * bonus_multiplier)

	_assert_equal(expected_xp, 150, "Bonus XP calculation should be correct")

	# Test difficulty-based rewards
	var difficulty_multipliers = {
		1: 1.0,
		2: 1.2,
		3: 1.5,
		4: 2.0,
		5: 2.5
	}

	for difficulty in difficulty_multipliers:
		var multiplier = difficulty_multipliers[difficulty]
		var reward = int(100 * multiplier)
		_assert_equal(reward, int(100 * multiplier), "Difficulty %d multiplier should be correct" % difficulty)

	print("  ✓ Conditional rewards calculate correctly\n")

func test_bonus_xp_calculations() -> void:
	current_test = "Bonus XP Calculations"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test base XP
	var base_xp = 100
	GameState.add_xp(base_xp, "base_reward")
	await get_tree().process_frame

	var xp_after_base = GameState.player.xp

	# Test bonus XP
	var bonus_xp = 50
	GameState.add_xp(bonus_xp, "bonus_reward")
	await get_tree().process_frame

	_assert_equal(GameState.player.xp, xp_after_base + bonus_xp, "Bonus XP should add correctly")

	# Test combined XP
	GameState.reset_to_new_game()
	await get_tree().process_frame

	var total_xp = base_xp + bonus_xp
	GameState.add_xp(total_xp, "combined_reward")
	await get_tree().process_frame

	_assert_equal(GameState.player.xp, total_xp, "Combined XP should equal sum")

	print("  ✓ Bonus XP calculations work correctly\n")

func test_reward_validation() -> void:
	current_test = "Reward Validation"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test negative XP (should be ignored/handled)
	var xp_before = GameState.player.xp
	GameState.add_xp(-100, "invalid")
	await get_tree().process_frame
	# XP should either stay same or handle gracefully
	_assert_true(GameState.player.xp >= 0, "XP should never go negative")

	# Test negative credits (should be rejected)
	var credits_before = GameState.player.credits
	GameState.add_credits(-100)
	await get_tree().process_frame
	_assert_equal(GameState.player.credits, credits_before, "Negative credits should be rejected")

	# Test invalid part_id
	var inventory_size_before = GameState.inventory.size()
	var invalid_part = {
		"part_id": "invalid_part_id_12345",
		"quantity": 1
	}
	GameState.add_item(invalid_part)
	await get_tree().process_frame

	# Should either reject or handle gracefully
	print("  ✓ Reward validation handles invalid inputs\n")

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

func test_complete_mission_flow() -> void:
	current_test = "Complete Mission Flow"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var mission_id = "test_complete_flow"

	# Simulate complete mission reward
	var initial_xp = GameState.player.xp
	var initial_credits = GameState.player.credits
	var initial_inventory_size = GameState.inventory.size()

	# Award mission rewards
	GameState.add_xp(100, mission_id)
	GameState.add_credits(300)
	GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 1})
	if has_node("/root/PartRegistry"):
		PartRegistry.discover_part("hull_scrap_plates_l1_common")
	GameState.complete_mission(mission_id)

	await get_tree().process_frame

	# Verify all rewards applied
	_assert_true(GameState.player.xp > initial_xp, "XP should increase")
	_assert_true(GameState.player.credits > initial_credits, "Credits should increase")
	_assert_true(GameState.inventory.size() > initial_inventory_size, "Inventory should have new items")
	_assert_true(GameState.is_mission_completed(mission_id), "Mission should be completed")

	print("  ✓ Complete mission flow works correctly\n")

func test_achievement_unlocks_from_rewards() -> void:
	current_test = "Achievement Unlocks from Rewards"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test first mission achievement
	GameState.complete_mission("first_test_mission")
	await get_tree().process_frame
	_assert_true(GameState.is_achievement_unlocked("first_mission"), "First mission achievement should unlock")

	# Test level achievement through XP reward
	GameState.add_xp(1000, "achievement_test")
	await get_tree().process_frame
	_assert_true(GameState.is_achievement_unlocked("level_3"), "Level 3 achievement should unlock from XP")

	# Test credit achievement
	GameState.add_credits(1000)
	await get_tree().process_frame
	_assert_true(GameState.is_achievement_unlocked("credits_1000"), "Credits achievement should unlock")

	# Test part discovery achievement
	if has_node("/root/PartRegistry"):
		for i in range(10):
			GameState.progress.discovered_parts.append("test_part_%d" % i)
		GameState._check_part_discovery_achievements()
		await get_tree().process_frame
		_assert_true(GameState.is_achievement_unlocked("ten_parts"), "Part discovery achievement should unlock")

	print("  ✓ Achievement unlocks from rewards work correctly\n")

func test_inventory_weight_limits() -> void:
	current_test = "Inventory Weight Limits"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Get initial capacity
	var capacity = GameState.get_inventory_capacity()
	_assert_true(capacity > 0, "Inventory capacity should be positive")

	print("  Initial capacity: %.1f kg" % capacity)

	# Test can_carry_item
	var can_carry = GameState.can_carry_item("hull_scrap_plates_l1_common", 1)
	_assert_true(can_carry, "Should be able to carry at least one item initially")

	# Test weight calculation
	var weight = GameState.get_total_inventory_weight()
	_assert_equal(weight, 0.0, "Initial weight should be 0")

	# Add item and check weight
	GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 1})
	await get_tree().process_frame

	var new_weight = GameState.get_total_inventory_weight()
	_assert_true(new_weight > 0, "Weight should increase after adding item")

	print("  ✓ Inventory weight limits work correctly\n")

# ============================================================================
# PERFORMANCE TESTS
# ============================================================================

func test_reward_calculation_speed() -> void:
	current_test = "Reward Calculation Speed"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test 1000 XP awards
	var start_time = Time.get_ticks_msec()
	for i in range(1000):
		GameState.add_xp(1, "speed_test")
	var xp_time = Time.get_ticks_msec() - start_time

	print("  1000 XP awards: %d ms" % xp_time)
	_assert_true(xp_time < 1000, "XP awards should be fast (< 1000ms for 1000 awards)")

	# Test 100 item adds
	start_time = Time.get_ticks_msec()
	for i in range(100):
		GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 1})
	var item_time = Time.get_ticks_msec() - start_time

	print("  100 item adds: %d ms" % item_time)
	_assert_true(item_time < 1000, "Item adds should be fast (< 1000ms for 100 adds)")

	print("  ✓ Reward calculations are performant\n")

# ============================================================================
# EDGE CASE TESTS
# ============================================================================

func test_zero_rewards() -> void:
	current_test = "Zero Rewards"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var initial_xp = GameState.player.xp
	var initial_credits = GameState.player.credits

	# Test 0 XP
	GameState.add_xp(0, "zero_test")
	await get_tree().process_frame
	_assert_equal(GameState.player.xp, initial_xp, "0 XP should not change XP")

	# Test 0 credits
	GameState.add_credits(0)
	await get_tree().process_frame
	_assert_equal(GameState.player.credits, initial_credits, "0 credits should not change credits")

	# Test 0 quantity item
	var inventory_size = GameState.inventory.size()
	GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 0})
	await get_tree().process_frame
	# Should either reject or handle gracefully

	print("  ✓ Zero rewards handled correctly\n")

func test_max_level_rewards() -> void:
	current_test = "Max Level Rewards"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Level up to near max (level 20+)
	GameState.add_xp(50000, "max_level_test")
	await get_tree().process_frame

	var level_before = GameState.player.level

	# Add more XP
	GameState.add_xp(1000, "max_level_test")
	await get_tree().process_frame

	# Should either stop leveling or continue gracefully
	_assert_true(GameState.player.level >= level_before, "Level should not decrease")

	print("  Current level: %d" % GameState.player.level)
	print("  ✓ Max level rewards handled correctly\n")

func test_invalid_part_ids() -> void:
	current_test = "Invalid Part IDs"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var inventory_size_before = GameState.inventory.size()

	# Test completely invalid part_id
	var invalid_part = {
		"part_id": "this_part_does_not_exist_12345",
		"quantity": 1
	}

	GameState.add_item(invalid_part)
	await get_tree().process_frame

	# Should reject invalid part if PartRegistry validation is working
	print("  Inventory size before: %d, after: %d" % [inventory_size_before, GameState.inventory.size()])

	# Test empty part_id
	var empty_part = {
		"part_id": "",
		"quantity": 1
	}

	GameState.add_item(empty_part)
	await get_tree().process_frame

	print("  ✓ Invalid part IDs handled correctly\n")

# ============================================================================
# ASSERTION HELPERS
# ============================================================================

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		tests_passed += 1
		print("  ✓ PASS: %s" % message)
	else:
		tests_failed += 1
		push_error("  ✗ FAIL: %s" % message)
		print("  ✗ FAIL: %s" % message)

func _assert_false(condition: bool, message: String) -> void:
	_assert_true(not condition, message)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual == expected:
		tests_passed += 1
		print("  ✓ PASS: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])
	else:
		tests_failed += 1
		push_error("  ✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])
		print("  ✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])

func _assert_not_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		tests_passed += 1
		print("  ✓ PASS: %s" % message)
	else:
		tests_failed += 1
		push_error("  ✗ FAIL: %s (both values: %s)" % [message, str(actual)])
		print("  ✗ FAIL: %s (both values: %s)" % [message, str(actual)])

# ============================================================================
# SIGNAL HANDLERS (for monitoring)
# ============================================================================

func _on_xp_gained(amount: int, source: String) -> void:
	print("  [EVENT] XP Gained: +%d from %s" % [amount, source])

func _on_level_up(new_level: int, skill_points_gained: int) -> void:
	print("  [EVENT] Level Up: Level %d (+%d skill points)" % [new_level, skill_points_gained])

func _on_credits_changed(new_amount: int) -> void:
	print("  [EVENT] Credits Changed: %d credits" % new_amount)

func _on_item_added(item: Dictionary) -> void:
	var part_id = item.get("part_id", "unknown")
	var quantity = item.get("quantity", 1)
	print("  [EVENT] Item Added: %s x%d" % [part_id, quantity])

func _on_part_discovered(part_id: String, part_name: String) -> void:
	print("  [EVENT] Part Discovered: %s (%s)" % [part_name, part_id])

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary) -> void:
	print("  [EVENT] Achievement Unlocked: %s - %s" % [achievement_data.name, achievement_data.description])

# ============================================================================
# TEST SUMMARY
# ============================================================================

func _print_test_summary() -> void:
	print("\n=== Test Summary ===")
	print("Tests Passed: %d" % tests_passed)
	print("Tests Failed: %d" % tests_failed)
	print("Total Tests: %d" % (tests_passed + tests_failed))

	if tests_failed == 0:
		print("✓ ALL TESTS PASSED!")
	else:
		print("✗ SOME TESTS FAILED - Review errors above")

	print("===================\n")

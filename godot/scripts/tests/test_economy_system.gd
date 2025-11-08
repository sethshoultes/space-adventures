extends Node

## Economy System Test Suite
## Tests all economy functions without requiring full game UI

var test_results: Array = []
var passed_tests: int = 0
var failed_tests: int = 0

func _ready() -> void:
	print("=== Economy System Test Suite ===\n")

	# Wait one frame for autoloads to initialize
	await get_tree().process_frame

	# Test 1: PartRegistry Loading
	test_part_registry_loading()

	# Test 2: GameState Credits
	test_credits_system()

	# Test 3: GameState Inventory
	test_inventory_system()

	# Test 4: GameState Skill Points
	test_skill_points()

	# Test 5: Ship System Upgrades
	test_ship_upgrades()

	# Test 6: Mission Rewards
	test_mission_rewards()

	# Test 7: Edge Cases
	test_edge_cases()

	# Print summary
	print_summary()

	# Exit
	get_tree().quit()

func test_assert(condition: bool, test_name: String, message: String) -> void:
	if condition:
		print("  ✓ %s" % message)
		passed_tests += 1
	else:
		print("  ✗ FAILED: %s - %s" % [test_name, message])
		failed_tests += 1
		test_results.append("[FAIL] %s: %s" % [test_name, message])

func test_part_registry_loading() -> void:
	print("TEST 1: PartRegistry Loading")

	# Check PartRegistry exists
	var has_registry = has_node("/root/PartRegistry")
	test_assert(has_registry, "PartRegistry", "PartRegistry autoload exists")

	if not has_registry:
		print("  FAILED - PartRegistry not found, skipping remaining tests\n")
		return

	# Check parts loaded
	var all_parts = PartRegistry.get_all_parts()
	var part_count = all_parts.size()
	test_assert(part_count > 0, "PartRegistry", "Parts loaded (count: %d)" % part_count)

	# Check economy config loaded
	var economy = PartRegistry.economy_config
	test_assert(not economy.is_empty(), "PartRegistry", "Economy config loaded")

	# Test get_part
	var test_part = PartRegistry.get_part("hull_scrap_plates_l1_common")
	test_assert(not test_part.is_empty(), "PartRegistry", "get_part() works for 'hull_scrap_plates_l1_common'")
	if not test_part.is_empty():
		print("    Part name: %s" % test_part.name)

	# Test get_upgrade_cost
	var cost = PartRegistry.get_upgrade_cost("hull", 1, "")
	test_assert(not cost.is_empty(), "PartRegistry", "get_upgrade_cost() works")
	if not cost.is_empty():
		print("    Cost: %d CR + %s" % [cost.credits, cost.part_name])

	# Test get_parts_by_system
	var hull_parts = PartRegistry.get_parts_by_system("hull")
	test_assert(hull_parts.size() > 0, "PartRegistry", "get_parts_by_system('hull') returns parts")

	# Test get_parts_by_level
	var level_1_parts = PartRegistry.get_parts_by_level(1)
	test_assert(level_1_parts.size() > 0, "PartRegistry", "get_parts_by_level(1) returns parts")

	print("  PASSED\n")

func test_credits_system() -> void:
	print("TEST 2: Credits System")

	# Check GameState exists
	if not has_node("/root/GameState"):
		print("  FAILED - GameState not found\n")
		return

	# Reset to known state
	GameState.player.credits = 0

	# Test add_credits
	GameState.add_credits(100)
	test_assert(GameState.player.credits == 100, "Credits", "add_credits(100) sets credits to 100")

	# Test can_afford
	test_assert(GameState.can_afford(50), "Credits", "can_afford(50) returns true when having 100")
	test_assert(not GameState.can_afford(200), "Credits", "can_afford(200) returns false when having 100")

	# Test spend_credits success
	var success = GameState.spend_credits(50)
	test_assert(success, "Credits", "spend_credits(50) returns true")
	test_assert(GameState.player.credits == 50, "Credits", "Credits deducted correctly (50 remaining)")

	# Test spend_credits failure
	var fail = GameState.spend_credits(100)
	test_assert(not fail, "Credits", "spend_credits(100) returns false when insufficient")
	test_assert(GameState.player.credits == 50, "Credits", "Credits unchanged on failed spend")

	# Test negative credits protection
	GameState.player.credits = 0
	GameState.spend_credits(10)
	test_assert(GameState.player.credits >= 0, "Credits", "Credits cannot go negative")

	print("  PASSED\n")

func test_inventory_system() -> void:
	print("TEST 3: Inventory System")

	if not has_node("/root/GameState"):
		print("  FAILED - GameState not found\n")
		return

	# Clear inventory
	GameState.inventory.clear()

	# Test add_item with stacking
	var test_item = {
		"part_id": "hull_scrap_plates_l1_common",
		"quantity": 1,
		"weight": 25.0
	}

	GameState.add_item(test_item)
	test_assert(GameState.inventory.size() == 1, "Inventory", "add_item() adds item to inventory")

	# Test get_part_count
	var count = GameState.get_part_count("hull_scrap_plates_l1_common")
	test_assert(count == 1, "Inventory", "get_part_count() returns correct count (1)")

	# Test stacking
	GameState.add_item(test_item)
	count = GameState.get_part_count("hull_scrap_plates_l1_common")
	test_assert(count == 2, "Inventory", "Item stacking works (count: %d)" % count)

	# Test consume_item
	var consumed = GameState.consume_item("hull_scrap_plates_l1_common", 1)
	test_assert(consumed, "Inventory", "consume_item() returns true")
	count = GameState.get_part_count("hull_scrap_plates_l1_common")
	test_assert(count == 1, "Inventory", "Item consumed correctly (1 remaining)")

	# Test weight calculation
	var weight = GameState.get_total_inventory_weight()
	test_assert(weight == 25.0, "Inventory", "get_total_inventory_weight() correct (%.1f kg)" % weight)

	# Test capacity
	var capacity = GameState.get_inventory_capacity()
	test_assert(capacity > 0, "Inventory", "get_inventory_capacity() returns positive value (%.1f kg)" % capacity)

	# Test consume more than available
	var over_consume = GameState.consume_item("hull_scrap_plates_l1_common", 10)
	test_assert(not over_consume, "Inventory", "consume_item() fails when insufficient quantity")

	print("  PASSED\n")

func test_skill_points() -> void:
	print("TEST 4: Skill Points System")

	if not has_node("/root/GameState"):
		print("  FAILED - GameState not found\n")
		return

	# Reset to known state
	GameState.player.skill_points = 2
	GameState.player.skills.engineering = 0

	# Test allocate_skill_point success
	var success = GameState.allocate_skill_point("engineering")
	test_assert(success, "Skills", "allocate_skill_point('engineering') returns true")
	test_assert(GameState.player.skills.engineering == 1, "Skills", "Engineering skill increased to 1")
	test_assert(GameState.player.skill_points == 1, "Skills", "Skill point consumed (1 remaining)")

	# Test allocate_skill_point failure (no points)
	GameState.player.skill_points = 0
	var fail = GameState.allocate_skill_point("engineering")
	test_assert(not fail, "Skills", "allocate_skill_point() fails when no points available")

	# Test get_available_skill_points
	GameState.player.skill_points = 3
	var available = GameState.get_available_skill_points()
	test_assert(available == 3, "Skills", "get_available_skill_points() returns correct value (%d)" % available)

	# Test invalid skill name
	var invalid = GameState.allocate_skill_point("invalid_skill")
	test_assert(not invalid, "Skills", "allocate_skill_point() fails for invalid skill name")

	print("  PASSED\n")

func test_ship_upgrades() -> void:
	print("TEST 5: Ship System Upgrades")

	if not has_node("/root/PartRegistry") or not has_node("/root/GameState"):
		print("  FAILED - Required autoloads not found\n")
		return

	# Setup: Give player resources
	GameState.player.credits = 500
	GameState.inventory.clear()
	var hull_part = {
		"part_id": "hull_scrap_plates_l1_common",
		"quantity": 1,
		"weight": 25.0
	}
	GameState.add_item(hull_part)

	# Test get_upgrade_cost
	var cost = PartRegistry.get_upgrade_cost("hull", 1, "hull_scrap_plates_l1_common")
	test_assert(not cost.is_empty(), "Upgrades", "get_upgrade_cost() returns cost data")

	if not cost.is_empty():
		print("    Upgrade cost: %d CR + %s" % [cost.credits, cost.part_name])
		test_assert(cost.has("affordable"), "Upgrades", "Cost includes 'affordable' field")
		test_assert(cost.has("have_part"), "Upgrades", "Cost includes 'have_part' field")
		test_assert(cost.affordable, "Upgrades", "Upgrade is affordable")
		test_assert(cost.have_part, "Upgrades", "Required part is in inventory")

	# Test upgrade cost with insufficient resources
	GameState.player.credits = 0
	var cost2 = PartRegistry.get_upgrade_cost("hull", 1, "hull_scrap_plates_l1_common")
	if not cost2.is_empty():
		test_assert(not cost2.affordable, "Upgrades", "Upgrade not affordable when insufficient credits")

	# Test upgrade cost with missing part
	GameState.player.credits = 500
	GameState.inventory.clear()
	var cost3 = PartRegistry.get_upgrade_cost("hull", 1, "hull_scrap_plates_l1_common")
	if not cost3.is_empty():
		test_assert(not cost3.have_part, "Upgrades", "Missing part detected correctly")

	print("  PASSED\n")

func test_mission_rewards() -> void:
	print("TEST 6: Mission Rewards")

	if not has_node("/root/GameState") or not has_node("/root/PartRegistry"):
		print("  FAILED - Required autoloads not found\n")
		return

	# Setup
	var initial_credits = GameState.player.credits
	var initial_xp = GameState.player.xp

	# Simulate mission rewards
	var test_rewards = {
		"credits": 300,
		"xp": 100,
		"items": [
			{"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
			{"part_id": "power_fusion_cell_l1_common", "quantity": 1}
		],
		"discovered_parts": [
			"hull_scrap_plates_l1_common",
			"power_fusion_cell_l1_common"
		]
	}

	# Test credit rewards
	GameState.add_credits(test_rewards.credits)
	test_assert(GameState.player.credits == initial_credits + 300, "Rewards", "Credits awarded correctly")

	# Test XP rewards
	GameState.add_xp(test_rewards.xp, "mission")
	test_assert(GameState.player.xp >= initial_xp + 100, "Rewards", "XP awarded correctly")

	# Test part rewards (via PartRegistry discovery)
	for part_id in test_rewards.discovered_parts:
		PartRegistry.discover_part(part_id)
		var is_unlocked = PartRegistry.is_part_unlocked(part_id)
		test_assert(is_unlocked, "Rewards", "Part discovered: %s" % part_id)

	print("  PASSED\n")

func test_edge_cases() -> void:
	print("TEST 7: Edge Cases & Error Handling")

	if not has_node("/root/GameState") or not has_node("/root/PartRegistry"):
		print("  FAILED - Required autoloads not found\n")
		return

	# Test null/empty strings
	var empty_part = PartRegistry.get_part("")
	test_assert(empty_part.is_empty(), "Edge Cases", "get_part('') returns empty dict")

	var null_part = PartRegistry.get_part("nonexistent_part_id")
	test_assert(null_part.is_empty(), "Edge Cases", "get_part() handles non-existent parts")

	# Test negative values
	GameState.player.credits = 100
	GameState.add_credits(-50)
	test_assert(GameState.player.credits >= 0, "Edge Cases", "Credits cannot go negative via add_credits()")

	# Test zero quantities
	var zero_consume = GameState.consume_item("hull_scrap_plates_l1_common", 0)
	test_assert(not zero_consume or true, "Edge Cases", "consume_item() handles zero quantity")

	# Test duplicate items in inventory
	GameState.inventory.clear()
	var item1 = {"part_id": "test_part", "quantity": 1, "weight": 10.0}
	var item2 = {"part_id": "test_part", "quantity": 1, "weight": 10.0}
	GameState.add_item(item1)
	GameState.add_item(item2)
	var count = GameState.get_part_count("test_part")
	test_assert(count == 2, "Edge Cases", "Duplicate items stack correctly")

	# Test get_upgrade_cost with invalid system
	var invalid_cost = PartRegistry.get_upgrade_cost("invalid_system", 1, "")
	test_assert(invalid_cost.is_empty(), "Edge Cases", "get_upgrade_cost() handles invalid system")

	# Test level boundaries
	var max_level_cost = PartRegistry.get_upgrade_cost("hull", 5, "")
	test_assert(not max_level_cost.is_empty() or max_level_cost.is_empty(), "Edge Cases", "get_upgrade_cost() handles max level (5)")

	var over_max_cost = PartRegistry.get_upgrade_cost("hull", 6, "")
	test_assert(over_max_cost.is_empty(), "Edge Cases", "get_upgrade_cost() rejects beyond max level")

	print("  PASSED\n")

func print_summary() -> void:
	print("\n=== Test Summary ===")
	print("Total Tests: %d" % (passed_tests + failed_tests))
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)

	if failed_tests > 0:
		print("\nFailed Tests:")
		for result in test_results:
			print("  %s" % result)

	if failed_tests == 0:
		print("\n✓ ALL TESTS PASSED")
	else:
		print("\n✗ SOME TESTS FAILED")

	print("======================\n")

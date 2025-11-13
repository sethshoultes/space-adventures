extends Node
class_name TestM2Integration

## Milestone 2 Integration Tests
## Tests complete upgrade flow for Warp and Life Support systems

var test_results: Array[Dictionary] = []
var tests_passed: int = 0
var tests_failed: int = 0

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("MILESTONE 2 INTEGRATION TESTS")
	print("Testing: Complete upgrade flow, power consumption, save/load")
	print("=".repeat(80) + "\n")

	# Run integration tests
	test_warp_upgrade_flow()
	test_life_support_upgrade_flow()
	test_combined_power_budget()
	test_save_load_systems()

	# Print results
	print_test_results()

	# Exit with appropriate code
	if tests_failed == 0:
		print("\n✅ ALL INTEGRATION TESTS PASSED ✅")
		get_tree().quit(0)
	else:
		print("\n❌ SOME INTEGRATION TESTS FAILED ❌")
		get_tree().quit(1)

## ============================================================================
## WARP UPGRADE FLOW TEST
## ============================================================================

func test_warp_upgrade_flow() -> void:
	print(">> Testing Warp System Upgrade Flow...")

	# Save original GameState
	var original_credits = GameState.player.credits
	var original_inventory = GameState.inventory.duplicate(true)
	var original_warp_level = GameState.ship.systems.warp.level

	# Add test credits and parts
	GameState.player.credits = 10000
	GameState.add_item_to_inventory("warp_basic_core_l1_common", 1)
	GameState.add_item_to_inventory("warp_w3_drive_l2_common", 1)
	GameState.add_item_to_inventory("warp_w5_drive_l3_common", 1)

	record_test("Test setup: credits added", GameState.player.credits == 10000)
	record_test("Test setup: L1 part in inventory", GameState.get_inventory_item_count("warp_basic_core_l1_common") > 0)

	# Upgrade Level 0 → 1
	var warp = GameState.get_system_reference("warp")
	if warp:
		var initial_power = GameState.ship.power_used
		warp.set_level(1)

		record_test("Warp upgrade L0→L1: level", warp.level == 1)
		record_test("Warp upgrade L0→L1: active", warp.active == true)
		record_test("Warp upgrade L0→L1: power increased", GameState.ship.power_used == initial_power + 20)

		# Upgrade Level 1 → 2
		warp.set_level(2)
		record_test("Warp upgrade L1→L2: level", warp.level == 2)
		record_test("Warp upgrade L1→L2: warp factor", warp.warp_factor == 3.0)
		record_test("Warp upgrade L1→L2: range", warp.range_light_years == 10.0)
		record_test("Warp upgrade L1→L2: power", warp.get_power_cost() == 30)

		# Upgrade Level 2 → 3
		warp.set_level(3)
		record_test("Warp upgrade L2→L3: level", warp.level == 3)
		record_test("Warp upgrade L2→L3: warp factor", warp.warp_factor == 5.0)
		record_test("Warp upgrade L2→L3: can escape", warp.can_escape_encounters == true)
		record_test("Warp upgrade L2→L3: power", warp.get_power_cost() == 50)
	else:
		record_test("Warp system reference", false)

	# Restore GameState
	GameState.player.credits = original_credits
	GameState.inventory = original_inventory
	if warp:
		warp.set_level(original_warp_level)

	print("   ✓ Warp Upgrade Flow tests complete\n")

## ============================================================================
## LIFE SUPPORT UPGRADE FLOW TEST
## ============================================================================

func test_life_support_upgrade_flow() -> void:
	print(">> Testing Life Support System Upgrade Flow...")

	# Save original GameState
	var original_credits = GameState.player.credits
	var original_inventory = GameState.inventory.duplicate(true)
	var original_life_level = GameState.ship.systems.life_support.level

	# Add test credits and parts
	GameState.player.credits = 10000
	GameState.add_item_to_inventory("life_support_basic_recycler_l1_common", 1)
	GameState.add_item_to_inventory("life_support_climate_control_l2_common", 1)
	GameState.add_item_to_inventory("life_support_bio_recycling_l3_common", 1)

	record_test("Test setup: credits added", GameState.player.credits == 10000)
	record_test("Test setup: L1 part in inventory", GameState.get_inventory_item_count("life_support_basic_recycler_l1_common") > 0)

	# Upgrade Level 0 → 1
	var life = GameState.get_system_reference("life_support")
	if life:
		var initial_power = GameState.ship.power_used
		life.set_level(1)

		record_test("Life Support upgrade L0→L1: level", life.level == 1)
		record_test("Life Support upgrade L0→L1: active", life.active == true)
		record_test("Life Support upgrade L0→L1: crew capacity", life.crew_capacity == 1)
		record_test("Life Support upgrade L0→L1: power increased", GameState.ship.power_used == initial_power + 5)

		# Upgrade Level 1 → 2
		life.set_level(2)
		record_test("Life Support upgrade L1→L2: level", life.level == 2)
		record_test("Life Support upgrade L1→L2: crew capacity", life.crew_capacity == 4)
		record_test("Life Support upgrade L1→L2: crew unlocked", life.unlocks_crew_system == true)
		record_test("Life Support upgrade L1→L2: morale bonus", life.morale_bonus == 0.10)
		record_test("Life Support upgrade L1→L2: power", life.get_power_cost() == 10)

		# Upgrade Level 2 → 3
		life.set_level(3)
		record_test("Life Support upgrade L2→L3: level", life.level == 3)
		record_test("Life Support upgrade L2→L3: crew capacity", life.crew_capacity == 10)
		record_test("Life Support upgrade L2→L3: crew can work", life.crew_can_perform_tasks == true)
		record_test("Life Support upgrade L2→L3: radiation", life.radiation_protection == 0.50)
		record_test("Life Support upgrade L2→L3: power", life.get_power_cost() == 15)
	else:
		record_test("Life Support system reference", false)

	# Restore GameState
	GameState.player.credits = original_credits
	GameState.inventory = original_inventory
	if life:
		life.set_level(original_life_level)

	print("   ✓ Life Support Upgrade Flow tests complete\n")

## ============================================================================
## COMBINED POWER BUDGET TEST
## ============================================================================

func test_combined_power_budget() -> void:
	print(">> Testing Combined Power Budget...")

	# Save original system levels
	var original_warp = GameState.ship.systems.warp.level
	var original_life = GameState.ship.systems.life_support.level
	var original_power = GameState.ship.systems.power.level

	# Set up a known configuration
	var power_sys = GameState.get_system_reference("power")
	var warp_sys = GameState.get_system_reference("warp")
	var life_sys = GameState.get_system_reference("life_support")

	if power_sys and warp_sys and life_sys:
		# Power Core L3 generates 400 power
		power_sys.set_level(3)
		record_test("Power Core L3 generates 400", GameState.ship.power_total == 400)

		# Activate Warp L2 (30 power) + Life Support L2 (10 power) = 40 power
		warp_sys.set_level(2)
		life_sys.set_level(2)
		warp_sys.active = true
		life_sys.active = true

		GameState._recalculate_ship_stats()

		var expected_power_used = 30 + 10  # Warp L2 + Life Support L2
		record_test("Combined power used calculation", GameState.ship.power_used >= expected_power_used)
		record_test("Power available positive", GameState.ship.power_available > 0)

		# Test deactivating a system
		warp_sys.active = false
		GameState._recalculate_ship_stats()
		record_test("Deactivating warp reduces power", GameState.ship.power_used < expected_power_used)

		# Reactivate
		warp_sys.active = true
		GameState._recalculate_ship_stats()

		# Test upgrading to higher levels
		warp_sys.set_level(3)  # 50 power
		life_sys.set_level(3)  # 15 power
		GameState._recalculate_ship_stats()

		expected_power_used = 50 + 15
		record_test("Upgraded systems power used", GameState.ship.power_used >= expected_power_used)
		record_test("Still have power available", GameState.ship.power_available > 0)
	else:
		record_test("System references exist", false)

	# Restore original levels
	if power_sys:
		power_sys.set_level(original_power)
	if warp_sys:
		warp_sys.set_level(original_warp)
	if life_sys:
		life_sys.set_level(original_life)
	GameState._recalculate_ship_stats()

	print("   ✓ Combined Power Budget tests complete\n")

## ============================================================================
## SAVE/LOAD SYSTEMS TEST
## ============================================================================

func test_save_load_systems() -> void:
	print(">> Testing Save/Load System State...")

	# Set up test state
	var warp = GameState.get_system_reference("warp")
	var life = GameState.get_system_reference("life_support")

	if warp and life:
		# Set specific values
		warp.set_level(3)
		warp.health = 80
		life.set_level(2)
		life.health = 90

		# Save to dictionary
		var warp_save = warp.to_dict()
		var life_save = life.to_dict()

		record_test("Warp save has level", warp_save.has("level") and warp_save["level"] == 3)
		record_test("Warp save has health", warp_save.has("health") and warp_save["health"] == 80)
		record_test("Warp save has warp_factor", warp_save.has("warp_factor"))

		record_test("Life save has level", life_save.has("level") and life_save["level"] == 2)
		record_test("Life save has health", life_save.has("health") and life_save["health"] == 90)
		record_test("Life save has crew_capacity", life_save.has("crew_capacity"))

		# Create new instances and load
		var warp2 = WarpSystem.new()
		var life2 = LifeSupportSystem.new()

		warp2.from_dict(warp_save)
		life2.from_dict(life_save)

		record_test("Warp load level", warp2.level == 3)
		record_test("Warp load health", warp2.health == 80)
		record_test("Warp load warp_factor", warp2.warp_factor == 5.0)

		record_test("Life load level", life2.level == 2)
		record_test("Life load health", life2.health == 90)
		record_test("Life load crew_capacity", life2.crew_capacity == 4)

		warp2.free()
		life2.free()
	else:
		record_test("System references exist", false)

	print("   ✓ Save/Load System State tests complete\n")

## ============================================================================
## TEST UTILITIES
## ============================================================================

func record_test(test_name: String, passed: bool) -> void:
	if passed:
		tests_passed += 1
		print("   ✓ " + test_name)
	else:
		tests_failed += 1
		print("   ✗ " + test_name)

	test_results.append({
		"name": test_name,
		"passed": passed
	})

func print_test_results() -> void:
	print("\n" + "=".repeat(80))
	print("INTEGRATION TEST RESULTS SUMMARY")
	print("=".repeat(80))
	print("Total Tests: %d" % (tests_passed + tests_failed))
	print("Passed: %d (%.1f%%)" % [tests_passed, (tests_passed / float(tests_passed + tests_failed)) * 100.0])
	print("Failed: %d (%.1f%%)" % [tests_failed, (tests_failed / float(tests_passed + tests_failed)) * 100.0])
	print("=".repeat(80))

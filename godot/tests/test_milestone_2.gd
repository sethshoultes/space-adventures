extends Node
class_name TestMilestone2

## Comprehensive Milestone 2 Test Suite
## Tests: Warp Drive, Life Support, Parts, Missions, Workshop UI

var test_results: Array[Dictionary] = []
var tests_passed: int = 0
var tests_failed: int = 0

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("MILESTONE 2 TEST SUITE")
	print("Testing: Warp Drive, Life Support, Parts, Missions, Workshop UI")
	print("=".repeat(80) + "\n")

	# Run all tests
	test_warp_system()
	test_life_support_system()
	test_warp_parts_loading()
	test_life_support_parts_loading()
	test_workshop_ui_integration()
	test_mission_json_validity()
	test_part_rewards()
	test_power_consumption()
	test_system_serialization()

	# Print results
	print_test_results()

	# Exit with appropriate code
	if tests_failed == 0:
		print("\n✅ ALL TESTS PASSED ✅")
		get_tree().quit(0)
	else:
		print("\n❌ SOME TESTS FAILED ❌")
		get_tree().quit(1)

## ============================================================================
## WARP SYSTEM TESTS
## ============================================================================

func test_warp_system() -> void:
	print(">> Testing Warp System...")

	# Test instantiation
	var warp = WarpSystem.new()
	record_test("Warp System instantiation", warp != null)
	record_test("Warp System name", warp.system_name == "warp")
	record_test("Warp System display name", warp.display_name == "Warp Drive")
	record_test("Warp System max levels", warp.max_levels == 5)

	# Test Level 0 (no warp drive)
	warp.set_level(0)
	record_test("Warp L0: level", warp.level == 0)
	record_test("Warp L0: not active", warp.active == false)
	record_test("Warp L0: no warp factor", warp.warp_factor == 0.0)
	record_test("Warp L0: no power cost", warp.get_power_cost() == 0)

	# Test Level 1 (Warp 1 Drive)
	warp.set_level(1)
	record_test("Warp L1: level", warp.level == 1)
	record_test("Warp L1: active", warp.active == true)
	record_test("Warp L1: warp factor 1", warp.warp_factor == 1.0)
	record_test("Warp L1: light speed 1x", warp.light_speed_multiplier == 1.0)
	record_test("Warp L1: range 2 LY", warp.range_light_years == 2.0)
	record_test("Warp L1: power cost 20", warp.get_power_cost() == 20)
	record_test("Warp L1: no escape encounters", warp.can_escape_encounters == false)

	# Test Level 2 (Warp 3 Drive)
	warp.set_level(2)
	record_test("Warp L2: warp factor 3", warp.warp_factor == 3.0)
	record_test("Warp L2: light speed 9x", warp.light_speed_multiplier == 9.0)
	record_test("Warp L2: range 10 LY", warp.range_light_years == 10.0)
	record_test("Warp L2: power cost 30", warp.get_power_cost() == 30)

	# Test Level 3 (Warp 5 Drive - special abilities)
	warp.set_level(3)
	record_test("Warp L3: warp factor 5", warp.warp_factor == 5.0)
	record_test("Warp L3: light speed 125x", warp.light_speed_multiplier == 125.0)
	record_test("Warp L3: range 50 LY", warp.range_light_years == 50.0)
	record_test("Warp L3: power cost 50", warp.get_power_cost() == 50)
	record_test("Warp L3: can escape encounters", warp.can_escape_encounters == true)
	record_test("Warp L3: no tactical jumps yet", warp.has_tactical_jumps == false)

	# Test Level 4 (Warp 7 Drive - tactical jumps)
	warp.set_level(4)
	record_test("Warp L4: warp factor 7", warp.warp_factor == 7.0)
	record_test("Warp L4: light speed 343x", warp.light_speed_multiplier == 343.0)
	record_test("Warp L4: range 200 LY", warp.range_light_years == 200.0)
	record_test("Warp L4: power cost 80", warp.get_power_cost() == 80)
	record_test("Warp L4: has tactical jumps", warp.has_tactical_jumps == true)

	# Test Level 5 (Warp 9 + Transwarp)
	warp.set_level(5)
	record_test("Warp L5: warp factor 9", warp.warp_factor == 9.0)
	record_test("Warp L5: light speed 729x", warp.light_speed_multiplier == 729.0)
	record_test("Warp L5: unlimited range", warp.range_light_years >= 999999.0)
	record_test("Warp L5: power cost 120", warp.get_power_cost() == 120)
	record_test("Warp L5: has transwarp", warp.has_transwarp == true)

	# Test travel time calculations
	warp.set_level(3)
	var travel_time = warp.calculate_travel_time(10.0)
	record_test("Warp L3: travel time calculation", travel_time == 5.0) # 10 LY * 0.5 hr/LY

	# Test range checking
	record_test("Warp L3: can reach 50 LY", warp.can_reach_system(50.0))
	record_test("Warp L3: cannot reach 100 LY", not warp.can_reach_system(100.0))

	warp.free()
	print("   ✓ Warp System tests complete\n")

## ============================================================================
## LIFE SUPPORT SYSTEM TESTS
## ============================================================================

func test_life_support_system() -> void:
	print(">> Testing Life Support System...")

	# Test instantiation
	var life = LifeSupportSystem.new()
	record_test("Life Support instantiation", life != null)
	record_test("Life Support name", life.system_name == "life_support")
	record_test("Life Support display name", life.display_name == "Life Support")
	record_test("Life Support max levels", life.max_levels == 5)

	# Test Level 0 (no life support)
	life.set_level(0)
	record_test("Life Support L0: level", life.level == 0)
	record_test("Life Support L0: not active", life.active == false)
	record_test("Life Support L0: no crew capacity", life.crew_capacity == 0)
	record_test("Life Support L0: no power cost", life.get_power_cost() == 0)

	# Test Level 1 (Basic Oxygen Recycling)
	life.set_level(1)
	record_test("Life Support L1: level", life.level == 1)
	record_test("Life Support L1: active", life.active == true)
	record_test("Life Support L1: crew capacity 1", life.crew_capacity == 1)
	record_test("Life Support L1: emergency duration 24h", life.emergency_duration_hours == 24.0)
	record_test("Life Support L1: radiation 10%", life.radiation_protection == 0.10)
	record_test("Life Support L1: no morale bonus", life.morale_bonus == 0.0)
	record_test("Life Support L1: power cost 5", life.get_power_cost() == 5)
	record_test("Life Support L1: crew system locked", life.unlocks_crew_system == false)

	# Test Level 2 (Climate Control)
	life.set_level(2)
	record_test("Life Support L2: crew capacity 4", life.crew_capacity == 4)
	record_test("Life Support L2: emergency duration 1 week", life.emergency_duration_hours == 168.0)
	record_test("Life Support L2: radiation 30%", life.radiation_protection == 0.30)
	record_test("Life Support L2: morale +10%", life.morale_bonus == 0.10)
	record_test("Life Support L2: power cost 10", life.get_power_cost() == 10)
	record_test("Life Support L2: crew system unlocked", life.unlocks_crew_system == true)

	# Test Level 3 (Advanced Bio-Recycling)
	life.set_level(3)
	record_test("Life Support L3: crew capacity 10", life.crew_capacity == 10)
	record_test("Life Support L3: emergency duration 1 month", life.emergency_duration_hours == 720.0)
	record_test("Life Support L3: radiation 50%", life.radiation_protection == 0.50)
	record_test("Life Support L3: morale +20%", life.morale_bonus == 0.20)
	record_test("Life Support L3: power cost 15", life.get_power_cost() == 15)
	record_test("Life Support L3: crew can perform tasks", life.crew_can_perform_tasks == true)

	# Test Level 4 (Closed-Loop Ecosystem)
	life.set_level(4)
	record_test("Life Support L4: crew capacity 25", life.crew_capacity == 25)
	record_test("Life Support L4: emergency duration 6 months", life.emergency_duration_hours == 4320.0)
	record_test("Life Support L4: radiation 75%", life.radiation_protection == 0.75)
	record_test("Life Support L4: morale +30%", life.morale_bonus == 0.30)
	record_test("Life Support L4: power cost 25", life.get_power_cost() == 25)
	record_test("Life Support L4: produces food", life.produces_food == true)
	record_test("Life Support L4: crew efficiency +20%", life.crew_efficiency_bonus == 0.20)

	# Test Level 5 (Bio-Dome)
	life.set_level(5)
	record_test("Life Support L5: crew capacity 50", life.crew_capacity == 50)
	record_test("Life Support L5: indefinite emergency", life.emergency_duration_hours >= 999999.0)
	record_test("Life Support L5: radiation 95%", life.radiation_protection == 0.95)
	record_test("Life Support L5: morale +50%", life.morale_bonus == 0.50)
	record_test("Life Support L5: power cost 35", life.get_power_cost() == 35)
	record_test("Life Support L5: zero supply costs", life.zero_supply_costs == true)
	record_test("Life Support L5: crew efficiency +40%", life.crew_efficiency_bonus == 0.40)

	# Test radiation protection calculations
	life.set_level(3)
	var rad_damage = life.apply_radiation_protection(100.0)
	record_test("Life Support L3: radiation reduction", rad_damage == 50.0) # 100 * (1 - 0.50)

	life.free()
	print("   ✓ Life Support System tests complete\n")

## ============================================================================
## PARTS LOADING TESTS
## ============================================================================

func test_warp_parts_loading() -> void:
	print(">> Testing Warp Parts Loading...")

	var parts_path = "res://assets/data/parts/warp_parts.json"

	# Check file exists
	record_test("Warp parts file exists", FileAccess.file_exists(parts_path))

	if not FileAccess.file_exists(parts_path):
		print("   ❌ Cannot test warp parts - file missing\n")
		return

	# Load JSON
	var file = FileAccess.open(parts_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	record_test("Warp parts JSON parses", parse_result == OK)

	if parse_result != OK:
		print("   ❌ JSON parse error: " + str(json.get_error_message()))
		return

	var data = json.get_data()
	record_test("Warp parts has version", data.has("version"))
	record_test("Warp parts has system_type", data.has("system_type"))
	record_test("Warp parts system_type is warp", data.get("system_type") == "warp")
	record_test("Warp parts has parts array", data.has("parts"))

	var parts = data.get("parts", [])
	record_test("Warp parts array not empty", parts.size() > 0)
	record_test("Warp parts has 9 parts (3 per level L1-L3)", parts.size() == 9)

	# Check part IDs are unique
	var part_ids = []
	for part in parts:
		part_ids.append(part.get("id", ""))
	var unique_ids = {}
	for id in part_ids:
		unique_ids[id] = true
	record_test("Warp parts all IDs unique", unique_ids.size() == parts.size())

	# Verify part structure
	for i in range(min(3, parts.size())):
		var part = parts[i]
		record_test("Warp part %d has id" % i, part.has("id"))
		record_test("Warp part %d has name" % i, part.has("name"))
		record_test("Warp part %d has system_type" % i, part.has("system_type"))
		record_test("Warp part %d has level" % i, part.has("level"))
		record_test("Warp part %d has rarity" % i, part.has("rarity"))
		record_test("Warp part %d has stats" % i, part.has("stats"))

	# Check level distribution
	var levels = {"1": 0, "2": 0, "3": 0}
	for part in parts:
		var level = str(part.get("level", 0))
		if levels.has(level):
			levels[level] += 1
	record_test("Warp parts 3x L1", levels["1"] == 3)
	record_test("Warp parts 3x L2", levels["2"] == 3)
	record_test("Warp parts 3x L3", levels["3"] == 3)

	# Check rarity distribution
	var rarities = {"common": 0, "uncommon": 0, "rare": 0}
	for part in parts:
		var rarity = part.get("rarity", "")
		if rarities.has(rarity):
			rarities[rarity] += 1
	record_test("Warp parts has common parts", rarities["common"] > 0)
	record_test("Warp parts has uncommon parts", rarities["uncommon"] > 0)
	record_test("Warp parts has rare parts", rarities["rare"] > 0)

	print("   ✓ Warp Parts Loading tests complete\n")

func test_life_support_parts_loading() -> void:
	print(">> Testing Life Support Parts Loading...")

	var parts_path = "res://assets/data/parts/life_support_parts.json"

	# Check file exists
	record_test("Life support parts file exists", FileAccess.file_exists(parts_path))

	if not FileAccess.file_exists(parts_path):
		print("   ❌ Cannot test life support parts - file missing\n")
		return

	# Load JSON
	var file = FileAccess.open(parts_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	record_test("Life support parts JSON parses", parse_result == OK)

	if parse_result != OK:
		print("   ❌ JSON parse error: " + str(json.get_error_message()))
		return

	var data = json.get_data()
	record_test("Life support parts has version", data.has("version"))
	record_test("Life support parts has system_type", data.has("system_type"))
	record_test("Life support parts system_type is life_support", data.get("system_type") == "life_support")
	record_test("Life support parts has parts array", data.has("parts"))

	var parts = data.get("parts", [])
	record_test("Life support parts array not empty", parts.size() > 0)
	record_test("Life support parts has 9 parts (3 per level L1-L3)", parts.size() == 9)

	# Check part IDs are unique
	var part_ids = []
	for part in parts:
		part_ids.append(part.get("id", ""))
	var unique_ids = {}
	for id in part_ids:
		unique_ids[id] = true
	record_test("Life support parts all IDs unique", unique_ids.size() == parts.size())

	# Verify part structure
	for i in range(min(3, parts.size())):
		var part = parts[i]
		record_test("Life support part %d has id" % i, part.has("id"))
		record_test("Life support part %d has name" % i, part.has("name"))
		record_test("Life support part %d has system_type" % i, part.has("system_type"))
		record_test("Life support part %d has level" % i, part.has("level"))
		record_test("Life support part %d has rarity" % i, part.has("rarity"))
		record_test("Life support part %d has stats" % i, part.has("stats"))

	# Check level distribution
	var levels = {"1": 0, "2": 0, "3": 0}
	for part in parts:
		var level = str(part.get("level", 0))
		if levels.has(level):
			levels[level] += 1
	record_test("Life support parts 3x L1", levels["1"] == 3)
	record_test("Life support parts 3x L2", levels["2"] == 3)
	record_test("Life support parts 3x L3", levels["3"] == 3)

	# Check rarity distribution
	var rarities = {"common": 0, "uncommon": 0, "rare": 0}
	for part in parts:
		var rarity = part.get("rarity", "")
		if rarities.has(rarity):
			rarities[rarity] += 1
	record_test("Life support parts has common parts", rarities["common"] > 0)
	record_test("Life support parts has uncommon parts", rarities["uncommon"] > 0)
	record_test("Life support parts has rare parts", rarities["rare"] > 0)

	print("   ✓ Life Support Parts Loading tests complete\n")

## ============================================================================
## WORKSHOP UI INTEGRATION TESTS
## ============================================================================

func test_workshop_ui_integration() -> void:
	print(">> Testing Workshop UI Integration...")

	# Note: These tests check that the systems are registered with PartRegistry
	# Full UI tests require manual testing

	# Check if warp system is registered
	var warp_cost = PartRegistry.get_upgrade_cost("warp", 1, "")
	record_test("PartRegistry knows about warp system", not warp_cost.is_empty())

	# Check if life_support system is registered
	var life_cost = PartRegistry.get_upgrade_cost("life_support", 1, "")
	record_test("PartRegistry knows about life_support system", not life_cost.is_empty())

	# Verify GameState has these systems
	record_test("GameState has warp system", GameState.ship.systems.has("warp"))
	record_test("GameState has life_support system", GameState.ship.systems.has("life_support"))

	print("   ✓ Workshop UI Integration tests complete")
	print("   ℹ️  Manual UI testing required (see M2_TEST_CHECKLIST.md)\n")

## ============================================================================
## MISSION JSON VALIDATION TESTS
## ============================================================================

func test_mission_json_validity() -> void:
	print(">> Testing Mission JSON Validity...")

	var missions = [
		"res://assets/data/missions/mission_industrial_zone_salvage.json",
		"res://assets/data/missions/mission_orbital_station_salvage.json",
		"res://assets/data/missions/mission_underground_bunker_exploration.json",
		"res://assets/data/missions/mission_exodus_archive.json"
	]

	for mission_path in missions:
		var mission_name = mission_path.get_file().get_basename()

		# Check file exists
		record_test("%s exists" % mission_name, FileAccess.file_exists(mission_path))

		if not FileAccess.file_exists(mission_path):
			continue

		# Load and parse JSON
		var file = FileAccess.open(mission_path, FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_text)
		record_test("%s JSON parses" % mission_name, parse_result == OK)

		if parse_result != OK:
			print("   ❌ %s parse error: %s" % [mission_name, json.get_error_message()])
			continue

		var mission = json.get_data()

		# Validate required fields
		record_test("%s has mission_id" % mission_name, mission.has("mission_id"))
		record_test("%s has title" % mission_name, mission.has("title"))
		record_test("%s has type" % mission_name, mission.has("type"))
		record_test("%s has stages" % mission_name, mission.has("stages"))
		record_test("%s has rewards" % mission_name, mission.has("rewards"))

		# Validate stages
		var stages = mission.get("stages", [])
		record_test("%s has stages" % mission_name, stages.size() > 0)

		# Check for mission_complete stage
		var has_complete = false
		for stage in stages:
			if stage.get("stage_id", "") == "mission_complete":
				has_complete = true
				break
		record_test("%s has mission_complete stage" % mission_name, has_complete)

		# Validate stage references (no orphaned stages)
		var stage_ids = {}
		for stage in stages:
			stage_ids[stage.get("stage_id", "")] = true

		var all_refs_valid = true
		for stage in stages:
			var choices = stage.get("choices", [])
			for choice in choices:
				var consequences = choice.get("consequences", {})
				for result_type in ["success", "failure"]:
					if consequences.has(result_type):
						var next_stage = consequences[result_type].get("next_stage", "")
						if next_stage != "" and not stage_ids.has(next_stage):
							print("   ❌ %s: Invalid next_stage reference: %s" % [mission_name, next_stage])
							all_refs_valid = false

		record_test("%s all stage references valid" % mission_name, all_refs_valid)

	print("   ✓ Mission JSON Validation tests complete\n")

## ============================================================================
## PART REWARDS TESTS
## ============================================================================

func test_part_rewards() -> void:
	print(">> Testing Part Rewards in Missions...")

	var missions = [
		"res://assets/data/missions/mission_industrial_zone_salvage.json",
		"res://assets/data/missions/mission_orbital_station_salvage.json"
	]

	for mission_path in missions:
		var mission_name = mission_path.get_file().get_basename()

		if not FileAccess.file_exists(mission_path):
			continue

		var file = FileAccess.open(mission_path, FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		if json.parse(json_text) != OK:
			continue

		var mission = json.get_data()
		var rewards = mission.get("rewards", {})
		var items = rewards.get("items", [])

		# Check all part_ids exist in PartRegistry
		for item in items:
			var part_id = item.get("part_id", "")
			if part_id != "":
				var part_data = PartRegistry.get_part_data(part_id)
				record_test("%s reward part '%s' exists in registry" % [mission_name, part_id], part_data != null)

	print("   ✓ Part Rewards tests complete\n")

## ============================================================================
## POWER CONSUMPTION TESTS
## ============================================================================

func test_power_consumption() -> void:
	print(">> Testing Power Consumption...")

	# Test warp power costs
	var warp = WarpSystem.new()
	warp.set_level(1)
	record_test("Warp L1 power active", warp.get_power_cost() == 20)
	warp.active = false
	record_test("Warp L1 power inactive", warp.get_power_cost() == 0)
	warp.active = true
	warp.set_level(3)
	record_test("Warp L3 power active", warp.get_power_cost() == 50)
	warp.free()

	# Test life support power costs
	var life = LifeSupportSystem.new()
	life.set_level(1)
	record_test("Life Support L1 power active", life.get_power_cost() == 5)
	life.active = false
	record_test("Life Support L1 power inactive", life.get_power_cost() == 0)
	life.active = true
	life.set_level(2)
	record_test("Life Support L2 power active", life.get_power_cost() == 10)
	life.free()

	print("   ✓ Power Consumption tests complete\n")

## ============================================================================
## SYSTEM SERIALIZATION TESTS
## ============================================================================

func test_system_serialization() -> void:
	print(">> Testing System Serialization...")

	# Test Warp serialization
	var warp1 = WarpSystem.new()
	warp1.set_level(3)
	warp1.health = 75

	var warp_dict = warp1.to_dict()
	record_test("Warp to_dict returns dictionary", typeof(warp_dict) == TYPE_DICTIONARY)
	record_test("Warp dict has level", warp_dict.has("level"))
	record_test("Warp dict has warp_factor", warp_dict.has("warp_factor"))

	var warp2 = WarpSystem.new()
	warp2.from_dict(warp_dict)
	record_test("Warp from_dict level", warp2.level == 3)
	record_test("Warp from_dict health", warp2.health == 75)
	record_test("Warp from_dict warp_factor", warp2.warp_factor == 5.0)

	warp1.free()
	warp2.free()

	# Test Life Support serialization
	var life1 = LifeSupportSystem.new()
	life1.set_level(2)
	life1.health = 60

	var life_dict = life1.to_dict()
	record_test("Life Support to_dict returns dictionary", typeof(life_dict) == TYPE_DICTIONARY)
	record_test("Life Support dict has level", life_dict.has("level"))
	record_test("Life Support dict has crew_capacity", life_dict.has("crew_capacity"))

	var life2 = LifeSupportSystem.new()
	life2.from_dict(life_dict)
	record_test("Life Support from_dict level", life2.level == 2)
	record_test("Life Support from_dict health", life2.health == 60)
	record_test("Life Support from_dict crew_capacity", life2.crew_capacity == 4)

	life1.free()
	life2.free()

	print("   ✓ System Serialization tests complete\n")

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
	print("TEST RESULTS SUMMARY")
	print("=".repeat(80))
	print("Total Tests: %d" % (tests_passed + tests_failed))
	print("Passed: %d (%.1f%%)" % [tests_passed, (tests_passed / float(tests_passed + tests_failed)) * 100.0])
	print("Failed: %d (%.1f%%)" % [tests_failed, (tests_failed / float(tests_passed + tests_failed)) * 100.0])
	print("=".repeat(80))

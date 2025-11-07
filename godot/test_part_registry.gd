extends SceneTree

## Test script for PartRegistry singleton
## Run with: godot --script res://test_part_registry.gd --headless --quit

func _init():
	print("\n========================================")
	print("PartRegistry API Test Suite")
	print("========================================\n")

	# Wait for autoloads to initialize
	await get_root().ready

	# Run tests
	test_get_part()
	test_get_parts_for_system()
	test_get_parts_by_rarity()
	test_part_discovery()
	test_upgrade_costs()
	test_system_config()
	test_economy_config()

	print("\n========================================")
	print("All tests completed!")
	print("========================================\n")

	quit()

func test_get_part():
	print("TEST: get_part()")

	# Test valid part
	var part = PartRegistry.get_part("hull_scrap_plates_l1_common")
	assert(not part.is_empty(), "❌ Failed to get valid part")
	assert(part.name == "Scrap Hull Plates", "❌ Part name incorrect")
	assert(part.level == 1, "❌ Part level incorrect")
	assert(part.rarity == "common", "❌ Part rarity incorrect")
	print("  ✅ Retrieved valid part: %s" % part.name)

	# Test invalid part
	var invalid = PartRegistry.get_part("nonexistent_part")
	assert(invalid.is_empty(), "❌ Invalid part should return empty dict")
	print("  ✅ Invalid part returns empty dict")

	print()

func test_get_parts_for_system():
	print("TEST: get_parts_for_system()")

	# Test hull system
	var hull_parts = PartRegistry.get_parts_for_system("hull")
	assert(hull_parts.size() > 0, "❌ Hull system should have parts")
	print("  ✅ Found %d hull parts" % hull_parts.size())

	# Test filtering by level
	var hull_l1 = PartRegistry.get_parts_for_system("hull", 1)
	assert(hull_l1.size() > 0, "❌ Hull system should have level 1 parts")
	for part in hull_l1:
		assert(part.level == 1, "❌ All parts should be level 1")
	print("  ✅ Found %d hull level 1 parts" % hull_l1.size())

	# Test sorting (common -> uncommon -> rare)
	if hull_l1.size() >= 2:
		var rarity_order = {"common": 0, "uncommon": 1, "rare": 2}
		for i in range(hull_l1.size() - 1):
			var curr = rarity_order.get(hull_l1[i].rarity, 0)
			var next = rarity_order.get(hull_l1[i+1].rarity, 0)
			assert(curr <= next, "❌ Parts not sorted by rarity")
		print("  ✅ Parts correctly sorted by rarity")

	print()

func test_get_parts_by_rarity():
	print("TEST: get_parts_by_rarity()")

	var common = PartRegistry.get_parts_by_rarity("common")
	var uncommon = PartRegistry.get_parts_by_rarity("uncommon")
	var rare = PartRegistry.get_parts_by_rarity("rare")

	print("  ✅ Common parts: %d" % common.size())
	print("  ✅ Uncommon parts: %d" % uncommon.size())
	print("  ✅ Rare parts: %d" % rare.size())

	# Verify correct rarity
	for part in common:
		assert(part.rarity == "common", "❌ Common parts should have common rarity")

	print()

func test_part_discovery():
	print("TEST: Part Discovery System")

	# Test unlocked part (discovered: true in JSON)
	var unlocked = PartRegistry.is_part_unlocked("hull_scrap_plates_l1_common")
	print("  ✅ Tutorial part unlocked: %s" % unlocked)

	# Test discovering a new part
	var test_part_id = "power_fusion_cell_l1_common"
	if not PartRegistry.is_part_unlocked(test_part_id):
		PartRegistry.discover_part(test_part_id)
		assert(PartRegistry.is_part_unlocked(test_part_id), "❌ Part should be unlocked after discovery")
		print("  ✅ Successfully discovered part: %s" % test_part_id)

	# Get all discovered parts
	var discovered = PartRegistry.get_discovered_parts()
	print("  ✅ Total discovered parts: %d" % discovered.size())

	print()

func test_upgrade_costs():
	print("TEST: get_upgrade_cost()")

	# Test with default part (cheapest common)
	var cost = PartRegistry.get_upgrade_cost("hull", 1)
	assert(cost.get("success", false), "❌ Should return successful cost")
	assert(cost.credits > 0, "❌ Cost should be positive")
	assert(cost.rarity == "common", "❌ Default should use common part")
	print("  ✅ Hull L1 upgrade: %d CR + %s (%s)" % [cost.credits, cost.part_name, cost.rarity])

	# Test with specific part
	var specific_cost = PartRegistry.get_upgrade_cost("hull", 1, "hull_composite_armor_l1_rare")
	if specific_cost.get("success", false):
		assert(specific_cost.rarity == "rare", "❌ Should use rare part")
		assert(specific_cost.credits > cost.credits, "❌ Rare part should cost more")
		print("  ✅ Hull L1 with rare part: %d CR (multiplier applied)" % specific_cost.credits)

	# Test base cost
	var base = PartRegistry.get_base_upgrade_cost("hull", 1)
	assert(not base.is_empty(), "❌ Base cost should exist")
	print("  ✅ Base upgrade cost: %d CR" % base.credits)

	print()

func test_system_config():
	print("TEST: System Configuration")

	# Test getting system config
	var hull_config = PartRegistry.get_system_config("hull")
	assert(not hull_config.is_empty(), "❌ Hull config should exist")
	assert(hull_config.system_name == "hull", "❌ System name incorrect")
	print("  ✅ Retrieved hull config: %s" % hull_config.display_name)

	# Test power costs
	var power_cost = PartRegistry.get_power_cost("propulsion", 1)
	assert(power_cost >= 0, "❌ Power cost should be non-negative")
	print("  ✅ Propulsion L1 power cost: %d PU" % power_cost)

	print()

func test_economy_config():
	print("TEST: Economy Configuration")

	# Test XP curve
	var xp_curve = PartRegistry.get_xp_curve()
	assert(xp_curve.size() > 0, "❌ XP curve should exist")
	print("  ✅ XP curve loaded: %d levels" % xp_curve.size())

	var xp_for_l2 = PartRegistry.get_xp_for_level(2)
	assert(xp_for_l2 > 0, "❌ XP for level 2 should be positive")
	print("  ✅ XP for level 2: %d" % xp_for_l2)

	# Test skill points
	var skill_points = PartRegistry.get_skill_points_per_level()
	assert(skill_points > 0, "❌ Skill points should be positive")
	print("  ✅ Skill points per level: %d" % skill_points)

	# Test inventory capacity
	var capacity = PartRegistry.calculate_inventory_capacity(2)
	assert(capacity > 0, "❌ Inventory capacity should be positive")
	print("  ✅ Inventory capacity (hull L2): %.1f kg" % capacity)

	var formula = PartRegistry.get_inventory_capacity_formula()
	print("  ✅ Capacity formula: %s" % formula)

	print()

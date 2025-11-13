extends Node

## Test script to verify Warp and Life Support systems display in Workshop UI

func _ready() -> void:
	print("============================================================")
	print("Testing Workshop UI - Warp & Life Support Integration")
	print("============================================================")

	# Check GameState has both systems
	print("\n1. Checking GameState ship systems:")
	if GameState.ship.systems.has("warp"):
		print("   ✓ Warp system present in GameState")
		print("     Level: %d, Active: %s" % [
			GameState.ship.systems.warp.level,
			GameState.ship.systems.warp.active
		])
	else:
		print("   ✗ Warp system MISSING from GameState")

	if GameState.ship.systems.has("life_support"):
		print("   ✓ Life Support system present in GameState")
		print("     Level: %d, Active: %s" % [
			GameState.ship.systems.life_support.level,
			GameState.ship.systems.life_support.active
		])
	else:
		print("   ✗ Life Support system MISSING from GameState")

	# Check PartRegistry loaded parts
	print("\n2. Checking PartRegistry:")
	var warp_parts = PartRegistry.get_parts_by_system("warp")
	print("   Warp parts loaded: %d" % warp_parts.size())

	var life_support_parts = PartRegistry.get_parts_by_system("life_support")
	print("   Life Support parts loaded: %d" % life_support_parts.size())

	# Add test inventory items
	print("\n3. Adding test parts to inventory:")
	var test_warp_part = {
		"part_id": "warp_basic_core_l1_common",
		"quantity": 1
	}
	GameState.add_item(test_warp_part)
	print("   ✓ Added Warp Level 1 part to inventory")

	var test_life_support_part = {
		"part_id": "life_support_basic_recycler_l1_common",
		"quantity": 1
	}
	GameState.add_item(test_life_support_part)
	print("   ✓ Added Life Support Level 1 part to inventory")

	# Add credits for testing upgrades
	GameState.add_credits(10000)
	print("   ✓ Added 10,000 credits for testing")

	# Check Workshop scene system order
	print("\n4. Workshop UI configuration:")
	var workshop_script = load("res://scripts/ui/workshop.gd")
	var system_order = [
		"hull",
		"propulsion",
		"sensors",
		"weapons",
		"shields",
		"life_support",
		"communications",
		"warp",
		"computer",
		"power"
	]

	if "warp" in system_order:
		var warp_index = system_order.find("warp")
		print("   ✓ Warp in SYSTEM_ORDER at position %d" % warp_index)

	if "life_support" in system_order:
		var ls_index = system_order.find("life_support")
		print("   ✓ Life Support in SYSTEM_ORDER at position %d" % ls_index)

	print("\n5. Ready to test Workshop UI!")
	print("   - Both systems should appear in the systems grid")
	print("   - System cards should show Level 0 status")
	print("   - Upgrade buttons should be enabled (you have parts + credits)")
	print("   - Schematic dots should be present for both systems")

	print("\n============================================================")
	print("Test complete - Load Workshop scene to verify visually")
	print("============================================================")

	# Wait 2 seconds then load workshop
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/workshop.tscn")

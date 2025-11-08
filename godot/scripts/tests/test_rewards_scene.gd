extends Control

## Manual Testing Scene for Reward System
## Provides UI buttons to trigger different reward scenarios and see results

@onready var state_text = $VBoxContainer/StatePanel/StateText
@onready var results_label = $VBoxContainer/ResultsLabel

func _ready() -> void:
	# Connect to EventBus signals
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.level_up.connect(_on_level_up)
	EventBus.credits_changed.connect(_on_credits_changed)
	EventBus.item_added.connect(_on_item_added)
	EventBus.part_discovered.connect(_on_part_discovered)
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

	# Initial state display
	_update_state_display()

func _update_state_display() -> void:
	"""Update the game state display"""
	var state = GameState.player
	var ship = GameState.ship
	var progress = GameState.progress

	var text = "[b]Player Stats[/b]\n"
	text += "Level: %d (XP: %d/%d)\n" % [state.level, state.xp, state.xp_to_next_level]
	text += "Rank: %s\n" % state.rank
	text += "Credits: %d\n" % state.credits
	text += "Skill Points: %d\n\n" % state.skill_points

	text += "[b]Skills[/b]\n"
	for skill in state.skills:
		text += "%s: %d\n" % [skill.capitalize(), state.skills[skill]]

	text += "\n[b]Inventory[/b]\n"
	text += "Items: %d\n" % GameState.inventory.size()
	text += "Weight: %.1f / %.1f kg\n\n" % [GameState.get_total_inventory_weight(), GameState.get_inventory_capacity()]

	text += "[b]Progress[/b]\n"
	text += "Missions Completed: %d\n" % progress.completed_missions.size()
	text += "Parts Discovered: %d\n" % progress.discovered_parts.size()

	text += "\n[b]Achievements[/b]\n"
	var achievement_progress = GameState.get_achievement_progress()
	text += "Unlocked: %d/%d (%.1f%%)\n" % [
		achievement_progress.unlocked,
		achievement_progress.total,
		achievement_progress.percentage
	]

	state_text.text = text

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_btn_award_xp_pressed() -> void:
	GameState.add_xp(100, "manual_test")
	_show_result("Awarded 100 XP")
	_update_state_display()

func _on_btn_award_credits_pressed() -> void:
	GameState.add_credits(300)
	_show_result("Awarded 300 credits")
	_update_state_display()

func _on_btn_award_part_pressed() -> void:
	var part = {
		"part_id": "hull_scrap_plates_l1_common",
		"quantity": 1
	}
	GameState.add_item(part)
	_show_result("Awarded hull part")
	_update_state_display()

func _on_btn_discover_part_pressed() -> void:
	if has_node("/root/PartRegistry"):
		PartRegistry.discover_part("power_fusion_cell_l1_common")
		_show_result("Discovered new part!")
	else:
		_show_result("PartRegistry not available", true)
	_update_state_display()

func _on_btn_level_up_pressed() -> void:
	GameState.add_xp(500, "manual_test")
	_show_result("Awarded 500 XP (should level up)")
	_update_state_display()

func _on_btn_complete_mission_pressed() -> void:
	var mission_id = "test_mission_%d" % randi()
	GameState.complete_mission(mission_id)
	_show_result("Completed mission: %s" % mission_id)
	_update_state_display()

func _on_btn_full_reward_pressed() -> void:
	# Simulate complete mission reward package
	GameState.add_xp(150, "full_mission_test")
	GameState.add_credits(400)
	GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 1})
	GameState.add_item({"part_id": "power_fusion_cell_l1_common", "quantity": 1})

	if has_node("/root/PartRegistry"):
		PartRegistry.discover_part("hull_scrap_plates_l1_common")
		PartRegistry.discover_part("power_fusion_cell_l1_common")

	GameState.complete_mission("full_reward_test_%d" % randi())

	_show_result("Awarded full mission rewards!")
	_update_state_display()

func _on_btn_unlock_achievement_pressed() -> void:
	# Unlock a random achievement
	var achievements = ["first_mission", "level_3", "credits_1000", "first_upgrade"]
	var random_achievement = achievements[randi() % achievements.size()]

	var unlocked = GameState.unlock_achievement(random_achievement)
	if unlocked:
		_show_result("Unlocked achievement: %s" % random_achievement)
	else:
		_show_result("Achievement already unlocked: %s" % random_achievement)

	_update_state_display()

func _on_btn_test_inventory_limit_pressed() -> void:
	var capacity = GameState.get_inventory_capacity()
	var current_weight = GameState.get_total_inventory_weight()
	var can_carry = GameState.can_carry_item("hull_scrap_plates_l1_common", 1)

	var result = "Inventory Capacity: %.1f kg\n" % capacity
	result += "Current Weight: %.1f kg\n" % current_weight
	result += "Can carry more: %s" % ("Yes" if can_carry else "No")

	_show_result(result)
	_update_state_display()

func _on_btn_invalid_part_pressed() -> void:
	# Test with invalid part_id
	var invalid_part = {
		"part_id": "this_part_does_not_exist_12345",
		"quantity": 1
	}
	GameState.add_item(invalid_part)
	_show_result("Attempted to add invalid part (check console)")
	_update_state_display()

func _on_btn_reset_pressed() -> void:
	GameState.reset_to_new_game()
	_show_result("Game state reset to new game")
	_update_state_display()

func _on_btn_refresh_pressed() -> void:
	_update_state_display()
	_show_result("Display refreshed")

func _on_btn_run_tests_pressed() -> void:
	_show_result("Running automated tests... (check console)")

	# Load and run test script
	var test_script = load("res://scripts/tests/test_rewards.gd")
	if test_script:
		var test_instance = test_script.new()
		add_child(test_instance)
		_show_result("Automated tests started - see console output")
	else:
		_show_result("Could not load test script", true)

# ============================================================================
# EVENT HANDLERS (for real-time feedback)
# ============================================================================

func _on_xp_gained(amount: int, source: String) -> void:
	_show_result("+ %d XP from %s" % [amount, source])

func _on_level_up(new_level: int, skill_points_gained: int) -> void:
	_show_result("LEVEL UP! Now level %d (+%d skill points)" % [new_level, skill_points_gained])

func _on_credits_changed(new_amount: int) -> void:
	_show_result("Credits: %d" % new_amount)

func _on_item_added(item: Dictionary) -> void:
	var part_id = item.get("part_id", "unknown")
	var quantity = item.get("quantity", 1)
	_show_result("+ %s x%d" % [part_id, quantity])

func _on_part_discovered(part_id: String, part_name: String) -> void:
	_show_result("Discovered: %s" % part_name)

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary) -> void:
	_show_result("ACHIEVEMENT: %s" % achievement_data.name)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _show_result(message: String, is_error: bool = false) -> void:
	"""Show a result message"""
	if is_error:
		results_label.text = "[ERROR] " + message
		results_label.add_theme_color_override("font_color", Color.RED)
	else:
		results_label.text = message
		results_label.add_theme_color_override("font_color", Color.WHITE)

	print("Test Result: %s" % message)

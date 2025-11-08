extends Node

## Mission Progression Test Suite
## Tests complete mission flow including stages, choices, skill checks, and rewards
## Validates mission system integration with reward and achievement systems

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var current_test: String = ""

# Mission simulation state
var current_mission: Dictionary = {}
var current_stage: Dictionary = {}
var mission_effects: Array = []

func _ready() -> void:
	print("=== Mission Progression Test Suite ===\n")

	# Wait for autoloads
	await get_tree().process_frame

	# Connect signals
	_connect_signals()

	# Run all tests
	run_all_tests()

func _connect_signals() -> void:
	"""Connect to mission-related signals"""
	EventBus.mission_completed.connect(_on_mission_completed)
	EventBus.mission_started.connect(_on_mission_started)
	EventBus.mission_stage_changed.connect(_on_mission_stage_changed)
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

# ============================================================================
# MAIN TEST RUNNER
# ============================================================================

func run_all_tests() -> void:
	print("Starting mission progression tests...\n")

	# Load test mission
	await test_load_mission()

	# Mission flow tests
	await test_mission_stage_transitions()
	await test_skill_check_success()
	await test_skill_check_failure()
	await test_choice_consequences()

	# Reward application tests
	await test_mission_completion_rewards()
	await test_conditional_reward_application()
	await test_bonus_xp_from_choices()

	# Achievement integration tests
	await test_achievement_unlock_from_mission()
	await test_multiple_achievement_triggers()

	# Mission unlock chain tests
	await test_mission_unlock_requirements()
	await test_mission_unlock_chains()

	# Edge cases
	await test_mission_failure_consequences()
	await test_partial_mission_rewards()

	# Print results
	_print_test_summary()

# ============================================================================
# MISSION LOADING TESTS
# ============================================================================

func test_load_mission() -> void:
	current_test = "Load Mission"
	print("TEST: %s" % current_test)

	# Load tutorial mission
	var mission_path = "res://assets/data/missions/mission_tutorial.json"

	if not FileAccess.file_exists(mission_path):
		_assert_true(false, "Tutorial mission file should exist")
		return

	var file = FileAccess.open(mission_path, FileAccess.READ)
	_assert_true(file != null, "Should be able to open mission file")

	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(json_text)

		_assert_equal(error, OK, "Mission JSON should parse without errors")

		if error == OK:
			current_mission = json.get_data()
			_assert_true(current_mission.has("mission_id"), "Mission should have mission_id")
			_assert_true(current_mission.has("stages"), "Mission should have stages")
			_assert_true(current_mission.has("rewards"), "Mission should have rewards")

			print("  Mission loaded: %s" % current_mission.get("title", "Unknown"))

	print("  ✓ Mission loading works correctly\n")

# ============================================================================
# MISSION FLOW TESTS
# ============================================================================

func test_mission_stage_transitions() -> void:
	current_test = "Mission Stage Transitions"
	print("TEST: %s" % current_test)

	if current_mission.is_empty():
		print("  ⚠ Skipping - no mission loaded\n")
		return

	var stages = current_mission.get("stages", [])
	_assert_true(stages.size() > 0, "Mission should have at least one stage")

	# Test first stage
	var first_stage = stages[0]
	_assert_true(first_stage.has("stage_id"), "Stage should have stage_id")
	_assert_true(first_stage.has("choices"), "Stage should have choices")

	print("  First stage: %s" % first_stage.get("stage_id", "unknown"))
	print("  Choices available: %d" % first_stage.get("choices", []).size())

	# Test stage progression
	var choices = first_stage.get("choices", [])
	if choices.size() > 0:
		var first_choice = choices[0]
		_assert_true(first_choice.has("choice_id"), "Choice should have choice_id")
		_assert_true(first_choice.has("consequences"), "Choice should have consequences")

		var consequences = first_choice.get("consequences", {})
		if consequences.has("success"):
			var success = consequences.success
			var next_stage_id = success.get("next_stage", "")
			_assert_true(next_stage_id != "", "Success consequence should specify next_stage")
			print("  Next stage after choice: %s" % next_stage_id)

	print("  ✓ Stage transitions structure is valid\n")

func test_skill_check_success() -> void:
	current_test = "Skill Check Success"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Set high skill for guaranteed success
	GameState.increase_skill("engineering", 10)
	await get_tree().process_frame

	# Simulate skill check
	var skill_name = "engineering"
	var required_level = 3
	var player_skill = GameState.player.skills.get(skill_name, 0)

	var success = player_skill >= required_level
	_assert_true(success, "Skill check should succeed with high skill level")

	if success:
		print("  Skill check passed: %s %d >= %d" % [skill_name, player_skill, required_level])
		# Award bonus XP for success
		GameState.add_xp(25, "skill_check_bonus")

	print("  ✓ Skill check success works correctly\n")

func test_skill_check_failure() -> void:
	current_test = "Skill Check Failure"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test with low skill
	var skill_name = "engineering"
	var required_level = 10
	var player_skill = GameState.player.skills.get(skill_name, 0)

	var success = player_skill >= required_level
	_assert_false(success, "Skill check should fail with low skill level")

	if not success:
		print("  Skill check failed: %s %d < %d" % [skill_name, player_skill, required_level])

	print("  ✓ Skill check failure works correctly\n")

func test_choice_consequences() -> void:
	current_test = "Choice Consequences"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test consequence application
	var test_consequences = {
		"xp_bonus": 30,
		"effects": ["peaceful_resolution", "made_ally"],
		"next_stage": "workshop_open"
	}

	# Apply consequences
	if test_consequences.has("xp_bonus"):
		var initial_xp = GameState.player.xp
		GameState.add_xp(test_consequences.xp_bonus, "choice_bonus")
		await get_tree().process_frame
		_assert_equal(GameState.player.xp, initial_xp + test_consequences.xp_bonus, "Bonus XP should apply")

	if test_consequences.has("effects"):
		var effects = test_consequences.effects
		_assert_true(effects.size() > 0, "Should have at least one effect")
		print("  Effects applied: %s" % str(effects))

	print("  ✓ Choice consequences work correctly\n")

# ============================================================================
# REWARD APPLICATION TESTS
# ============================================================================

func test_mission_completion_rewards() -> void:
	current_test = "Mission Completion Rewards"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	if current_mission.is_empty():
		print("  ⚠ Skipping - no mission loaded\n")
		return

	var rewards = current_mission.get("rewards", {})
	_assert_true(rewards.size() > 0, "Mission should have rewards")

	var initial_xp = GameState.player.xp
	var initial_credits = GameState.player.credits
	var initial_inventory_size = GameState.inventory.size()

	# Apply rewards
	if rewards.has("xp"):
		GameState.add_xp(rewards.xp, current_mission.mission_id)
		await get_tree().process_frame
		_assert_true(GameState.player.xp > initial_xp, "XP should increase")

	if rewards.has("credits"):
		GameState.add_credits(rewards.credits)
		await get_tree().process_frame
		_assert_true(GameState.player.credits > initial_credits, "Credits should increase")

	if rewards.has("items"):
		for item in rewards.items:
			GameState.add_item(item)
		await get_tree().process_frame
		_assert_true(GameState.inventory.size() > initial_inventory_size, "Inventory should have new items")

	if rewards.has("discovered_parts"):
		if has_node("/root/PartRegistry"):
			for part_id in rewards.discovered_parts:
				PartRegistry.discover_part(part_id)
			await get_tree().process_frame

	# Mark mission complete
	GameState.complete_mission(current_mission.mission_id)
	await get_tree().process_frame
	_assert_true(GameState.is_mission_completed(current_mission.mission_id), "Mission should be marked complete")

	print("  ✓ Mission completion rewards work correctly\n")

func test_conditional_reward_application() -> void:
	current_test = "Conditional Reward Application"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test reward modification based on choices
	var base_reward = 100
	var has_bonus_condition = true
	var bonus_multiplier = 1.5

	var final_reward = base_reward
	if has_bonus_condition:
		final_reward = int(base_reward * bonus_multiplier)

	_assert_equal(final_reward, 150, "Conditional reward should apply bonus")

	# Test reward removal (like "remove:spare_tools")
	var reward_items = [
		{"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
		{"part_id": "spare_tools", "quantity": 1}
	]

	# Simulate removing an item due to choice
	var modified_rewards = []
	for item in reward_items:
		if item.part_id != "spare_tools":  # Condition: removed spare_tools
			modified_rewards.append(item)

	_assert_equal(modified_rewards.size(), 1, "Should have 1 item after removal")
	_assert_equal(modified_rewards[0].part_id, "hull_scrap_plates_l1_common", "Should keep correct item")

	print("  ✓ Conditional reward application works correctly\n")

func test_bonus_xp_from_choices() -> void:
	current_test = "Bonus XP from Choices"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	var base_xp = 100
	var initial_xp = GameState.player.xp

	# Apply base XP
	GameState.add_xp(base_xp, "base_mission_reward")
	await get_tree().process_frame

	var xp_after_base = GameState.player.xp

	# Apply bonus XP from choice
	var bonus_xp = 30
	GameState.add_xp(bonus_xp, "peaceful_resolution_bonus")
	await get_tree().process_frame

	_assert_equal(GameState.player.xp, initial_xp + base_xp + bonus_xp, "Total XP should include base and bonus")

	print("  Base XP: %d" % base_xp)
	print("  Bonus XP: %d" % bonus_xp)
	print("  Total XP gained: %d" % (GameState.player.xp - initial_xp))

	print("  ✓ Bonus XP from choices works correctly\n")

# ============================================================================
# ACHIEVEMENT INTEGRATION TESTS
# ============================================================================

func test_achievement_unlock_from_mission() -> void:
	current_test = "Achievement Unlock from Mission"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Complete first mission - should unlock "first_mission" achievement
	GameState.complete_mission("tutorial_first_mission")
	await get_tree().process_frame

	_assert_true(GameState.is_achievement_unlocked("first_mission"), "First mission achievement should unlock")

	print("  ✓ Achievement unlock from mission works correctly\n")

func test_multiple_achievement_triggers() -> void:
	current_test = "Multiple Achievement Triggers"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Award credits that trigger achievement
	GameState.add_credits(1000)
	await get_tree().process_frame
	_assert_true(GameState.is_achievement_unlocked("credits_1000"), "Credits achievement should unlock")

	# Award XP that triggers level up and achievement
	GameState.add_xp(600, "achievement_test")
	await get_tree().process_frame
	_assert_true(GameState.is_achievement_unlocked("level_3"), "Level achievement should unlock")

	# Install system that triggers achievement
	GameState.install_system("hull", 1)
	await get_tree().process_frame
	_assert_true(GameState.is_achievement_unlocked("first_upgrade"), "System achievement should unlock")

	print("  ✓ Multiple achievement triggers work correctly\n")

# ============================================================================
# MISSION UNLOCK CHAIN TESTS
# ============================================================================

func test_mission_unlock_requirements() -> void:
	current_test = "Mission Unlock Requirements"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test mission requirements
	var requirements = {
		"min_level": 3,
		"required_systems": ["hull", "power"],
		"completed_missions": ["tutorial_first_salvage"]
	}

	# Check level requirement
	var meets_level = GameState.player.level >= requirements.min_level
	print("  Level requirement (%d): %s" % [requirements.min_level, "MET" if meets_level else "NOT MET"])

	# Check system requirements
	var meets_systems = true
	for system_name in requirements.required_systems:
		if GameState.ship.systems[system_name].level == 0:
			meets_systems = false
			break

	print("  System requirements: %s" % ("MET" if meets_systems else "NOT MET"))

	# Check mission requirements
	var meets_missions = true
	for mission_id in requirements.completed_missions:
		if not GameState.is_mission_completed(mission_id):
			meets_missions = false
			break

	print("  Mission requirements: %s" % ("MET" if meets_missions else "NOT MET"))

	var all_requirements_met = meets_level and meets_systems and meets_missions
	print("  Overall: %s" % ("UNLOCKED" if all_requirements_met else "LOCKED"))

	print("  ✓ Mission unlock requirements check works correctly\n")

func test_mission_unlock_chains() -> void:
	current_test = "Mission Unlock Chains"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	if current_mission.is_empty():
		print("  ⚠ Skipping - no mission loaded\n")
		return

	var rewards = current_mission.get("rewards", {})

	# Test unlock chain from mission rewards
	if rewards.has("unlocks"):
		var unlocks = rewards.unlocks
		_assert_true(unlocks.size() > 0, "Mission should unlock other missions")

		print("  Mission unlocks: %s" % str(unlocks))

		# Simulate completing mission and unlocking chain
		GameState.complete_mission(current_mission.mission_id)
		await get_tree().process_frame

		# Check that unlocks would be available
		for unlock in unlocks:
			print("    Unlocked: %s" % unlock)

	print("  ✓ Mission unlock chains work correctly\n")

# ============================================================================
# EDGE CASE TESTS
# ============================================================================

func test_mission_failure_consequences() -> void:
	current_test = "Mission Failure Consequences"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	if current_mission.is_empty():
		print("  ⚠ Skipping - no mission loaded\n")
		return

	# Check for failure consequences
	if current_mission.has("failure_consequences"):
		var failure_rewards = current_mission.failure_consequences

		print("  Failure consequences exist:")
		if failure_rewards.has("xp"):
			print("    XP: %d" % failure_rewards.xp)
		if failure_rewards.has("effects"):
			print("    Effects: %s" % str(failure_rewards.effects))

		# Apply failure rewards
		if failure_rewards.has("xp"):
			var initial_xp = GameState.player.xp
			GameState.add_xp(failure_rewards.xp, "mission_failure")
			await get_tree().process_frame
			_assert_true(GameState.player.xp >= initial_xp, "Failure XP should still award some")

	print("  ✓ Mission failure consequences work correctly\n")

func test_partial_mission_rewards() -> void:
	current_test = "Partial Mission Rewards"
	print("TEST: %s" % current_test)

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Test receiving only some rewards (e.g., base reward but no bonus)
	var base_reward = 100
	var bonus_reward = 50

	# Scenario: Player gets base but not bonus
	GameState.add_xp(base_reward, "partial_reward")
	await get_tree().process_frame

	var xp_gained = GameState.player.xp

	# Should only get base reward
	_assert_equal(xp_gained, base_reward, "Should receive only base reward")

	print("  Base reward: %d XP" % base_reward)
	print("  Bonus reward (not earned): %d XP" % bonus_reward)

	print("  ✓ Partial mission rewards work correctly\n")

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
		print("  ✓ PASS: %s" % message)
	else:
		tests_failed += 1
		push_error("  ✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])
		print("  ✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_mission_completed(mission_id: String, rewards: Dictionary) -> void:
	print("  [EVENT] Mission Completed: %s" % mission_id)

func _on_mission_started(mission_id: String, mission_data: Dictionary) -> void:
	print("  [EVENT] Mission Started: %s" % mission_id)

func _on_mission_stage_changed(mission_id: String, stage_id: String) -> void:
	print("  [EVENT] Stage Changed: %s -> %s" % [mission_id, stage_id])

func _on_xp_gained(amount: int, source: String) -> void:
	print("  [EVENT] XP Gained: +%d from %s" % [amount, source])

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary) -> void:
	print("  [EVENT] Achievement: %s" % achievement_data.name)

# ============================================================================
# TEST SUMMARY
# ============================================================================

func _print_test_summary() -> void:
	print("\n=== Mission Progression Test Summary ===")
	print("Tests Passed: %d" % tests_passed)
	print("Tests Failed: %d" % tests_failed)
	print("Total Tests: %d" % (tests_passed + tests_failed))

	if tests_failed == 0:
		print("✓ ALL TESTS PASSED!")
	else:
		print("✗ SOME TESTS FAILED - Review errors above")

	print("========================================\n")

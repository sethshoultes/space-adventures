extends Node

## Achievement System Test Script
## Run this from a test scene or directly via Godot's script editor
## Tests all achievement functionality: unlock, query, save/load, and signals

func _ready() -> void:
	print("=== Achievement System Test ===\n")

	# Wait for autoloads to be ready
	await get_tree().process_frame

	# Connect to achievement signal
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

	run_all_tests()

func run_all_tests() -> void:
	print("Starting achievement tests...\n")

	test_achievement_initialization()
	test_manual_unlock()
	test_level_achievements()
	test_credit_achievements()
	test_mission_achievements()
	test_system_achievements()
	test_skill_achievements()
	test_part_achievements()
	test_skill_check_achievements()
	test_achievement_queries()
	test_save_load()

	print("\n=== All Tests Complete ===")

## Test 1: Achievement initialization
func test_achievement_initialization() -> void:
	print("TEST 1: Achievement Initialization")

	var achievements = GameState.get_all_achievements()
	print("  Total achievements defined: %d" % achievements.size())

	assert(achievements.size() == 15, "Should have 15 achievements")
	assert(GameState.player.achievements.has("first_mission"), "Should have first_mission achievement")

	print("  ✓ Achievements initialized correctly\n")

## Test 2: Manual unlock
func test_manual_unlock() -> void:
	print("TEST 2: Manual Unlock")

	# Reset to clean state
	GameState.reset_to_new_game()
	await get_tree().process_frame

	var result = GameState.unlock_achievement("first_mission")
	assert(result == true, "First unlock should return true")
	assert(GameState.is_achievement_unlocked("first_mission"), "Achievement should be unlocked")

	# Try unlocking again
	var result2 = GameState.unlock_achievement("first_mission")
	assert(result2 == false, "Second unlock should return false")

	print("  ✓ Manual unlock works correctly\n")

## Test 3: Level achievements
func test_level_achievements() -> void:
	print("TEST 3: Level Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Level up to 3
	GameState.add_xp(600)  # Should level to 3+
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("level_3"), "Level 3 achievement should unlock")
	print("  ✓ Level 3 achievement unlocked")

	# Level up to 5
	GameState.add_xp(2000)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("level_5"), "Level 5 achievement should unlock")
	print("  ✓ Level 5 achievement unlocked\n")

## Test 4: Credit achievements
func test_credit_achievements() -> void:
	print("TEST 4: Credit Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	GameState.add_credits(1000)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("credits_1000"), "1000 credits achievement should unlock")
	print("  ✓ 1000 credits achievement unlocked")

	GameState.add_credits(4000)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("credits_5000"), "5000 credits achievement should unlock")
	print("  ✓ 5000 credits achievement unlocked\n")

## Test 5: Mission achievements
func test_mission_achievements() -> void:
	print("TEST 5: Mission Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Complete first mission
	GameState.complete_mission("test_mission_1")
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("first_mission"), "First mission achievement should unlock")
	print("  ✓ First mission achievement unlocked")

	# Complete 4 more missions (total 5)
	for i in range(2, 6):
		GameState.complete_mission("test_mission_%d" % i)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("five_missions"), "5 missions achievement should unlock")
	print("  ✓ 5 missions achievement unlocked\n")

## Test 6: System achievements
func test_system_achievements() -> void:
	print("TEST 6: System Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Install first system
	GameState.install_system("hull", 1)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("first_upgrade"), "First upgrade achievement should unlock")
	print("  ✓ First upgrade achievement unlocked")

	# Install all 10 systems at level 1
	var systems = ["power", "propulsion", "warp", "life_support", "computer",
	               "sensors", "shields", "weapons", "communications"]
	for sys in systems:
		GameState.install_system(sys, 1)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("ten_systems"), "10 systems achievement should unlock")
	assert(GameState.is_achievement_unlocked("all_systems_level_1"), "All systems level 1 achievement should unlock")
	print("  ✓ 10 systems achievement unlocked")
	print("  ✓ All systems level 1 achievement unlocked\n")

## Test 7: Skill achievements
func test_skill_achievements() -> void:
	print("TEST 7: Skill Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Increase skill to 10
	GameState.increase_skill("engineering", 10)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("skill_master"), "Skill master achievement should unlock")
	print("  ✓ Skill master achievement unlocked\n")

## Test 8: Part discovery achievements
func test_part_achievements() -> void:
	print("TEST 8: Part Discovery Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Simulate discovering 10 parts
	for i in range(10):
		GameState.progress.discovered_parts.append("part_%d" % i)

	# Manually trigger check (normally triggered by EventBus.part_discovered signal)
	GameState._check_part_discovery_achievements()
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("ten_parts"), "10 parts achievement should unlock")
	print("  ✓ 10 parts achievement unlocked")

	# Add 10 more parts
	for i in range(10, 20):
		GameState.progress.discovered_parts.append("part_%d" % i)

	GameState._check_part_discovery_achievements()
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("twenty_parts"), "20 parts achievement should unlock")
	print("  ✓ 20 parts achievement unlocked\n")

## Test 9: Skill check achievements
func test_skill_check_achievements() -> void:
	print("TEST 9: Skill Check Achievements")

	GameState.reset_to_new_game()
	await get_tree().process_frame

	# Record 10 successful skill checks
	for i in range(10):
		GameState.record_skill_check_success()
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("ten_successful_checks"), "10 skill checks achievement should unlock")
	print("  ✓ 10 successful skill checks achievement unlocked\n")

## Test 10: Achievement queries
func test_achievement_queries() -> void:
	print("TEST 10: Achievement Queries")

	var progress = GameState.get_achievement_progress()
	print("  Total achievements: %d" % progress.total)
	print("  Unlocked: %d" % progress.unlocked)
	print("  Percentage: %.1f%%" % progress.percentage)

	assert(progress.total == 15, "Should have 15 total achievements")

	var unlocked = GameState.get_unlocked_achievements()
	print("  Unlocked achievements count: %d" % unlocked.size())

	var all = GameState.get_all_achievements()
	assert(all.size() == 15, "Should return all 15 achievements")

	print("  ✓ Achievement queries work correctly\n")

## Test 11: Save/Load
func test_save_load() -> void:
	print("TEST 11: Save/Load Achievements")

	# Create a save with some achievements
	GameState.reset_to_new_game()
	await get_tree().process_frame

	GameState.unlock_achievement("first_mission")
	GameState.unlock_achievement("level_3")
	await get_tree().process_frame

	# Save to file
	var save_data = GameState.to_dict()
	assert(save_data.player.has("achievements"), "Save data should include achievements")
	assert(save_data.player.achievements.has("first_mission"), "Save should have first_mission")
	print("  ✓ Achievements included in save data")

	# Load from save
	GameState.reset_to_new_game()
	await get_tree().process_frame

	GameState.from_dict(save_data)
	await get_tree().process_frame

	assert(GameState.is_achievement_unlocked("first_mission"), "Loaded game should have first_mission unlocked")
	assert(GameState.is_achievement_unlocked("level_3"), "Loaded game should have level_3 unlocked")
	assert(not GameState.is_achievement_unlocked("five_missions"), "Loaded game should not have five_missions")

	print("  ✓ Achievements persist through save/load\n")

## Signal handler for achievement unlocks
func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary) -> void:
	print("  🏆 ACHIEVEMENT UNLOCKED: %s - %s" % [achievement_data.name, achievement_data.description])

extends Node

## END-TO-END STORY INTEGRATION TEST
## This script tests the complete chain from mission loading to narrative generation

func _ready() -> void:
	print("=== STORY INTEGRATION TEST STARTING ===\n")
	await get_tree().process_frame
	await run_all_tests()
	print("\n=== STORY INTEGRATION TEST COMPLETE ===")
	get_tree().quit()


func run_all_tests() -> void:
	var all_passed = true

	# Test 1: Check autoload singletons exist
	print("[TEST 1] Checking autoload singletons...")
	if not await test_singletons():
		all_passed = false
		return

	# Test 2: Check AI service availability
	print("\n[TEST 2] Checking AI service availability...")
	if not await test_ai_service():
		all_passed = false
		return

	# Test 3: Load and verify hybrid mission
	print("\n[TEST 3] Loading hybrid mission...")
	var mission = await test_load_hybrid_mission()
	if not mission:
		all_passed = false
		return

	# Test 4: Test hybrid detection
	print("\n[TEST 4] Testing hybrid detection...")
	if not test_hybrid_detection(mission):
		all_passed = false
		return

	# Test 5: Test StoryService API call
	print("\n[TEST 5] Testing StoryService API call...")
	if not await test_story_service_api(mission):
		all_passed = false
		return

	# Test 6: Test full narrative generation flow
	print("\n[TEST 6] Testing full narrative generation...")
	if not await test_narrative_generation(mission):
		all_passed = false
		return

	if all_passed:
		print("\n✅ ALL TESTS PASSED - Integration is working!")
	else:
		print("\n❌ SOME TESTS FAILED - Integration has issues")


## TEST 1: Singletons
func test_singletons() -> bool:
	var required_singletons = [
		"ServiceManager",
		"StoryService",
		"GameState",
		"MissionManager"
	]

	for singleton_name in required_singletons:
		if not has_node("/root/" + singleton_name):
			print("  ❌ FAIL: %s singleton not found" % singleton_name)
			return false
		else:
			print("  ✅ PASS: %s exists" % singleton_name)

	return true


## TEST 2: AI Service
func test_ai_service() -> bool:
	# Check ServiceManager status
	var services_status = ServiceManager.check_all_services()
	print("  Service status: %s" % JSON.stringify(services_status))

	if not services_status.has("ai"):
		print("  ❌ FAIL: AI service not in ServiceManager")
		return false

	if not services_status.ai.available:
		print("  ❌ FAIL: AI service not available")
		print("    URL checked: %s" % services_status.ai.url)
		print("    Error: %s" % services_status.ai.get("error", "Unknown"))
		return false

	print("  ✅ PASS: AI service is available at %s" % services_status.ai.url)

	# Check StoryService.is_available()
	var story_available = StoryService.is_available()
	if not story_available:
		print("  ❌ FAIL: StoryService.is_available() returned false")
		return false

	print("  ✅ PASS: StoryService.is_available() returned true")
	return true


## TEST 3: Load Hybrid Mission
func test_load_hybrid_mission() -> Dictionary:
	var mission_path = "res://assets/data/missions/mission_tutorial_hybrid.json"

	if not FileAccess.file_exists(mission_path):
		print("  ❌ FAIL: Hybrid mission file not found: %s" % mission_path)
		return {}

	var file = FileAccess.open(mission_path, FileAccess.READ)
	if not file:
		print("  ❌ FAIL: Could not open hybrid mission file")
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		print("  ❌ FAIL: Could not parse hybrid mission JSON")
		print("    Error: %s" % json.get_error_message())
		return {}

	var mission = json.data

	if typeof(mission) != TYPE_DICTIONARY:
		print("  ❌ FAIL: Mission is not a dictionary")
		return {}

	print("  ✅ PASS: Hybrid mission loaded successfully")
	print("    Mission ID: %s" % mission.get("mission_id", "N/A"))
	print("    Title: %s" % mission.get("title", "N/A"))
	print("    Type: %s" % mission.get("type", "N/A"))
	print("    Stages: %d" % mission.get("stages", []).size())

	return mission


## TEST 4: Hybrid Detection
func test_hybrid_detection(mission: Dictionary) -> bool:
	if not mission.has("stages") or mission.stages.size() == 0:
		print("  ❌ FAIL: Mission has no stages")
		return false

	var first_stage = mission.stages[0]

	# Check if stage has narrative_structure
	if not first_stage.has("narrative_structure"):
		print("  ❌ FAIL: First stage does not have narrative_structure")
		print("    Stage keys: %s" % first_stage.keys())
		return false

	print("  ✅ PASS: Stage has narrative_structure field")

	var narrative_structure = first_stage.narrative_structure
	print("    Setup: %s" % narrative_structure.get("setup", "N/A"))
	print("    Conflict: %s" % narrative_structure.get("conflict", "N/A"))
	print("    Has prompt: %s" % narrative_structure.has("prompt"))

	return true


## TEST 5: StoryService API Call
func test_story_service_api(mission: Dictionary) -> bool:
	var first_stage = mission.stages[0]

	# Build request data
	var request_data = {
		"player_id": "test_player_" + str(Time.get_unix_time_from_system()),
		"mission_template": mission,
		"stage_id": first_stage.get("stage_id", ""),
		"player_state": {
			"level": 1,
			"phase": 1,
			"completed_missions": []
		}
	}

	print("  Calling StoryService.generate_narrative()...")
	print("    Player ID: %s" % request_data.player_id)
	print("    Stage ID: %s" % request_data.stage_id)

	var result = await StoryService.generate_narrative(request_data)

	if not result:
		print("  ❌ FAIL: StoryService.generate_narrative() returned null")
		return false

	if typeof(result) != TYPE_DICTIONARY:
		print("  ❌ FAIL: Result is not a dictionary")
		return false

	if not result.has("success"):
		print("  ❌ FAIL: Result does not have 'success' field")
		print("    Result keys: %s" % result.keys())
		return false

	if not result.success:
		print("  ❌ FAIL: API call failed")
		print("    Error: %s" % result.get("error", "Unknown"))
		return false

	if not result.has("narrative"):
		print("  ❌ FAIL: Result does not have 'narrative' field")
		return false

	print("  ✅ PASS: StoryService API call successful")
	print("    Narrative length: %d characters" % result.narrative.length())
	print("    Cached: %s" % result.get("cached", false))
	print("    Generation time: %dms" % result.get("generation_time_ms", 0))
	print("    First 100 chars: %s..." % result.narrative.substr(0, 100))

	return true


## TEST 6: Full Narrative Generation
func test_narrative_generation(mission: Dictionary) -> bool:
	var first_stage = mission.stages[0]

	# Simulate what mission.gd does
	print("  Simulating mission.gd narrative generation flow...")

	# Check if hybrid stage (same as mission.gd line 1121-1123)
	var is_hybrid = first_stage.has("narrative_structure")

	if not is_hybrid:
		print("  ❌ FAIL: Stage is not detected as hybrid")
		return false

	print("  ✅ Stage detected as hybrid")

	# Check StoryService availability (same as mission.gd line 1137)
	if not StoryService.is_available():
		print("  ❌ FAIL: StoryService not available at generation time")
		return false

	print("  ✅ StoryService is available")

	# Generate narrative (same as mission.gd lines 1142-1152)
	var request_data = {
		"player_id": StoryService.get_player_id(),
		"mission_template": mission,
		"stage_id": first_stage.get("stage_id", ""),
		"player_state": StoryService.build_player_state(),
		"world_context": null
	}

	print("  Generating narrative...")
	var result = await StoryService.generate_narrative(request_data)

	# Check result (same as mission.gd lines 1154-1161)
	if not result.success:
		print("  ❌ FAIL: Narrative generation failed")
		print("    Error: %s" % result.get("error", "Unknown"))
		return false

	var narrative = result.narrative

	if narrative.is_empty():
		print("  ❌ FAIL: Generated narrative is empty")
		return false

	print("  ✅ PASS: Full narrative generation flow successful")
	print("    Final narrative: %s" % narrative)

	return true

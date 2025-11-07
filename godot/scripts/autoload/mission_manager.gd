extends Node

## MissionManager Singleton
## Handles loading, tracking, and managing missions
## Provides mission data to UI and handles mission progression

const MISSIONS_DIR: String = "res://assets/data/missions/"

# Current mission state
var current_mission: Dictionary = {}
var current_stage_id: String = ""
var mission_effects: Array[String] = []  # Effects accumulated during mission
var mission_active: bool = false

# Mission cache (all loaded missions)
var loaded_missions: Dictionary = {}

func _ready() -> void:
	print("MissionManager initialized")
	_load_all_missions()

## Load all mission files from the missions directory
func _load_all_missions() -> void:
	var dir = DirAccess.open(MISSIONS_DIR)
	if dir == null:
		push_error("MissionManager: Failed to open missions directory: " + MISSIONS_DIR)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".json"):
			var mission_path = MISSIONS_DIR + file_name
			var mission = _load_mission_file(mission_path)
			if not mission.is_empty():
				loaded_missions[mission.mission_id] = mission
				print("MissionManager: Loaded mission '%s' (%s)" % [mission.title, mission.mission_id])

		file_name = dir.get_next()

	dir.list_dir_end()
	print("MissionManager: Loaded %d missions" % loaded_missions.size())

## Load a single mission JSON file
func _load_mission_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("MissionManager: Mission file not found: " + path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("MissionManager: Failed to open mission file: " + path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("MissionManager: Failed to parse mission JSON: " + json.get_error_message())
		return {}

	var mission_data = json.data
	if not _validate_mission(mission_data):
		push_error("MissionManager: Invalid mission structure in: " + path)
		return {}

	return mission_data

## Validate mission structure
func _validate_mission(mission: Dictionary) -> bool:
	var required_fields = ["mission_id", "title", "type", "stages"]
	for field in required_fields:
		if not mission.has(field):
			push_error("MissionManager: Missing required field: " + field)
			return false

	if not mission.stages is Array or mission.stages.size() == 0:
		push_error("MissionManager: Mission has no stages")
		return false

	return true

## Start a mission
func start_mission(mission_id: String) -> bool:
	if not loaded_missions.has(mission_id):
		push_error("MissionManager: Mission not found: " + mission_id)
		EventBus.show_error.emit("Mission Error", "Mission not found: " + mission_id)
		return false

	# Check requirements
	var mission = loaded_missions[mission_id]
	if not _check_requirements(mission):
		return false

	# Initialize mission
	current_mission = mission.duplicate(true)
	current_stage_id = current_mission.stages[0].stage_id
	mission_effects = []
	mission_active = true

	print("MissionManager: Started mission '%s'" % mission.title)
	EventBus.mission_started.emit(mission_id, current_mission)

	return true

## Check if player meets mission requirements
func _check_requirements(mission: Dictionary) -> bool:
	if not mission.has("requirements"):
		return true

	var reqs = mission.requirements

	# Check player level
	if reqs.has("min_level"):
		if GameState.player.level < reqs.min_level:
			EventBus.show_error.emit("Mission Locked", "Requires player level %d" % reqs.min_level)
			return false

	# Check required systems
	if reqs.has("required_systems") and reqs.required_systems is Array:
		for system_name in reqs.required_systems:
			if GameState.ship.systems[system_name].level == 0:
				EventBus.show_error.emit("Mission Locked", "Requires %s system installed" % system_name)
				return false

	# Check completed missions
	if reqs.has("completed_missions") and reqs.completed_missions is Array:
		for prereq_mission in reqs.completed_missions:
			if not GameState.is_mission_completed(prereq_mission):
				EventBus.show_error.emit("Mission Locked", "Complete prerequisite missions first")
				return false

	return true

## Get current stage data
func get_current_stage() -> Dictionary:
	if not mission_active:
		return {}

	for stage in current_mission.stages:
		if stage.stage_id == current_stage_id:
			return stage

	push_error("MissionManager: Current stage not found: " + current_stage_id)
	return {}

## Make a choice and advance mission
func make_choice(choice_id: String) -> Dictionary:
	if not mission_active:
		push_error("MissionManager: No active mission")
		return {}

	var stage = get_current_stage()
	if stage.is_empty():
		return {}

	# Find the choice
	var choice: Dictionary = {}
	for c in stage.choices:
		if c.choice_id == choice_id:
			choice = c
			break

	if choice.is_empty():
		push_error("MissionManager: Choice not found: " + choice_id)
		return {}

	# Check choice requirements
	if not _check_choice_requirements(choice):
		return {"success": false, "reason": "Requirements not met"}

	# Determine success/failure
	var result = _resolve_choice(choice)

	# Apply consequences
	_apply_consequences(result.consequence)

	# Advance to next stage or complete mission
	if result.consequence.has("next_stage"):
		current_stage_id = result.consequence.next_stage
		EventBus.mission_stage_changed.emit(current_mission.mission_id, current_stage_id)
	elif result.consequence.has("mission_complete"):
		_complete_mission(result.consequence.get("success", true))
	elif result.consequence.has("mission_failed"):
		_fail_mission(result.consequence.get("reason", "Mission failed"))

	return result

## Check if player meets choice requirements
func _check_choice_requirements(choice: Dictionary) -> bool:
	if not choice.has("requirements"):
		return true

	var reqs = choice.requirements

	# Check skill requirement
	if reqs.has("skill") and reqs.has("skill_level"):
		var skill_name = reqs.skill
		var required_level = reqs.skill_level
		var player_skill = GameState.player.skills.get(skill_name, 0)

		if player_skill < required_level:
			return false

	# Check system requirements
	if reqs.has("system") and reqs.has("system_level"):
		var system_name = reqs.system
		var required_level = reqs.system_level
		var system_level = GameState.ship.systems.get(system_name, {}).get("level", 0)

		if system_level < required_level:
			return false

	return true

## Resolve a choice (success/failure based on chance and skills)
func _resolve_choice(choice: Dictionary) -> Dictionary:
	var success_chance = choice.get("success_chance", 100)

	# Skill-based check
	if success_chance is String and success_chance == "skill_based":
		if choice.has("requirements") and choice.requirements.has("skill"):
			var skill_name = choice.requirements.skill
			var required_level = choice.requirements.get("skill_level", 0)
			var player_skill = GameState.player.skills.get(skill_name, 0)

			# Success if player meets or exceeds skill level
			var success = player_skill >= required_level
			var consequence = choice.consequences.success if success else choice.consequences.get("failure", {})

			return {
				"success": success,
				"consequence": consequence
			}
	# Percentage-based check
	elif success_chance is int or success_chance is float:
		var roll = randi() % 100
		var success = roll < success_chance
		var consequence = choice.consequences.success if success else choice.consequences.get("failure", {})

		return {
			"success": success,
			"consequence": consequence
		}

	# Default: always succeed
	return {
		"success": true,
		"consequence": choice.consequences.get("success", {})
	}

## Apply consequences of a choice
func _apply_consequences(consequence: Dictionary) -> void:
	# Add effects to mission tracking
	if consequence.has("effects") and consequence.effects is Array:
		for effect in consequence.effects:
			if effect not in mission_effects:
				mission_effects.append(effect)

	# Grant XP bonus
	if consequence.has("xp_bonus"):
		GameState.add_xp(consequence.xp_bonus, "mission_choice")

	# Add items to inventory
	if consequence.has("items") and consequence.items is Array:
		for item_id in consequence.items:
			# TODO: Implement item system
			print("MissionManager: Would add item: " + item_id)

	# Modify skills
	if consequence.has("skill_changes") and consequence.skill_changes is Dictionary:
		for skill_name in consequence.skill_changes:
			var change = consequence.skill_changes[skill_name]
			GameState.increase_skill(skill_name, change)

## Complete the mission
func _complete_mission(success: bool = true) -> void:
	if not mission_active:
		return

	print("MissionManager: Mission completed - %s" % current_mission.title)

	# Award mission rewards
	if current_mission.has("rewards"):
		_award_rewards(current_mission.rewards)

	# Mark mission as completed
	GameState.complete_mission(current_mission.mission_id)

	# Emit completion event
	EventBus.mission_completed.emit(current_mission.mission_id, current_mission.get("rewards", {}))

	# Clear mission state
	mission_active = false
	current_mission = {}
	current_stage_id = ""
	mission_effects = []

## Fail the mission
func _fail_mission(reason: String) -> void:
	print("MissionManager: Mission failed - %s: %s" % [current_mission.title, reason])

	EventBus.mission_failed.emit(current_mission.mission_id, reason)

	# Clear mission state
	mission_active = false
	current_mission = {}
	current_stage_id = ""
	mission_effects = []

## Award an item (could be ship system, part, or inventory item)
func _award_item(item_id: String) -> void:
	# Parse item_id to determine type
	# Format: "system_name_lX" for systems (e.g., "hull_system_l1")
	if item_id.begins_with("hull_system_"):
		var level = int(item_id.substr(-1))
		GameState.install_system("hull", level)
		print("MissionManager: Awarded Hull System Level %d" % level)

	elif item_id.begins_with("power_core_"):
		var level = int(item_id.substr(-1))
		GameState.install_system("power", level)
		print("MissionManager: Awarded Power Core Level %d" % level)

	elif item_id.begins_with("propulsion_system_"):
		var level = int(item_id.substr(-1))
		GameState.install_system("propulsion", level)
		print("MissionManager: Awarded Propulsion System Level %d" % level)

	else:
		# Generic inventory item
		var item = {"id": item_id, "name": item_id, "type": "generic"}
		GameState.add_item(item)
		print("MissionManager: Awarded item: " + item_id)

## Award all rewards (credits, XP, parts, discoveries)
func _award_rewards(rewards: Dictionary) -> void:
	"""Award mission rewards to player"""

	# Award XP (existing functionality)
	if rewards.has("xp"):
		GameState.add_xp(rewards.xp, "mission_completion")

	# Award Credits (NEW)
	if rewards.has("credits"):
		var credits = rewards.credits
		GameState.add_credits(credits)
		print("MissionManager: Awarded %d credits" % credits)

	# Award Items/Parts (UPDATED)
	if rewards.has("items"):
		for item in rewards.items:
			# Support both old format (String) and new format (Dictionary)
			var part_id: String = ""
			var quantity: int = 1

			if item is String:
				# Old format: item_id as string
				_award_item(item)
				continue
			elif item is Dictionary:
				# New format: {part_id: String, quantity: int}
				part_id = item.get("part_id", item.get("item_id", ""))
				quantity = item.get("quantity", 1)
			else:
				push_warning("MissionManager: Invalid item format in mission rewards")
				continue

			if part_id == "":
				continue

			# Validate part exists in PartRegistry
			var part_data = PartRegistry.get_part(part_id)
			if part_data.is_empty():
				push_warning("MissionManager: Invalid part_id in mission rewards: %s" % part_id)
				continue

			# Add to inventory
			for i in range(quantity):
				var item_dict = {
					"part_id": part_id,
					"id": part_id,
					"name": part_data.name,
					"type": part_data.get("type", "part"),
					"weight": part_data.weight,
					"rarity": part_data.rarity,
					"level": part_data.level
				}
				GameState.add_item(item_dict)

			print("MissionManager: Awarded %dx %s" % [quantity, part_data.name])

	# Discover Parts (NEW) - Story-driven unlocks
	if rewards.has("discovered_parts"):
		for part_id in rewards.discovered_parts:
			if PartRegistry.is_part_unlocked(part_id):
				continue  # Already discovered

			PartRegistry.discover_part(part_id)
			var part_data = PartRegistry.get_part(part_id)
			if not part_data.is_empty():
				print("MissionManager: Discovered new part: %s" % part_data.name)
				# EventBus.part_discovered is emitted by PartRegistry.discover_part()

## Get list of available missions (player can start)
func get_available_missions() -> Array:
	var available = []

	for mission_id in loaded_missions:
		var mission = loaded_missions[mission_id]

		# Skip completed missions
		if GameState.is_mission_completed(mission_id):
			continue

		# Check if player meets requirements
		if _check_requirements(mission):
			available.append(mission)

	return available

## Get mission by ID
func get_mission(mission_id: String) -> Dictionary:
	return loaded_missions.get(mission_id, {})

## Check if a mission is active
func is_mission_active() -> bool:
	return mission_active

## Get active mission info
func get_active_mission() -> Dictionary:
	return current_mission

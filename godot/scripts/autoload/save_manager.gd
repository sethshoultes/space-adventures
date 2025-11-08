extends Node

## SaveManager Singleton
## Handles saving and loading game state to/from JSON files
## Supports multiple save slots with metadata

const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_PREFIX: String = "save_slot_"
const SAVE_FILE_EXTENSION: String = ".json"
const MAX_SAVE_SLOTS: int = 5

func _ready() -> void:
	print("SaveManager initialized")
	_ensure_save_directory()

## Ensure the saves directory exists
func _ensure_save_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			var error = dir.make_dir("saves")
			if error == OK:
				print("SaveManager: Created saves directory")
			else:
				push_error("SaveManager: Failed to create saves directory: " + str(error))
	else:
		push_error("SaveManager: Failed to access user:// directory")

## Get full path for a save slot
func _get_save_path(slot: int) -> String:
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION

## Save current game state to a slot
func save_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		push_error("SaveManager: Invalid save slot: %d (must be 1-%d)" % [slot, MAX_SAVE_SLOTS])
		EventBus.save_load_error.emit("Invalid save slot")
		return false

	var save_path = _get_save_path(slot)
	var game_data = GameState.to_dict()

	# Add save metadata
	var save_data = {
		"metadata": {
			"slot": slot,
			"timestamp": Time.get_unix_time_from_system(),
			"save_date": Time.get_datetime_string_from_system(),
			"player_name": game_data.player.name,
			"player_level": game_data.player.level,
			"player_rank": game_data.player.rank,
			"ship_name": game_data.ship.name,
			"ship_class": game_data.ship.ship_class,
			"phase": game_data.progress.phase,
			"playtime_seconds": game_data.progress.playtime_seconds,
			"completed_missions": game_data.progress.completed_missions.size()
		},
		"game_state": game_data
	}

	# Convert to JSON
	var json_string = JSON.stringify(save_data, "\t")  # Pretty print with tabs

	# Write to file
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("SaveManager: Failed to open save file for writing: " + str(error))
		EventBus.save_load_error.emit("Failed to create save file")
		return false

	file.store_string(json_string)
	file.close()

	print("SaveManager: Game saved to slot %d" % slot)
	EventBus.game_saved.emit(slot, Time.get_unix_time_from_system())
	EventBus.notify("Game saved to slot %d" % slot, "success")

	return true

## Load game state from a slot
func load_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		push_error("SaveManager: Invalid save slot: %d (must be 1-%d)" % [slot, MAX_SAVE_SLOTS])
		EventBus.save_load_error.emit("Invalid save slot")
		return false

	var save_path = _get_save_path(slot)

	# Check if save file exists
	if not FileAccess.file_exists(save_path):
		push_warning("SaveManager: Save file does not exist: " + save_path)
		EventBus.save_load_error.emit("Save file not found")
		return false

	# Read file
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("SaveManager: Failed to open save file for reading: " + str(error))
		EventBus.save_load_error.emit("Failed to open save file")
		return false

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("SaveManager: Failed to parse save file JSON: " + json.get_error_message())
		EventBus.save_load_error.emit("Save file corrupted")
		return false

	var save_data = json.data

	# Validate save data structure
	if not save_data.has("metadata") or not save_data.has("game_state"):
		push_error("SaveManager: Invalid save file structure")
		EventBus.save_load_error.emit("Save file corrupted")
		return false

	# Load game state
	var game_state = save_data.game_state
	GameState.from_dict(game_state)

	print("SaveManager: Game loaded from slot %d" % slot)
	EventBus.game_loaded.emit(slot, game_state)
	EventBus.notify("Game loaded from slot %d" % slot, "success")

	return true

## Delete a save file
func delete_save(slot: int) -> bool:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		push_error("SaveManager: Invalid save slot: %d" % slot)
		return false

	var save_path = _get_save_path(slot)

	if not FileAccess.file_exists(save_path):
		push_warning("SaveManager: Save file does not exist: " + save_path)
		return false

	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		var error = dir.remove(_get_save_filename(slot))
		if error == OK:
			print("SaveManager: Deleted save slot %d" % slot)
			EventBus.notify("Save slot %d deleted" % slot, "info")
			return true
		else:
			push_error("SaveManager: Failed to delete save file: " + str(error))
			return false
	else:
		push_error("SaveManager: Failed to access saves directory")
		return false

## Get save filename without path
func _get_save_filename(slot: int) -> String:
	return SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION

## Check if a save slot has a save file
func save_exists(slot: int) -> bool:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return false
	return FileAccess.file_exists(_get_save_path(slot))

## Get save file metadata without loading the full game state
func get_save_info(slot: int) -> Dictionary:
	if not save_exists(slot):
		return {}

	var save_path = _get_save_path(slot)
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return {}

	var save_data = json.data
	if save_data.has("metadata"):
		return save_data.metadata
	return {}

## Get all save slots with their metadata
func get_all_save_info() -> Array:
	var saves = []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		var info = get_save_info(slot)
		if info.is_empty():
			# Empty slot
			saves.append({
				"slot": slot,
				"exists": false
			})
		else:
			# Existing save
			info.exists = true
			saves.append(info)
	return saves

## Quick save to slot 1
func quick_save() -> bool:
	print("SaveManager: Quick saving...")
	return save_game(1)

## Quick load from slot 1
func quick_load() -> bool:
	print("SaveManager: Quick loading...")
	return load_game(1)

## Auto-save (uses slot 0 - not accessible to player, reserved for auto-save)
func auto_save() -> bool:
	var auto_save_path = SAVE_DIR + "autosave" + SAVE_FILE_EXTENSION
	var game_data = GameState.to_dict()

	var save_data = {
		"metadata": {
			"slot": 0,
			"timestamp": Time.get_unix_time_from_system(),
			"save_date": Time.get_datetime_string_from_system(),
			"autosave": true
		},
		"game_state": game_data
	}

	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(auto_save_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Auto-save failed")
		return false

	file.store_string(json_string)
	file.close()

	print("SaveManager: Auto-save complete")
	return true

## Auto-load - Load the auto-save file if it exists
func auto_load() -> bool:
	var auto_save_path = SAVE_DIR + "autosave" + SAVE_FILE_EXTENSION

	# Check if auto-save exists
	if not FileAccess.file_exists(auto_save_path):
		print("SaveManager: No auto-save file found")
		return false

	# Read file
	var file = FileAccess.open(auto_save_path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open auto-save file")
		return false

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("SaveManager: Failed to parse auto-save JSON: " + json.get_error_message())
		return false

	var save_data = json.data

	# Validate structure
	if not save_data.has("game_state"):
		push_error("SaveManager: Invalid auto-save structure")
		return false

	# Load game state
	var game_state = save_data.game_state
	GameState.from_dict(game_state)

	print("SaveManager: Auto-save loaded successfully")
	return true

## Format playtime for display
func format_playtime(seconds: float) -> String:
	var hours = int(seconds) / 3600
	var minutes = (int(seconds) % 3600) / 60
	var secs = int(seconds) % 60

	if hours > 0:
		return "%dh %dm" % [hours, minutes]
	elif minutes > 0:
		return "%dm %ds" % [minutes, secs]
	else:
		return "%ds" % secs

## Get formatted save info for display
func get_formatted_save_info(slot: int) -> String:
	var info = get_save_info(slot)
	if info.is_empty():
		return "Empty Slot"

	var lines = []
	lines.append("%s - Level %d %s" % [info.player_name, info.player_level, info.player_rank])
	lines.append("Ship: %s (%s)" % [info.ship_name, info.ship_class])
	lines.append("Missions: %d | Playtime: %s" % [info.completed_missions, format_playtime(info.playtime_seconds)])
	lines.append("Saved: %s" % info.save_date)

	return "\n".join(lines)

## Get the most recent save slot number
## Returns slot number (1-MAX_SAVE_SLOTS) or -1 if no saves exist
func get_most_recent_save() -> int:
	var most_recent_slot = -1
	var most_recent_time = 0.0

	for slot in range(1, MAX_SAVE_SLOTS + 1):
		if save_exists(slot):
			var info = get_save_info(slot)
			if not info.is_empty():
				var timestamp = info.get("timestamp", 0.0)
				if timestamp > most_recent_time:
					most_recent_time = timestamp
					most_recent_slot = slot

	return most_recent_slot

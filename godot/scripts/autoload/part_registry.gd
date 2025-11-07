extends Node

## PartRegistry Singleton
## Central data authority for ship parts, upgrade costs, and economy configuration
##
## Purpose:
##   - Load and cache all part definitions from JSON files
##   - Provide O(1) lookup for parts by ID, system, rarity
##   - Manage part discovery state (story unlocks)
##   - Calculate upgrade costs (credits + parts)
##   - Provide economy configuration (XP curve, skill points, inventory capacity)
##
## Load Order:
##   1. Economy config (foundational rules)
##   2. System config (system definitions)
##   3. Part files (bulk data)
##   4. Discovered parts from GameState (player progress)
##   5. Build caches and indexes
##
## Integration Points:
##   - GameState: Read credits, inventory, discovered_parts
##   - EventBus: Emit part_discovered signals
##   - Workshop UI: Query parts, costs, requirements
##   - Ship Systems: Check upgrade requirements
##   - MissionManager: Award parts, unlock discoveries

# ============================================================================
# CONSTANTS
# ============================================================================

const DATA_PATH = "res://assets/data/"
const PARTS_PATH = DATA_PATH + "parts/"
const SYSTEMS_PATH = DATA_PATH + "systems/"
const ECONOMY_PATH = DATA_PATH + "economy/"

const PART_FILES = [
	"hull_parts.json",
	"power_parts.json",
	"propulsion_parts.json",
	"warp_parts.json",
	"life_support_parts.json",
	"computer_parts.json",
	"sensors_parts.json",
	"shields_parts.json",
	"weapons_parts.json",
	"communications_parts.json"
]

# ============================================================================
# STATE
# ============================================================================

# Part data indexed by part_id for O(1) lookup
var _parts_cache: Dictionary = {}

# Parts organized by system type for filtering
# Example: {"hull": [part1, part2, ...], "power": [...], ...}
var _parts_by_system: Dictionary = {}

# Parts organized by rarity tier
var _parts_by_rarity: Dictionary = {
	"common": [],
	"uncommon": [],
	"rare": []
}

# System configurations from ship_systems.json
# Example: {"hull": {config...}, "power": {config...}, ...}
var _systems_config: Dictionary = {}

# Economy configuration from economy_config.json
var _economy_config: Dictionary = {}

# Discovered parts (player progression)
# Key: part_id, Value: bool (true if discovered)
var _discovered_parts: Dictionary = {}

# Loading state flags
var _is_loaded: bool = false
var _load_error: bool = false

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("PartRegistry: Initializing...")
	_load_all_data()

# ============================================================================
# LOADING SYSTEM
# ============================================================================

## Load all data files on startup
func _load_all_data() -> void:
	print("PartRegistry: Loading data files...")

	# Load economy config first (foundational rules)
	if not _load_economy_config():
		_load_error = true
		push_error("PartRegistry: Failed to load economy config")
		return

	# Load system config
	if not _load_system_config():
		_load_error = true
		push_error("PartRegistry: Failed to load system config")
		return

	# Load all part files
	var parts_loaded = 0
	for file_name in PART_FILES:
		var file_path = PARTS_PATH + file_name
		if _load_part_file(file_path):
			parts_loaded += 1
		else:
			push_warning("PartRegistry: Failed to load " + file_name)

	# Build indexes for fast lookups
	_build_part_indexes()

	# Load discovered parts from GameState
	_load_discovered_parts()

	_is_loaded = true
	print("PartRegistry: Loaded %d parts from %d/%d files, %d systems configured" % [
		_parts_cache.size(),
		parts_loaded,
		PART_FILES.size(),
		_systems_config.size()
	])

## Load economy configuration JSON
func _load_economy_config() -> bool:
	var file_path = ECONOMY_PATH + "economy_config.json"

	if not FileAccess.file_exists(file_path):
		push_warning("PartRegistry: Economy config not found at: " + file_path)
		# Use default config
		_economy_config = _get_default_economy_config()
		return true

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("PartRegistry: Failed to open economy config: " + file_path)
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("PartRegistry: JSON parse error in %s: %s" % [
			file_path,
			json.get_error_message()
		])
		return false

	_economy_config = json.get_data()
	print("PartRegistry: Economy config loaded")
	return true

## Load ship systems configuration JSON
func _load_system_config() -> bool:
	var file_path = SYSTEMS_PATH + "ship_systems.json"

	if not FileAccess.file_exists(file_path):
		push_warning("PartRegistry: System config not found at: " + file_path)
		# Use default config
		_systems_config = _get_default_system_config()
		return true

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("PartRegistry: Failed to open system config: " + file_path)
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("PartRegistry: JSON parse error in %s: %s" % [
			file_path,
			json.get_error_message()
		])
		return false

	var data = json.get_data()

	if not data.has("systems"):
		push_error("PartRegistry: Invalid system config structure")
		return false

	# Convert array to dictionary indexed by system_name
	for system in data.systems:
		if system.has("system_name"):
			_systems_config[system.system_name] = system

	print("PartRegistry: System config loaded (%d systems)" % _systems_config.size())
	return true

## Load a single part file JSON
func _load_part_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_warning("PartRegistry: Part file not found: " + file_path)
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("PartRegistry: Failed to open part file: " + file_path)
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("PartRegistry: JSON parse error in %s: %s" % [
			file_path,
			json.get_error_message()
		])
		return false

	var data = json.get_data()

	if not data.has("parts"):
		push_error("PartRegistry: Invalid part file structure: " + file_path)
		return false

	# Add parts to cache
	var parts_added = 0
	for part in data.parts:
		if not _validate_part(part):
			push_warning("PartRegistry: Invalid part in %s: %s" % [
				file_path,
				part.get("id", "unknown")
			])
			continue

		var part_id = part.id

		# Check for duplicate IDs
		if _parts_cache.has(part_id):
			push_warning("PartRegistry: Duplicate part ID: " + part_id)

		_parts_cache[part_id] = part
		parts_added += 1

	print("PartRegistry: Loaded %d parts from %s" % [parts_added, file_path.get_file()])
	return true

## Build indexes for fast lookups
func _build_part_indexes() -> void:
	# Clear indexes
	_parts_by_system.clear()
	for rarity in _parts_by_rarity:
		_parts_by_rarity[rarity].clear()

	# Build indexes
	for part_id in _parts_cache:
		var part = _parts_cache[part_id]

		# Index by system type
		var system = part.get("system_type", "")
		if system != "":
			if not _parts_by_system.has(system):
				_parts_by_system[system] = []
			_parts_by_system[system].append(part)

		# Index by rarity
		var rarity = part.get("rarity", "")
		if _parts_by_rarity.has(rarity):
			_parts_by_rarity[rarity].append(part)

	# Sort parts by level and rarity
	for system in _parts_by_system:
		_parts_by_system[system].sort_custom(_sort_parts_by_level_and_rarity)

	print("PartRegistry: Indexes built (%d systems)" % _parts_by_system.size())

## Load discovered parts from GameState
func _load_discovered_parts() -> void:
	# Parts with discovered: true in JSON are unlocked by default
	for part_id in _parts_cache:
		var part = _parts_cache[part_id]
		if part.get("discovered", false):
			_discovered_parts[part_id] = true

	# Load player's discovered parts from GameState (if available)
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		if game_state.progress.has("discovered_parts"):
			for part_id in game_state.progress.discovered_parts:
				_discovered_parts[part_id] = true

	print("PartRegistry: Discovered parts loaded (%d unlocked)" % _discovered_parts.size())

# ============================================================================
# VALIDATION
# ============================================================================

## Validate part data structure
func _validate_part(part: Dictionary) -> bool:
	var required_fields = ["id", "name", "description", "system_type", "level", "rarity", "weight", "stats"]

	for field in required_fields:
		if not part.has(field):
			push_error("PartRegistry: Part missing required field: " + field)
			return false

	# Validate rarity
	if part.rarity not in ["common", "uncommon", "rare"]:
		push_error("PartRegistry: Invalid rarity: " + str(part.rarity))
		return false

	# Validate level
	if part.level < 1 or part.level > 5:
		push_error("PartRegistry: Invalid level: " + str(part.level))
		return false

	# Validate weight
	if part.weight < 0.1 or part.weight > 1000.0:
		push_error("PartRegistry: Invalid weight: " + str(part.weight))
		return false

	return true

## Validate part ID exists
func validate_part_id(part_id: String) -> bool:
	return _parts_cache.has(part_id)

# ============================================================================
# PART QUERIES
# ============================================================================

## Get complete part definition by ID
## Returns empty dictionary if not found
func get_part(part_id: String) -> Dictionary:
	if not _check_loaded():
		return {}

	if not _parts_cache.has(part_id):
		push_warning("PartRegistry: Part not found: " + part_id)
		return {}

	return _parts_cache[part_id]

## Get all parts compatible with a system at a specific level
## Returns array sorted by rarity (common → uncommon → rare)
func get_parts_for_system(system_name: String, level: int = -1) -> Array:
	if not _check_loaded():
		return []

	if not _parts_by_system.has(system_name):
		push_warning("PartRegistry: No parts found for system: " + system_name)
		return []

	var parts = _parts_by_system[system_name]

	# Filter by level if specified
	if level > 0:
		var filtered = []
		for part in parts:
			if part.level == level:
				filtered.append(part)
		return filtered

	return parts

## Get all parts of a specific rarity tier
func get_parts_by_rarity(rarity: String) -> Array:
	if not _check_loaded():
		return []

	if not _parts_by_rarity.has(rarity):
		push_warning("PartRegistry: Invalid rarity: " + rarity)
		return []

	return _parts_by_rarity[rarity]

## Get all loaded parts organized by system type
func get_all_parts() -> Dictionary:
	if not _check_loaded():
		return {}

	return _parts_by_system.duplicate()

# ============================================================================
# PART DISCOVERY
# ============================================================================

## Check if a part has been discovered by the player
func is_part_unlocked(part_id: String) -> bool:
	return _discovered_parts.get(part_id, false)

## Unlock a part for the player (story progression)
func discover_part(part_id: String) -> void:
	if not validate_part_id(part_id):
		push_error("PartRegistry: Cannot discover invalid part: " + part_id)
		return

	if _discovered_parts.has(part_id):
		return  # Already discovered

	_discovered_parts[part_id] = true

	# Save to GameState (if available)
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		if not game_state.progress.has("discovered_parts"):
			game_state.progress.discovered_parts = []

		if part_id not in game_state.progress.discovered_parts:
			game_state.progress.discovered_parts.append(part_id)

	# Emit signal (if EventBus available and has the signal)
	var part = get_part(part_id)
	if not part.is_empty():
		if has_node("/root/EventBus"):
			var event_bus = get_node("/root/EventBus")
			if event_bus.has_signal("part_discovered"):
				event_bus.part_discovered.emit(part_id, part.name)
		print("PartRegistry: Part discovered: %s (%s)" % [part.name, part_id])

## Get list of all discovered part IDs
func get_discovered_parts() -> Array:
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		return game_state.progress.get("discovered_parts", [])
	return []

# ============================================================================
# UPGRADE COSTS
# ============================================================================

## Calculate the cost to upgrade a system using a specific part
## If part_id is empty, uses cheapest common part for that level
func get_upgrade_cost(system_name: String, target_level: int, part_id: String = "") -> Dictionary:
	if not _check_loaded():
		return _error_cost_result("Data not loaded")

	# Get base cost from system config
	var base_cost = get_base_upgrade_cost(system_name, target_level)
	if base_cost.is_empty():
		return _error_cost_result("Invalid system or level")

	# If no part_id specified, find cheapest common part for this level
	if part_id == "":
		var parts = get_parts_for_system(system_name, target_level)
		var common_parts = []
		for part in parts:
			if part.rarity == "common":
				common_parts.append(part)

		if common_parts.is_empty():
			return _error_cost_result("No parts available for this upgrade")

		# Use first common part (already sorted by level)
		part_id = common_parts[0].id

	# Get part details
	var part = get_part(part_id)
	if part.is_empty():
		return _error_cost_result("Part not found")

	# Apply rarity multiplier
	var multiplier = _economy_config.get("upgrade_cost_formula", {}).get("rarity_multipliers", {}).get(part.rarity, 1.0)
	var credits = int(base_cost.credits * multiplier)

	# Check affordability and inventory (if GameState available)
	var player_credits = 0
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		player_credits = game_state.player.get("credits", 0)

	var have_part = _check_player_has_part(part_id)

	return {
		"credits": credits,
		"part_id": part_id,
		"part_name": part.name,
		"rarity": part.rarity,
		"affordable": player_credits >= credits,
		"have_part": have_part,
		"success": true
	}

## Get base upgrade cost from configuration (no rarity multiplier)
func get_base_upgrade_cost(system_name: String, target_level: int) -> Dictionary:
	var config = get_system_config(system_name)
	if config.is_empty():
		return {}

	var costs = config.get("base_upgrade_costs", {})
	var level_key = str(target_level)

	if not costs.has(level_key):
		push_warning("PartRegistry: No cost defined for %s level %d" % [system_name, target_level])
		return {}

	return costs[level_key]

# ============================================================================
# SYSTEM CONFIGURATION
# ============================================================================

## Get complete configuration for a system
func get_system_config(system_name: String) -> Dictionary:
	if not _check_loaded():
		return {}

	if not _systems_config.has(system_name):
		push_warning("PartRegistry: Unknown system: " + system_name)
		return {}

	return _systems_config[system_name]

## Get power consumption for a system at a specific level
func get_power_cost(system_name: String, level: int) -> int:
	var config = get_system_config(system_name)
	if config.is_empty():
		return 0

	var costs = config.get("power_costs", [])
	if level < 1 or level > costs.size():
		return 0

	return costs[level - 1]  # Array is 0-indexed

# ============================================================================
# ECONOMY CONFIGURATION
# ============================================================================

## Get total XP required to reach a level
func get_xp_for_level(level: int) -> int:
	var curve = _economy_config.get("xp_curve", {}).get("levels", [])
	if level < 1 or level > curve.size():
		return 0
	return curve[level - 1]

## Get complete XP curve array
func get_xp_curve() -> Array:
	return _economy_config.get("xp_curve", {}).get("levels", [])

## Get number of skill points awarded per level up
func get_skill_points_per_level() -> int:
	return _economy_config.get("skill_points", {}).get("per_level", 2)

## Get formula for calculating inventory capacity
func get_inventory_capacity_formula() -> String:
	return _economy_config.get("inventory", {}).get("formula", "100 + (50 * hull_level)")

## Calculate inventory capacity for a hull level
func calculate_inventory_capacity(hull_level: int) -> float:
	var base = _economy_config.get("inventory", {}).get("base_capacity_kg", 100.0)
	var per_level = _economy_config.get("inventory", {}).get("capacity_per_hull_level", 50.0)
	return base + (per_level * hull_level)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

## Check if PartRegistry is loaded
func _check_loaded() -> bool:
	if not _is_loaded:
		push_error("PartRegistry: Data not loaded yet!")
		return false
	if _load_error:
		push_error("PartRegistry: Load failed, cannot query data")
		return false
	return true

## Sort parts by level, then rarity
func _sort_parts_by_level_and_rarity(a: Dictionary, b: Dictionary) -> bool:
	if a.level != b.level:
		return a.level < b.level

	# Rarity order: common < uncommon < rare
	var rarity_order = {"common": 0, "uncommon": 1, "rare": 2}
	var a_order = rarity_order.get(a.rarity, 0)
	var b_order = rarity_order.get(b.rarity, 0)
	return a_order < b_order

## Check if player has a part in inventory
func _check_player_has_part(part_id: String) -> bool:
	if not has_node("/root/GameState"):
		return false

	var game_state = get_node("/root/GameState")

	# Check if GameState has inventory system
	if not game_state.has_method("get_part_count"):
		# Fallback: check inventory array directly
		for item in game_state.inventory:
			if item.get("id") == part_id:
				return true
		return false

	return game_state.get_part_count(part_id) > 0

## Return error result for upgrade cost queries
func _error_cost_result(error_message: String) -> Dictionary:
	return {
		"credits": 0,
		"part_id": "",
		"part_name": "",
		"rarity": "",
		"affordable": false,
		"have_part": false,
		"success": false,
		"error": error_message
	}

# ============================================================================
# DEFAULT CONFIGURATIONS (Fallback if files missing)
# ============================================================================

## Get default economy configuration
func _get_default_economy_config() -> Dictionary:
	return {
		"version": "1.0.0",
		"starting_state": {
			"credits": 0,
			"parts": [],
			"discovered_parts": []
		},
		"tutorial_rewards": {
			"credits": 300,
			"parts": []
		},
		"upgrade_cost_formula": {
			"rarity_multipliers": {
				"common": 1.0,
				"uncommon": 1.5,
				"rare": 2.0
			}
		},
		"xp_curve": {
			"levels": [0, 100, 250, 450, 700, 1000]
		},
		"skill_points": {
			"per_level": 2,
			"starting_points": 0,
			"max_skill_level": 10
		},
		"level_cap": {
			"milestone_1": 5
		},
		"inventory": {
			"base_capacity_kg": 100.0,
			"capacity_per_hull_level": 50.0,
			"formula": "100 + (50 * hull_level)"
		}
	}

## Get default system configuration
func _get_default_system_config() -> Dictionary:
	var systems = {}
	var system_names = ["hull", "power", "propulsion", "warp", "life_support",
						"computer", "sensors", "shields", "weapons", "communications"]

	for system_name in system_names:
		systems[system_name] = {
			"system_name": system_name,
			"display_name": system_name.capitalize(),
			"description": "System configuration missing",
			"max_level": 5,
			"milestone_1_max_level": 3,
			"compatible_parts": [],
			"power_costs": [0, 0, 0, 0, 0],
			"base_upgrade_costs": {
				"1": {"credits": 100, "rarity_required": "common"},
				"2": {"credits": 200, "rarity_required": "common"},
				"3": {"credits": 300, "rarity_required": "common"},
				"4": {"credits": 500, "rarity_required": "uncommon"},
				"5": {"credits": 800, "rarity_required": "rare"}
			}
		}

	return systems

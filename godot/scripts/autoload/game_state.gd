extends Node

## GameState Singleton
## Central repository for all game data
## Player, Ship, Inventory, and Progress tracking

# Version for save file compatibility
const VERSION: String = "1.0.0"

# ============================================================================
# PLAYER DATA
# ============================================================================

var player: Dictionary = {
	"name": "Player",
	"level": 1,
	"xp": 0,
	"xp_to_next_level": 200,
	"rank": "Cadet",
	"skills": {
		"engineering": 0,
		"diplomacy": 0,
		"combat": 0,
		"science": 0
	}
}

# ============================================================================
# SHIP DATA
# ============================================================================

var ship: Dictionary = {
	"name": "Unnamed Vessel",
	"ship_class": "None",  # Determined by system configuration
	"systems": {
		"hull": _create_system("hull", 0),
		"power": _create_system("power", 0),
		"propulsion": _create_system("propulsion", 0),
		"warp": _create_system("warp", 0),
		"life_support": _create_system("life_support", 0),
		"computer": _create_system("computer", 0),
		"sensors": _create_system("sensors", 0),
		"shields": _create_system("shields", 0),
		"weapons": _create_system("weapons", 0),
		"communications": _create_system("communications", 0)
	},
	"hull_hp": 0,
	"max_hull_hp": 0,
	"power_available": 0,
	"power_total": 0,
	"power_consumption": 0
}

# ============================================================================
# INVENTORY DATA
# ============================================================================

var inventory: Array = []  # Array of item dictionaries

# ============================================================================
# PROGRESS DATA
# ============================================================================

var progress: Dictionary = {
	"phase": 1,  # 1 = Earthbound (Phase 1), 2 = Space (Phase 2)
	"completed_missions": [],  # Array of mission IDs
	"discovered_locations": [],  # Array of location names
	"major_choices": [],  # Array of choice dictionaries
	"playtime_seconds": 0.0,
	"game_started": 0.0  # Unix timestamp
}

# ============================================================================
# RUNTIME DATA (Not saved)
# ============================================================================

var _playtime_offset: float = 0.0  # For tracking current session

func _ready() -> void:
	print("GameState initialized")
	print("Version: ", VERSION)
	_initialize_game()

func _process(delta: float) -> void:
	# Track playtime
	progress.playtime_seconds += delta

# ============================================================================
# INITIALIZATION
# ============================================================================

func _initialize_game() -> void:
	"""Initialize a new game with default values"""
	progress.game_started = Time.get_unix_time_from_system()
	_playtime_offset = 0.0
	_recalculate_ship_stats()

## Create a ship system dictionary
func _create_system(system_name: String, level: int) -> Dictionary:
	return {
		"name": system_name,
		"level": level,
		"health": 100,
		"max_health": 100,
		"active": false,
		"installed_part": null  # Part item ID if equipped
	}

# ============================================================================
# PLAYER FUNCTIONS
# ============================================================================

## Add XP to player and check for level up
func add_xp(amount: int, source: String = "") -> void:
	var old_level = player.level
	player.xp += amount
	EventBus.xp_gained.emit(amount, source)

	# Check for level up
	while player.xp >= player.xp_to_next_level:
		player.xp -= player.xp_to_next_level
		player.level += 1
		player.xp_to_next_level = _calculate_next_level_xp(player.level)
		EventBus.level_up.emit(player.level, old_level)
		print("Player leveled up! New level: %d" % player.level)

	_update_player_rank()

## Calculate XP needed for next level (exponential curve)
func _calculate_next_level_xp(current_level: int) -> int:
	return int(200 * pow(1.5, current_level - 1))

## Update player rank based on level
func _update_player_rank() -> void:
	var old_rank = player.rank
	var new_rank = _get_rank_for_level(player.level)

	if new_rank != old_rank:
		player.rank = new_rank
		EventBus.rank_changed.emit(new_rank, old_rank)
		print("Rank changed: %s → %s" % [old_rank, new_rank])

## Get rank based on player level
func _get_rank_for_level(level: int) -> String:
	if level >= 20: return "Admiral"
	if level >= 15: return "Captain"
	if level >= 10: return "Commander"
	if level >= 7: return "Lieutenant Commander"
	if level >= 5: return "Lieutenant"
	if level >= 3: return "Ensign"
	return "Cadet"

## Increase a skill
func increase_skill(skill_name: String, amount: int) -> void:
	if not player.skills.has(skill_name):
		push_error("Unknown skill: " + skill_name)
		return

	var old_value = player.skills[skill_name]
	player.skills[skill_name] += amount
	EventBus.skill_increased.emit(skill_name, player.skills[skill_name], old_value)

# ============================================================================
# SHIP FUNCTIONS
# ============================================================================

## Install or upgrade a ship system
func install_system(system_name: String, level: int, part_id: String = "") -> void:
	if not ship.systems.has(system_name):
		push_error("Unknown system: " + system_name)
		return

	var system = ship.systems[system_name]
	system.level = level
	system.health = 100
	system.max_health = 100
	system.active = true
	system.installed_part = part_id if part_id != "" else null

	EventBus.system_installed.emit(system_name, level)
	_recalculate_ship_stats()
	_update_ship_class()

## Damage a ship system
func damage_system(system_name: String, damage: int) -> void:
	if not ship.systems.has(system_name):
		return

	var system = ship.systems[system_name]
	system.health = max(0, system.health - damage)

	EventBus.system_damaged.emit(system_name, damage, system.health)

	if system.health == 0:
		system.active = false
		print("System OFFLINE: %s" % system_name)

## Repair a ship system
func repair_system(system_name: String, repair: int) -> void:
	if not ship.systems.has(system_name):
		return

	var system = ship.systems[system_name]
	system.health = min(system.max_health, system.health + repair)

	EventBus.system_repaired.emit(system_name, repair, system.health)

	if system.health > 0:
		system.active = true

## Recalculate ship stats based on installed systems
func _recalculate_ship_stats() -> void:
	# Calculate max hull HP based on hull system level (from ship-systems.md spec)
	var hull_system = ship.systems.hull
	const HULL_HP_BY_LEVEL = [0, 50, 100, 200, 350, 500]
	ship.max_hull_hp = HULL_HP_BY_LEVEL[hull_system.level] if hull_system.level < 6 else 0

	# Initialize hull HP if this is first installation
	if ship.hull_hp == 0 and ship.max_hull_hp > 0:
		ship.hull_hp = ship.max_hull_hp
	# Cap existing HP to new max if downgraded
	elif ship.hull_hp > ship.max_hull_hp:
		ship.hull_hp = ship.max_hull_hp

	# Calculate power generation from power core (from ship-systems.md spec)
	var power_system = ship.systems.power
	const POWER_BY_LEVEL = [0, 100, 200, 400, 700, 1000]
	ship.power_total = POWER_BY_LEVEL[power_system.level] if power_system.level < 6 else 0

	# Calculate power consumption from all active systems
	ship.power_consumption = _calculate_power_consumption()
	ship.power_available = ship.power_total - ship.power_consumption

	EventBus.ship_power_changed.emit(ship.power_available, ship.power_total, ship.power_consumption)

## Calculate total power consumption
func _calculate_power_consumption() -> int:
	# Power costs by system and level from ship-systems.md spec
	# Format: system_name: [L1, L2, L3, L4, L5]
	const POWER_COSTS = {
		"hull": [0, 0, 0, 0, 10],  # Level 5 only (regeneration)
		"power": [0, 0, 0, 0, 0],  # Generates power, doesn't consume
		"propulsion": [10, 15, 25, 40, 60],
		"warp": [20, 30, 50, 80, 120],
		"life_support": [5, 10, 15, 25, 35],
		"computer": [5, 10, 20, 35, 50],
		"sensors": [5, 10, 20, 35, 50],
		"shields": [15, 25, 40, 60, 85],
		"weapons": [10, 20, 35, 55, 80],
		"communications": [5, 8, 12, 18, 25]
	}

	var total = 0
	for system_name in ship.systems:
		var system = ship.systems[system_name]
		if system.active and system.level > 0:
			if POWER_COSTS.has(system_name):
				var costs = POWER_COSTS[system_name]
				var level_index = system.level - 1  # Array is 0-indexed
				if level_index >= 0 and level_index < costs.size():
					total += costs[level_index]

	return total

## Update ship class based on system configuration
func _update_ship_class() -> void:
	var old_class = ship.ship_class
	var new_class = _determine_ship_class()

	if new_class != old_class:
		ship.ship_class = new_class
		EventBus.ship_class_changed.emit(old_class, new_class)
		print("Ship class: %s → %s" % [old_class, new_class])

## Determine ship class based on installed systems
func _determine_ship_class() -> String:
	# Count installed systems and total levels
	var installed_count = 0
	var total_levels = 0

	for system_name in ship.systems:
		var system = ship.systems[system_name]
		if system.level > 0:
			installed_count += 1
			total_levels += system.level

	# Basic classification (simplified)
	if installed_count < 5:
		return "None"
	elif total_levels >= 40:
		return "Heavy Cruiser"
	elif total_levels >= 30:
		return "Cruiser"
	elif total_levels >= 20:
		return "Frigate"
	else:
		return "Scout"

## Get list of operational systems
func get_operational_systems() -> Array:
	var operational = []
	for system_name in ship.systems:
		var system = ship.systems[system_name]
		if system.active and system.level > 0:
			operational.append(system_name)
	return operational

# ============================================================================
# INVENTORY FUNCTIONS
# ============================================================================

## Add item to inventory
func add_item(item: Dictionary) -> void:
	inventory.append(item)
	EventBus.item_added.emit(item)

## Remove item from inventory
func remove_item(item_id: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i].get("id") == item_id:
			var item = inventory[i]
			inventory.remove_at(i)
			EventBus.item_removed.emit(item)
			return true
	return false

## Get item by ID
func get_item(item_id: String) -> Dictionary:
	for item in inventory:
		if item.get("id") == item_id:
			return item
	return {}

# ============================================================================
# PROGRESS FUNCTIONS
# ============================================================================

## Mark mission as completed
func complete_mission(mission_id: String) -> void:
	if mission_id not in progress.completed_missions:
		progress.completed_missions.append(mission_id)

## Check if mission is completed
func is_mission_completed(mission_id: String) -> bool:
	return mission_id in progress.completed_missions

## Get total completed mission count
func get_completed_missions_count() -> int:
	return progress.completed_missions.size()

## Record a major choice
func record_major_choice(choice_id: String, choice_data: Dictionary) -> void:
	progress.major_choices.append({
		"id": choice_id,
		"data": choice_data,
		"timestamp": Time.get_unix_time_from_system()
	})
	EventBus.major_choice_made.emit(choice_id, choice_data)

# ============================================================================
# SERIALIZATION
# ============================================================================

## Convert game state to dictionary for saving
func to_dict() -> Dictionary:
	return {
		"version": VERSION,
		"player": player.duplicate(true),
		"ship": ship.duplicate(true),
		"inventory": inventory.duplicate(true),
		"progress": progress.duplicate(true),
		"timestamp": Time.get_unix_time_from_system()
	}

## Load game state from dictionary
func from_dict(data: Dictionary) -> void:
	if data.get("version") != VERSION:
		push_warning("Save file version mismatch: %s vs %s" % [data.get("version"), VERSION])

	player = data.get("player", player).duplicate(true)
	ship = data.get("ship", ship).duplicate(true)
	inventory = data.get("inventory", []).duplicate(true)
	progress = data.get("progress", progress).duplicate(true)

	_playtime_offset = progress.playtime_seconds

	print("GameState loaded from save")

## Reset to new game state
func reset_to_new_game() -> void:
	player = {
		"name": "Player",
		"level": 1,
		"xp": 0,
		"xp_to_next_level": 200,
		"rank": "Cadet",
		"skills": {
			"engineering": 0,
			"diplomacy": 0,
			"combat": 0,
			"science": 0
		}
	}

	# Reset all ship systems
	for system_name in ship.systems:
		ship.systems[system_name] = _create_system(system_name, 0)

	ship.name = "Unnamed Vessel"
	ship.ship_class = "None"
	ship.hull_hp = 0
	ship.max_hull_hp = 0
	ship.power_available = 0
	ship.power_total = 0
	ship.power_consumption = 0

	inventory.clear()

	progress = {
		"phase": 1,
		"completed_missions": [],
		"discovered_locations": [],
		"major_choices": [],
		"playtime_seconds": 0.0,
		"game_started": Time.get_unix_time_from_system()
	}

	_initialize_game()
	print("GameState reset to new game")

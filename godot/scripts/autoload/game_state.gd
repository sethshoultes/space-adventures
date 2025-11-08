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
	"credits": 0,  # Player's currency
	"skill_points": 0,  # Unspent skill points from leveling
	"skills": {
		"engineering": 0,
		"diplomacy": 0,
		"combat": 0,
		"science": 0
	},
	"achievements": {}  # Achievement tracking (populated in _ready)
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
	"discovered_parts": [],  # Array of part_id strings (unlocked for use)
	"major_choices": [],  # Array of choice dictionaries
	"playtime_seconds": 0.0,
	"game_started": 0.0  # Unix timestamp
}

# ============================================================================
# ACHIEVEMENT DEFINITIONS
# ============================================================================

## Achievement definitions
## Each achievement has: id, name, description, and tracking data
const ACHIEVEMENTS: Dictionary = {
	"first_mission": {
		"name": "First Steps",
		"description": "Complete your first mission",
		"hidden": false
	},
	"level_3": {
		"name": "Rising Star",
		"description": "Reach level 3",
		"hidden": false
	},
	"level_5": {
		"name": "Experienced Explorer",
		"description": "Reach level 5",
		"hidden": false
	},
	"level_10": {
		"name": "Veteran Commander",
		"description": "Reach level 10",
		"hidden": false
	},
	"first_upgrade": {
		"name": "Engineer's Touch",
		"description": "Upgrade your first ship system",
		"hidden": false
	},
	"all_systems_level_1": {
		"name": "Launch Ready",
		"description": "Bring all ship systems to Level 1",
		"hidden": false
	},
	"ten_systems": {
		"name": "Complete Ship",
		"description": "Unlock all 10 ship systems",
		"hidden": false
	},
	"five_missions": {
		"name": "Mission Runner",
		"description": "Complete 5 missions",
		"hidden": false
	},
	"ten_missions": {
		"name": "Mission Master",
		"description": "Complete 10 missions",
		"hidden": false
	},
	"credits_1000": {
		"name": "Entrepreneur",
		"description": "Collect 1000 credits",
		"hidden": false
	},
	"credits_5000": {
		"name": "Wealthy Trader",
		"description": "Collect 5000 credits",
		"hidden": false
	},
	"skill_master": {
		"name": "Skill Master",
		"description": "Raise any skill to level 10",
		"hidden": false
	},
	"ten_successful_checks": {
		"name": "Lucky Streak",
		"description": "Successfully pass 10 skill checks",
		"hidden": false
	},
	"ten_parts": {
		"name": "Scavenger",
		"description": "Discover 10 different ship parts",
		"hidden": false
	},
	"twenty_parts": {
		"name": "Master Scavenger",
		"description": "Discover 20 different ship parts",
		"hidden": false
	}
}

# ============================================================================
# RUNTIME DATA (Not saved)
# ============================================================================

var _playtime_offset: float = 0.0  # For tracking current session
var _successful_skill_checks: int = 0  # Runtime counter for skill check achievements

func _ready() -> void:
	print("GameState initialized")
	print("Version: ", VERSION)

	# Initialize achievements if empty
	if player.achievements.is_empty():
		_initialize_achievements()

	# Connect to EventBus signals for achievement tracking
	EventBus.part_discovered.connect(_on_part_discovered)

	# Try to load auto-save first
	if SaveManager.auto_load():
		print("GameState: Auto-save loaded successfully")
		# Ensure any new achievements are added to existing save
		_initialize_achievements()
	else:
		print("GameState: No auto-save found, starting new game")
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
	_initialize_achievements()
	_recalculate_ship_stats()

## Initialize achievements dictionary with all defined achievements
func _initialize_achievements() -> void:
	"""Initialize or update achievements dictionary"""
	for achievement_id in ACHIEVEMENTS:
		# Only add if not already exists (preserves existing progress)
		if not player.achievements.has(achievement_id):
			player.achievements[achievement_id] = {
				"id": achievement_id,
				"name": ACHIEVEMENTS[achievement_id].name,
				"description": ACHIEVEMENTS[achievement_id].description,
				"hidden": ACHIEVEMENTS[achievement_id].hidden,
				"unlocked": false,
				"unlocked_at": 0.0  # Unix timestamp when unlocked
			}

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
	player.xp += amount
	EventBus.xp_gained.emit(amount, source)

	# Check for level up (can level up multiple times)
	while player.xp >= player.xp_to_next_level:
		player.xp -= player.xp_to_next_level
		player.level += 1

		# Award skill points (from PartRegistry economy config)
		var skill_points_gained = 2  # Default
		if has_node("/root/PartRegistry"):
			skill_points_gained = PartRegistry.get_skill_points_per_level()

		player.skill_points += skill_points_gained

		# Update XP needed for next level
		player.xp_to_next_level = _calculate_next_level_xp(player.level)

		# Emit level up signal
		EventBus.level_up.emit(player.level, skill_points_gained)
		print("Player leveled up! New level: %d, gained %d skill points" % [player.level, skill_points_gained])

		# Check level achievements
		_check_level_achievements()

	_update_player_rank()

## Calculate XP needed for next level (uses PartRegistry XP curve)
func _calculate_next_level_xp(current_level: int) -> int:
	# Use PartRegistry economy config if available
	if has_node("/root/PartRegistry"):
		var xp_required = PartRegistry.get_xp_for_level(current_level)
		if xp_required > 0:
			return xp_required

	# Fallback to hardcoded exponential curve
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

	# Check skill achievements
	_check_skill_achievements()

# ============================================================================
# ECONOMY FUNCTIONS
# ============================================================================

## Add credits to player's balance
func add_credits(amount: int) -> void:
	if amount < 0:
		push_warning("GameState.add_credits: Amount should be positive (%d)" % amount)
		return

	player.credits += amount
	EventBus.credits_changed.emit(player.credits)
	print("Credits added: +%d (Total: %d)" % [amount, player.credits])

	# Check credit achievements
	_check_credit_achievements()

## Spend credits if player can afford it
## Returns true if successful, false if insufficient funds
func spend_credits(amount: int) -> bool:
	if amount < 0:
		push_error("GameState.spend_credits: Amount must be positive (%d)" % amount)
		return false

	if player.credits < amount:
		print("Insufficient credits: Need %d, have %d" % [amount, player.credits])
		return false

	player.credits -= amount
	EventBus.credits_changed.emit(player.credits)
	print("Credits spent: -%d (Remaining: %d)" % [amount, player.credits])
	return true

## Check if player can afford a purchase
func can_afford(amount: int) -> bool:
	return player.credits >= amount

# ============================================================================
# SKILL POINTS
# ============================================================================

## Allocate a skill point to increase a skill by 1
## Returns true if successful, false if no skill points available
func allocate_skill_point(skill_name: String) -> bool:
	if not player.skills.has(skill_name):
		push_error("Unknown skill: " + skill_name)
		return false

	if player.skill_points <= 0:
		print("No skill points available to allocate")
		return false

	player.skill_points -= 1
	player.skills[skill_name] += 1

	EventBus.skill_allocated.emit(skill_name, player.skills[skill_name])
	print("Skill point allocated: %s +1 (Total: %d, Points remaining: %d)" % [
		skill_name,
		player.skills[skill_name],
		player.skill_points
	])
	return true

## Get number of unspent skill points
func get_available_skill_points() -> int:
	return player.skill_points

# ============================================================================
# ACHIEVEMENT FUNCTIONS
# ============================================================================

## Unlock an achievement
## Returns true if newly unlocked, false if already unlocked
func unlock_achievement(achievement_id: String) -> bool:
	if not ACHIEVEMENTS.has(achievement_id):
		push_error("Unknown achievement: " + achievement_id)
		return false

	# Initialize achievements if needed
	if not player.achievements.has(achievement_id):
		_initialize_achievements()

	var achievement = player.achievements[achievement_id]

	# Already unlocked - don't unlock again
	if achievement.unlocked:
		return false

	# Unlock achievement
	achievement.unlocked = true
	achievement.unlocked_at = Time.get_unix_time_from_system()

	# Emit signal
	EventBus.achievement_unlocked.emit(achievement_id, achievement)

	print("Achievement unlocked: %s - %s" % [achievement.name, achievement.description])
	return true

## Check if an achievement is unlocked
func is_achievement_unlocked(achievement_id: String) -> bool:
	if not player.achievements.has(achievement_id):
		return false
	return player.achievements[achievement_id].unlocked

## Get achievement progress summary
## Returns: {total: int, unlocked: int, percentage: float, achievements: Array}
func get_achievement_progress() -> Dictionary:
	var total = ACHIEVEMENTS.size()
	var unlocked = 0
	var achievements_list = []

	for achievement_id in player.achievements:
		var achievement = player.achievements[achievement_id]
		achievements_list.append(achievement)
		if achievement.unlocked:
			unlocked += 1

	var percentage = (float(unlocked) / float(total)) * 100.0 if total > 0 else 0.0

	return {
		"total": total,
		"unlocked": unlocked,
		"percentage": percentage,
		"achievements": achievements_list
	}

## Get all achievements (for UI display)
func get_all_achievements() -> Array:
	var achievements_list = []
	for achievement_id in player.achievements:
		achievements_list.append(player.achievements[achievement_id])
	return achievements_list

## Get only unlocked achievements
func get_unlocked_achievements() -> Array:
	var unlocked = []
	for achievement_id in player.achievements:
		var achievement = player.achievements[achievement_id]
		if achievement.unlocked:
			unlocked.append(achievement)
	return unlocked

## Record successful skill check (for achievement tracking)
func record_skill_check_success() -> void:
	_successful_skill_checks += 1
	_check_skill_check_achievements()

# ============================================================================
# ACHIEVEMENT AUTO-UNLOCK LOGIC
# ============================================================================

## Check and unlock level-based achievements
func _check_level_achievements() -> void:
	if player.level >= 3:
		unlock_achievement("level_3")
	if player.level >= 5:
		unlock_achievement("level_5")
	if player.level >= 10:
		unlock_achievement("level_10")

## Check and unlock credit-based achievements
func _check_credit_achievements() -> void:
	if player.credits >= 1000:
		unlock_achievement("credits_1000")
	if player.credits >= 5000:
		unlock_achievement("credits_5000")

## Check and unlock mission-based achievements
func _check_mission_achievements() -> void:
	var completed_count = get_completed_missions_count()

	if completed_count >= 1:
		unlock_achievement("first_mission")
	if completed_count >= 5:
		unlock_achievement("five_missions")
	if completed_count >= 10:
		unlock_achievement("ten_missions")

## Check and unlock system-based achievements
func _check_system_achievements() -> void:
	# Count installed systems (level > 0)
	var installed_count = 0
	var all_level_1 = true

	for system_name in ship.systems:
		var system = ship.systems[system_name]
		if system.level > 0:
			installed_count += 1
		if system.level < 1:
			all_level_1 = false

	# First upgrade achievement
	if installed_count >= 1:
		unlock_achievement("first_upgrade")

	# All 10 systems unlocked
	if installed_count >= 10:
		unlock_achievement("ten_systems")

	# All systems at Level 1
	if all_level_1 and installed_count == 10:
		unlock_achievement("all_systems_level_1")

## Check and unlock skill-based achievements
func _check_skill_achievements() -> void:
	# Check if any skill reached level 10
	for skill_name in player.skills:
		if player.skills[skill_name] >= 10:
			unlock_achievement("skill_master")
			break

## Check and unlock skill check achievements
func _check_skill_check_achievements() -> void:
	if _successful_skill_checks >= 10:
		unlock_achievement("ten_successful_checks")

## Check and unlock part discovery achievements
func _check_part_discovery_achievements() -> void:
	var discovered_count = progress.discovered_parts.size()

	if discovered_count >= 10:
		unlock_achievement("ten_parts")
	if discovered_count >= 20:
		unlock_achievement("twenty_parts")

## Signal handler for part discovery (connected to EventBus.part_discovered)
func _on_part_discovered(_part_id: String, _part_name: String) -> void:
	_check_part_discovery_achievements()

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

	# Check system achievements
	_check_system_achievements()

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

## Add item to inventory (supports stacking by part_id)
func add_item(item: Dictionary) -> void:
	var part_id = item.get("part_id", "")
	var quantity = item.get("quantity", 1)

	# Validate part_id if present
	if part_id != "" and has_node("/root/PartRegistry"):
		if not PartRegistry.validate_part_id(part_id):
			push_error("GameState.add_item: Invalid part_id: " + part_id)
			return

	# Check weight capacity before adding
	if not can_carry_item(part_id, quantity):
		EventBus.inventory_full.emit()
		push_warning("GameState.add_item: Inventory full, cannot add item")
		return

	# If item has a part_id, try to stack with existing item
	if part_id != "":
		for existing_item in inventory:
			if existing_item.get("part_id", "") == part_id:
				# Stack with existing item
				existing_item.quantity = existing_item.get("quantity", 1) + quantity
				EventBus.item_added.emit(item)
				print("Item stacked: %s x%d (Total: x%d)" % [
					part_id,
					quantity,
					existing_item.quantity
				])
				return

	# Not stackable or first instance - add new item
	if not item.has("quantity"):
		item.quantity = quantity
	inventory.append(item)
	EventBus.item_added.emit(item)
	print("Item added: %s x%d" % [part_id if part_id != "" else item.get("id", "unknown"), quantity])

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

## Get count of a specific part in inventory
func get_part_count(part_id: String) -> int:
	var total = 0
	for item in inventory:
		if item.get("part_id", "") == part_id:
			total += item.get("quantity", 1)
	return total

## Check if player has at least one of a specific part
func has_part(part_id: String) -> bool:
	return get_part_count(part_id) > 0

## Consume items for upgrades (removes parts from inventory)
## Returns true if successful, false if not enough parts
func consume_item(part_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		push_error("GameState.consume_item: Quantity must be positive")
		return false

	var available = get_part_count(part_id)
	if available < quantity:
		print("Not enough parts: Need %d, have %d" % [quantity, available])
		return false

	# Remove parts from inventory (LIFO - last in, first out)
	var remaining = quantity
	for i in range(inventory.size() - 1, -1, -1):  # Iterate backwards
		if remaining <= 0:
			break

		var item = inventory[i]
		if item.get("part_id", "") == part_id:
			var item_quantity = item.get("quantity", 1)

			if item_quantity <= remaining:
				# Remove entire stack
				remaining -= item_quantity
				inventory.remove_at(i)
				EventBus.item_removed.emit(item)
			else:
				# Reduce stack
				item.quantity -= remaining
				remaining = 0

	print("Parts consumed: %s x%d" % [part_id, quantity])
	return true

## Get total weight of inventory
func get_total_inventory_weight() -> float:
	var total_weight = 0.0

	if not has_node("/root/PartRegistry"):
		# Fallback: use weight field if present
		for item in inventory:
			var weight = item.get("weight", 1.0)
			var quantity = item.get("quantity", 1)
			total_weight += weight * quantity
		return total_weight

	# Use PartRegistry for accurate weights
	for item in inventory:
		var part_id = item.get("part_id", "")
		var quantity = item.get("quantity", 1)

		if part_id != "":
			var part = PartRegistry.get_part(part_id)
			if not part.is_empty():
				total_weight += part.get("weight", 1.0) * quantity
		else:
			# Non-part item, use weight field
			total_weight += item.get("weight", 1.0) * quantity

	return total_weight

## Get current inventory capacity in kg
func get_inventory_capacity() -> float:
	if not has_node("/root/PartRegistry"):
		# Fallback: basic capacity
		return 100.0 + (50.0 * ship.systems.hull.level)

	# Use PartRegistry formula
	return PartRegistry.calculate_inventory_capacity(ship.systems.hull.level)

## Check if player can carry additional items
func can_carry_item(part_id: String, quantity: int = 1) -> bool:
	var current_weight = get_total_inventory_weight()
	var capacity = get_inventory_capacity()

	# Calculate weight of item to add
	var item_weight = 1.0  # Default
	if part_id != "" and has_node("/root/PartRegistry"):
		var part = PartRegistry.get_part(part_id)
		if not part.is_empty():
			item_weight = part.get("weight", 1.0)

	var total_weight_after = current_weight + (item_weight * quantity)
	return total_weight_after <= capacity

# ============================================================================
# PROGRESS FUNCTIONS
# ============================================================================

## Mark mission as completed
func complete_mission(mission_id: String) -> void:
	if mission_id not in progress.completed_missions:
		progress.completed_missions.append(mission_id)

		# Check mission achievements
		_check_mission_achievements()

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

	# Load data with migration support (merge with defaults to handle new fields)
	var loaded_player = data.get("player", {})
	player = _migrate_player_data(loaded_player)

	var loaded_ship = data.get("ship", {})
	ship = _migrate_ship_data(loaded_ship)

	inventory = data.get("inventory", []).duplicate(true)

	var loaded_progress = data.get("progress", {})
	progress = _migrate_progress_data(loaded_progress)

	_playtime_offset = progress.playtime_seconds

	print("GameState loaded from save")

## Migrate player data to ensure all required fields exist
func _migrate_player_data(loaded: Dictionary) -> Dictionary:
	"""Merge loaded player data with default structure to handle version changes"""
	var default_player = {
		"name": "Player",
		"level": 1,
		"xp": 0,
		"xp_to_next_level": 200,
		"rank": "Cadet",
		"credits": 0,
		"skill_points": 0,
		"skills": {
			"engineering": 0,
			"diplomacy": 0,
			"combat": 0,
			"science": 0
		},
		"achievements": {}
	}

	# Merge: loaded values override defaults, but defaults fill in missing fields
	for key in default_player:
		if not loaded.has(key):
			loaded[key] = default_player[key]

	# Ensure skills dictionary has all skills
	if loaded.has("skills"):
		for skill in default_player.skills:
			if not loaded.skills.has(skill):
				loaded.skills[skill] = 0

	# Ensure achievements dictionary is present (will be populated by _initialize_achievements)
	if not loaded.has("achievements"):
		loaded.achievements = {}

	return loaded.duplicate(true)

## Migrate ship data to ensure all required fields exist
func _migrate_ship_data(loaded: Dictionary) -> Dictionary:
	"""Merge loaded ship data with default structure"""
	# Start with current ship structure (has all systems)
	var migrated = ship.duplicate(true)

	# Override with loaded values
	for key in loaded:
		migrated[key] = loaded[key]

	return migrated

## Migrate progress data to ensure all required fields exist
func _migrate_progress_data(loaded: Dictionary) -> Dictionary:
	"""Merge loaded progress data with default structure"""
	var default_progress = {
		"phase": 1,
		"completed_missions": [],
		"discovered_locations": [],
		"major_choices": [],
		"discovered_parts": [],  # Economy system addition
		"playtime_seconds": 0.0
	}

	# Merge: loaded values override defaults
	for key in default_progress:
		if not loaded.has(key):
			loaded[key] = default_progress[key]

	return loaded.duplicate(true)

## Reset to new game state
func reset_to_new_game() -> void:
	player = {
		"name": "Player",
		"level": 1,
		"xp": 0,
		"xp_to_next_level": 200,
		"rank": "Cadet",
		"credits": 0,
		"skill_points": 0,
		"skills": {
			"engineering": 0,
			"diplomacy": 0,
			"combat": 0,
			"science": 0
		},
		"achievements": {}
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
		"discovered_parts": [],
		"major_choices": [],
		"playtime_seconds": 0.0,
		"game_started": Time.get_unix_time_from_system()
	}

	_initialize_game()
	print("GameState reset to new game")

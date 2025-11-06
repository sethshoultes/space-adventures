extends Node
class_name ShipSystem

## Base class for all ship systems
## Provides common functionality for system management, upgrades, and state tracking

# System properties
var system_name: String = ""
var level: int = 0
var health: int = 100
var max_health: int = 100
var active: bool = false
var installed_part_id: String = ""

# System specifications by level (override in subclasses)
var max_levels: int = 5
var display_name: String = "System"
var description_by_level: Array[String] = []
var power_cost_by_level: Array[int] = [0, 0, 0, 0, 0, 0]  # Index 0 unused, 1-5 for levels

## Initialize the system
func _init(sys_name: String = "") -> void:
	system_name = sys_name
	if system_name != "":
		set_name("System_" + system_name)

## Set system level
func set_level(new_level: int) -> void:
	if new_level < 0 or new_level > max_levels:
		push_error("Invalid level %d for system %s" % [new_level, system_name])
		return

	level = new_level
	active = (level > 0)

	# Update health
	if level == 0:
		health = 0
		max_health = 0
	else:
		max_health = 100  # Default, override in subclasses
		health = max_health

## Upgrade system to next level
func upgrade() -> bool:
	if level >= max_levels:
		push_warning("System %s already at max level" % system_name)
		return false

	set_level(level + 1)
	EventBus.system_upgraded.emit(system_name, level)
	return true

## Take damage
func take_damage(amount: int) -> void:
	if level == 0:
		return  # Can't damage uninstalled system

	var old_health = health
	health = max(0, health - amount)

	EventBus.system_damaged.emit(system_name, amount, health)

	# Check if system went offline
	if old_health > 0 and health == 0:
		active = false
		EventBus.system_destroyed.emit(system_name)
		push_warning("System OFFLINE: %s" % system_name)

## Repair system
func repair(amount: int) -> void:
	if level == 0:
		return  # Can't repair uninstalled system

	var old_health = health
	health = min(max_health, health + amount)

	EventBus.system_repaired.emit(system_name, amount, health)

	# Reactivate if was offline
	if old_health == 0 and health > 0:
		active = true
		push_warning("System ONLINE: %s" % system_name)

## Get power cost for current level
func get_power_cost() -> int:
	if level < 0 or level >= power_cost_by_level.size():
		return 0
	return power_cost_by_level[level] if active else 0

## Get system info as dictionary (for save/load)
func to_dict() -> Dictionary:
	return {
		"name": system_name,
		"level": level,
		"health": health,
		"max_health": max_health,
		"active": active,
		"installed_part": installed_part_id
	}

## Load from dictionary
func from_dict(data: Dictionary) -> void:
	system_name = data.get("name", system_name)
	level = data.get("level", 0)
	health = data.get("health", 100)
	max_health = data.get("max_health", 100)
	active = data.get("active", false)
	installed_part_id = data.get("installed_part", "")

## Get description for current level
func get_description() -> String:
	if level < 0 or level >= description_by_level.size():
		return "No description available"
	return description_by_level[level]

## Can this system be upgraded? (override for resource checks)
func can_upgrade() -> bool:
	return level < max_levels

## Get status string
func get_status() -> String:
	if level == 0:
		return "NOT INSTALLED"
	elif not active:
		return "OFFLINE"
	elif health == max_health:
		return "OPERATIONAL"
	elif health > max_health * 0.5:
		return "DAMAGED"
	else:
		return "CRITICAL"

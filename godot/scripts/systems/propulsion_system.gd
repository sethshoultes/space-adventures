extends ShipSystem
class_name PropulsionSystem

## Propulsion System (Impulse Engines)
## Sub-light maneuvering and combat agility
##
## Level 0: No Propulsion (0 PU, 0x speed, 0% dodge)
## Level 1: Chemical Thrusters (10 PU, 1x speed, 5% dodge)
## Level 2: Ion Drive (15 PU, 2x speed, 10% dodge)
## Level 3: Plasma Engine (25 PU, 4x speed, 18% dodge, Evasive Maneuvers 1/encounter)
## Level 4: Gravitic Drive (40 PU, 7x speed, 28% dodge, Emergency Burn 2/encounter)
## Level 5: Inertial Dampener (60 PU, 12x speed, 40% dodge, perfect maneuverability + collision immunity)

# Propulsion-specific properties
var speed_multiplier: float = 0.0  # Speed multiplier (1x = base speed)
var dodge_bonus: float = 0.0  # Dodge % in combat
var evasive_maneuvers_available: int = 0  # Level 3: 1 per encounter
var emergency_burns_available: int = 0  # Level 4: 2 per encounter
var perfect_maneuverability: bool = false  # Level 5: perfect control
var collision_immunity: bool = false  # Level 5: immune to kinetic collision damage

# Spec tables from ship-systems.md
const SPEED_BY_LEVEL: Array[float] = [0.0, 1.0, 2.0, 4.0, 7.0, 12.0]
const DODGE_BY_LEVEL: Array[float] = [0.0, 0.05, 0.10, 0.18, 0.28, 0.40]
const POWER_COST_BY_LEVEL: Array[int] = [0, 10, 15, 25, 40, 60]

func _init() -> void:
	super._init("propulsion")

	display_name = "Propulsion (Impulse Engines)"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 10, 15, 25, 40, 60]

	# Descriptions from design doc
	description_by_level = [
		"No propulsion system installed.",
		"Old reliable. Slow but functional.",
		"Standard ion propulsion. Quiet and efficient.",
		"Fast and responsive. A pilot's dream.",
		"Manipulates local gravity fields. Impossibly agile.",
		"Experimental technology that negates inertia. You can stop on a dime."
	]

## Override set_level to update propulsion-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update speed multiplier from spec
	if new_level >= 0 and new_level < SPEED_BY_LEVEL.size():
		speed_multiplier = SPEED_BY_LEVEL[new_level]
	else:
		speed_multiplier = 0.0

	# Update dodge bonus from spec
	if new_level >= 0 and new_level < DODGE_BY_LEVEL.size():
		dodge_bonus = DODGE_BY_LEVEL[new_level]
	else:
		dodge_bonus = 0.0

	# Set special abilities
	if new_level >= 3:
		evasive_maneuvers_available = 1  # Level 3+
	else:
		evasive_maneuvers_available = 0

	if new_level >= 4:
		emergency_burns_available = 2  # Level 4+
	else:
		emergency_burns_available = 0

	if new_level == 5:
		perfect_maneuverability = true
		collision_immunity = true
	else:
		perfect_maneuverability = false
		collision_immunity = false

	# Update GameState propulsion values
	_update_game_state_propulsion()

	print("Propulsion System upgraded to Level %d: %.0fx speed, %.0f%% dodge" % [
		level,
		speed_multiplier,
		dodge_bonus * 100
	])

## Get current speed multiplier
func get_speed() -> float:
	if not active:
		return 0.0
	return speed_multiplier

## Get dodge bonus as percentage (0-100)
func get_dodge_percent() -> float:
	return dodge_bonus * 100.0

## Check if evasive maneuvers available
func can_use_evasive_maneuvers() -> bool:
	return evasive_maneuvers_available > 0

## Use evasive maneuver (Level 3+, once per encounter)
func use_evasive_maneuver() -> bool:
	if evasive_maneuvers_available > 0:
		evasive_maneuvers_available -= 1
		print("Evasive Maneuvers activated! Remaining: %d" % evasive_maneuvers_available)
		return true
	return false

## Reset evasive maneuvers (call at start of encounter)
func reset_evasive_maneuvers() -> void:
	if level >= 3:
		evasive_maneuvers_available = 1

## Check if emergency burns available
func can_use_emergency_burn() -> bool:
	return emergency_burns_available > 0

## Use emergency burn (Level 4+, 2 per encounter)
func use_emergency_burn() -> bool:
	if emergency_burns_available > 0:
		emergency_burns_available -= 1
		print("Emergency Burn activated! Remaining: %d" % emergency_burns_available)
		return true
	return false

## Reset emergency burns (call at start of encounter)
func reset_emergency_burns() -> void:
	if level >= 4:
		emergency_burns_available = 2

## Check if has perfect maneuverability (Level 5)
func has_perfect_maneuverability() -> bool:
	return perfect_maneuverability

## Check if immune to collision damage (Level 5)
func is_collision_immune() -> bool:
	return collision_immunity

## Update GameState with current propulsion values
func _update_game_state_propulsion() -> void:
	# Update system data in GameState
	GameState.ship.systems.propulsion.level = level
	GameState.ship.systems.propulsion.health = health
	GameState.ship.systems.propulsion.max_health = max_health
	GameState.ship.systems.propulsion.active = active

	# Recalculate ship power stats (propulsion consumes power)
	GameState._recalculate_ship_stats()

## Override to_dict to include propulsion-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["speed_multiplier"] = speed_multiplier
	data["dodge_bonus"] = dodge_bonus
	data["evasive_maneuvers_available"] = evasive_maneuvers_available
	data["emergency_burns_available"] = emergency_burns_available
	data["perfect_maneuverability"] = perfect_maneuverability
	data["collision_immunity"] = collision_immunity
	return data

## Override from_dict to load propulsion-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	speed_multiplier = data.get("speed_multiplier", 0.0)
	dodge_bonus = data.get("dodge_bonus", 0.0)
	evasive_maneuvers_available = data.get("evasive_maneuvers_available", 0)
	emergency_burns_available = data.get("emergency_burns_available", 0)
	perfect_maneuverability = data.get("perfect_maneuverability", false)
	collision_immunity = data.get("collision_immunity", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Propulsion not installed"

	var stats = "Speed: %.0fx\n" % speed_multiplier
	stats += "Dodge Bonus: %.0f%%\n" % (dodge_bonus * 100)
	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 3:
		stats += "\nSpecial Abilities:\n"
		if evasive_maneuvers_available > 0:
			stats += "  • Evasive Maneuvers: %d available\n" % evasive_maneuvers_available
		else:
			stats += "  • Evasive Maneuvers: Used (resets per encounter)\n"

	if level >= 4:
		if emergency_burns_available > 0:
			stats += "  • Emergency Burn: %d available\n" % emergency_burns_available
		else:
			stats += "  • Emergency Burn: Used (resets per encounter)\n"

	if level == 5:
		stats += "  • Perfect Maneuverability\n"
		stats += "  • Collision Immunity\n"

	stats += "\nStatus: %s" % get_status()

	return stats

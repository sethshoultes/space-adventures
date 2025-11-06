extends ShipSystem
class_name PowerSystem

## Power Core System
## Generates power for all ship systems
##
## Level 0: No Power (0 PU)
## Level 1: Fusion Cell (100 PU, 80% efficiency)
## Level 2: Deuterium Reactor (200 PU, 85% efficiency, -10% power cost reduction)
## Level 3: M/AM Core (400 PU, 90% efficiency, -15% power cost reduction)
## Level 4: Advanced M/AM Reactor (700 PU, 93% efficiency, -20% power cost reduction, 100 PU emergency reserve)
## Level 5: Zero-Point Energy Tap (1000 PU, 98% efficiency, -25% power cost reduction, +5 PU/turn regen)

# Power-specific properties
var power_output: int = 0  # Total power generated (PU)
var efficiency: float = 0.0  # Efficiency % (0.0 - 1.0)
var power_cost_reduction: float = 0.0  # Reduces cost of all other systems
var emergency_reserve: int = 0  # One-time emergency power boost (Level 4)
var power_regen_per_turn: int = 0  # Power regeneration per turn (Level 5)

# Spec tables from ship-systems.md
const POWER_BY_LEVEL: Array[int] = [0, 100, 200, 400, 700, 1000]
const EFFICIENCY_BY_LEVEL: Array[float] = [0.0, 0.80, 0.85, 0.90, 0.93, 0.98]
const COST_REDUCTION_BY_LEVEL: Array[float] = [0.0, 0.0, 0.10, 0.15, 0.20, 0.25]

func _init() -> void:
	super._init("power")

	display_name = "Power Core"
	max_levels = 5

	# Power Core doesn't consume power, it generates it
	power_cost_by_level = [0, 0, 0, 0, 0, 0]

	# Descriptions from design doc
	description_by_level = [
		"Ship is dead in space.",
		"Basic fusion cell. Enough to get started.",
		"Standard deuterium reactor. Reliable and efficient.",
		"The workhorse of modern starships. Volatile but powerful.",
		"Military-grade reactor. Over-engineered for extreme reliability.",
		"Experimental quantum technology. Draws power from the fabric of space itself."
	]

## Override set_level to update power-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update power output from spec
	if new_level >= 0 and new_level < POWER_BY_LEVEL.size():
		power_output = POWER_BY_LEVEL[new_level]
	else:
		power_output = 0

	# Update efficiency from spec
	if new_level >= 0 and new_level < EFFICIENCY_BY_LEVEL.size():
		efficiency = EFFICIENCY_BY_LEVEL[new_level]
	else:
		efficiency = 0.0

	# Update power cost reduction from spec
	if new_level >= 0 and new_level < COST_REDUCTION_BY_LEVEL.size():
		power_cost_reduction = COST_REDUCTION_BY_LEVEL[new_level]
	else:
		power_cost_reduction = 0.0

	# Set emergency reserve for Level 4
	if new_level == 4:
		emergency_reserve = 100  # One-time 100 PU boost
	else:
		emergency_reserve = 0

	# Set power regeneration for Level 5
	if new_level == 5:
		power_regen_per_turn = 5  # 5 PU per turn
	else:
		power_regen_per_turn = 0

	# Update GameState power values
	_update_game_state_power()

	print("Power Core upgraded to Level %d: %d PU, %.0f%% efficiency, %.0f%% cost reduction" % [
		level,
		power_output,
		efficiency * 100,
		power_cost_reduction * 100
	])

## Get power output for current level
func get_power_output() -> int:
	if not active:
		return 0
	return power_output

## Get efficiency as percentage (0-100)
func get_efficiency_percent() -> float:
	return efficiency * 100.0

## Get power cost reduction as percentage (0-100)
func get_cost_reduction_percent() -> float:
	return power_cost_reduction * 100.0

## Use emergency reserve (Level 4 only, one-time use)
func use_emergency_reserve() -> int:
	if level != 4 or emergency_reserve == 0:
		return 0

	var reserve = emergency_reserve
	emergency_reserve = 0
	print("Emergency power reserve activated: +%d PU" % reserve)
	return reserve

## Regenerate power (Level 5 only, called each turn)
func regenerate_power() -> int:
	if level != 5 or power_regen_per_turn == 0:
		return 0

	# This would be used in encounters to regenerate power
	return power_regen_per_turn

## Update GameState with current power values
func _update_game_state_power() -> void:
	# Update system data in GameState
	GameState.ship.systems.power.level = level
	GameState.ship.systems.power.health = health
	GameState.ship.systems.power.max_health = max_health
	GameState.ship.systems.power.active = active

	# Recalculate ship power stats (this will update power_total and power_available)
	GameState._recalculate_ship_stats()

## Override to_dict to include power-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["power_output"] = power_output
	data["efficiency"] = efficiency
	data["power_cost_reduction"] = power_cost_reduction
	data["emergency_reserve"] = emergency_reserve
	data["power_regen_per_turn"] = power_regen_per_turn
	return data

## Override from_dict to load power-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	power_output = data.get("power_output", 0)
	efficiency = data.get("efficiency", 0.0)
	power_cost_reduction = data.get("power_cost_reduction", 0.0)
	emergency_reserve = data.get("emergency_reserve", 0)
	power_regen_per_turn = data.get("power_regen_per_turn", 0)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Power Core not installed"

	var stats = "Power Output: %d PU\n" % power_output
	stats += "Efficiency: %.0f%%\n" % (efficiency * 100)

	if power_cost_reduction > 0:
		stats += "Power Cost Reduction: %.0f%% (all systems)\n" % (power_cost_reduction * 100)

	if level == 4:
		stats += "Emergency Reserve: %d PU (one-time boost)\n" % emergency_reserve

	if level == 5:
		stats += "Power Regeneration: %d PU per turn\n" % power_regen_per_turn

	stats += "Status: %s" % get_status()

	return stats

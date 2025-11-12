extends ShipSystem
class_name LifeSupportSystem

## Life Support System
## Keep crew alive and operational
##
## Level 0: No Life Support (0 PU, 0 crew)
## Level 1: Basic Oxygen Recycling (5 PU, 1 crew, 24h emergency, 10% radiation protection)
## Level 2: Climate Control (10 PU, 4 crew, 1 week emergency, 30% radiation, +10% morale, unlocks crew system)
## Level 3: Advanced Bio-Recycling (15 PU, 10 crew, 1 month emergency, 50% radiation, +20% morale, crew can perform tasks)
## Level 4: Closed-Loop Ecosystem (25 PU, 25 crew, 6 months emergency, 75% radiation, +30% morale, produce food, +20% crew efficiency)
## Level 5: Bio-Dome (35 PU, 50 crew, indefinite emergency, 95% radiation, +50% morale, zero supply costs, +40% crew efficiency)

# Life support-specific properties
var crew_capacity: int = 0  # Maximum crew members
var emergency_duration_hours: float = 0.0  # Hours of life support without power
var radiation_protection: float = 0.0  # Percentage of radiation protection (0.0 to 1.0)
var morale_bonus: float = 0.0  # Percentage bonus to crew morale
var unlocks_crew_system: bool = false  # Level 2+: Enables crew recruitment
var crew_can_perform_tasks: bool = false  # Level 3+: Crew can work on ship tasks
var produces_food: bool = false  # Level 4+: Reduces supply costs
var crew_efficiency_bonus: float = 0.0  # Percentage bonus to crew task efficiency
var zero_supply_costs: bool = false  # Level 5: Completely self-sufficient

# Spec tables from ship-systems.md
const CREW_CAPACITY_BY_LEVEL: Array[int] = [0, 1, 4, 10, 25, 50]
const EMERGENCY_DURATION_BY_LEVEL: Array[float] = [0.0, 24.0, 168.0, 720.0, 4320.0, 999999.0]  # Hours (last is indefinite)
const RADIATION_PROTECTION_BY_LEVEL: Array[float] = [0.0, 0.10, 0.30, 0.50, 0.75, 0.95]
const MORALE_BONUS_BY_LEVEL: Array[float] = [0.0, 0.0, 0.10, 0.20, 0.30, 0.50]
const CREW_EFFICIENCY_BY_LEVEL: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.20, 0.40]
const POWER_COST_BY_LEVEL: Array[int] = [0, 5, 10, 15, 25, 35]

func _init() -> void:
	super._init("life_support")

	display_name = "Life Support"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 5, 10, 15, 25, 35]

	# Descriptions from design doc
	description_by_level = [
		"No life support system installed. Cannot support crew.",
		"Keeps you breathing. That's about it.",
		"Comfortable environment for a small crew.",
		"Closed-loop life support. Months of self-sufficiency.",
		"Self-sustaining ecosystem. You could live aboard indefinitely.",
		"A garden in space. The crew considers this home."
	]

## Override set_level to update life support-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update crew capacity from spec
	if new_level >= 0 and new_level < CREW_CAPACITY_BY_LEVEL.size():
		crew_capacity = CREW_CAPACITY_BY_LEVEL[new_level]
	else:
		crew_capacity = 0

	# Update emergency duration from spec
	if new_level >= 0 and new_level < EMERGENCY_DURATION_BY_LEVEL.size():
		emergency_duration_hours = EMERGENCY_DURATION_BY_LEVEL[new_level]
	else:
		emergency_duration_hours = 0.0

	# Update radiation protection from spec
	if new_level >= 0 and new_level < RADIATION_PROTECTION_BY_LEVEL.size():
		radiation_protection = RADIATION_PROTECTION_BY_LEVEL[new_level]
	else:
		radiation_protection = 0.0

	# Update morale bonus from spec
	if new_level >= 0 and new_level < MORALE_BONUS_BY_LEVEL.size():
		morale_bonus = MORALE_BONUS_BY_LEVEL[new_level]
	else:
		morale_bonus = 0.0

	# Update crew efficiency from spec
	if new_level >= 0 and new_level < CREW_EFFICIENCY_BY_LEVEL.size():
		crew_efficiency_bonus = CREW_EFFICIENCY_BY_LEVEL[new_level]
	else:
		crew_efficiency_bonus = 0.0

	# Set special abilities
	if new_level >= 2:
		unlocks_crew_system = true  # Level 2+: Can recruit crew
	else:
		unlocks_crew_system = false

	if new_level >= 3:
		crew_can_perform_tasks = true  # Level 3+: Crew can work on ship tasks
	else:
		crew_can_perform_tasks = false

	if new_level >= 4:
		produces_food = true  # Level 4+: Reduces supply costs via hydroponics
	else:
		produces_food = false

	if new_level == 5:
		zero_supply_costs = true  # Level 5: Completely self-sufficient
	else:
		zero_supply_costs = false

	# Update GameState life support values
	_update_game_state_life_support()

	if new_level > 0:
		print("Life Support upgraded to Level %d: %d crew capacity, %.0f%% radiation protection" % [
			level,
			crew_capacity,
			radiation_protection * 100
		])

## Get current crew capacity
func get_crew_capacity() -> int:
	if not active:
		return 0
	return crew_capacity

## Get emergency duration in hours
func get_emergency_duration() -> float:
	if not active:
		return 0.0
	return emergency_duration_hours

## Get emergency duration as human-readable string
func get_emergency_duration_string() -> String:
	if emergency_duration_hours >= 999999:
		return "Indefinite"
	elif emergency_duration_hours >= 720:  # 30 days
		return "%d months" % (emergency_duration_hours / 720)
	elif emergency_duration_hours >= 168:  # 7 days
		return "%d weeks" % (emergency_duration_hours / 168)
	elif emergency_duration_hours >= 24:
		return "%d days" % (emergency_duration_hours / 24)
	else:
		return "%d hours" % emergency_duration_hours

## Get radiation protection as percentage (0-100)
func get_radiation_protection_percent() -> float:
	return radiation_protection * 100.0

## Calculate radiation damage after protection
func apply_radiation_protection(base_damage: float) -> float:
	if not active:
		return base_damage
	return base_damage * (1.0 - radiation_protection)

## Get morale bonus as percentage (0-100)
func get_morale_bonus_percent() -> float:
	return morale_bonus * 100.0

## Check if crew system is unlocked (Level 2+)
func is_crew_system_unlocked() -> bool:
	return unlocks_crew_system

## Check if crew can perform tasks (Level 3+)
func can_crew_perform_tasks() -> bool:
	return crew_can_perform_tasks

## Get crew efficiency bonus as percentage (0-100)
func get_crew_efficiency_percent() -> float:
	return crew_efficiency_bonus * 100.0

## Check if produces food (Level 4+)
func does_produce_food() -> bool:
	return produces_food

## Check if has zero supply costs (Level 5)
func has_zero_supply_costs() -> bool:
	return zero_supply_costs

## Update GameState with current life support values
func _update_game_state_life_support() -> void:
	# Update system data in GameState
	GameState.ship.systems.life_support.level = level
	GameState.ship.systems.life_support.health = health
	GameState.ship.systems.life_support.max_health = max_health
	GameState.ship.systems.life_support.active = active

	# Recalculate ship power stats (life support consumes power)
	GameState._recalculate_ship_stats()

## Override to_dict to include life support-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["crew_capacity"] = crew_capacity
	data["emergency_duration_hours"] = emergency_duration_hours
	data["radiation_protection"] = radiation_protection
	data["morale_bonus"] = morale_bonus
	data["unlocks_crew_system"] = unlocks_crew_system
	data["crew_can_perform_tasks"] = crew_can_perform_tasks
	data["produces_food"] = produces_food
	data["crew_efficiency_bonus"] = crew_efficiency_bonus
	data["zero_supply_costs"] = zero_supply_costs
	return data

## Override from_dict to load life support-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	crew_capacity = data.get("crew_capacity", 0)
	emergency_duration_hours = data.get("emergency_duration_hours", 0.0)
	radiation_protection = data.get("radiation_protection", 0.0)
	morale_bonus = data.get("morale_bonus", 0.0)
	unlocks_crew_system = data.get("unlocks_crew_system", false)
	crew_can_perform_tasks = data.get("crew_can_perform_tasks", false)
	produces_food = data.get("produces_food", false)
	crew_efficiency_bonus = data.get("crew_efficiency_bonus", 0.0)
	zero_supply_costs = data.get("zero_supply_costs", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Life Support not installed\nCannot support crew"

	var stats = "Crew Capacity: %d\n" % crew_capacity
	stats += "Emergency Duration: %s\n" % get_emergency_duration_string()
	stats += "Radiation Protection: %.0f%%\n" % (radiation_protection * 100)

	if morale_bonus > 0.0:
		stats += "Morale Bonus: +%.0f%%\n" % (morale_bonus * 100)

	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 2:
		stats += "\nSpecial Abilities:\n"
		if unlocks_crew_system:
			stats += "  • Crew system unlocked\n"
		if crew_can_perform_tasks:
			stats += "  • Crew can perform ship tasks\n"
		if crew_efficiency_bonus > 0.0:
			stats += "  • Crew efficiency: +%.0f%%\n" % (crew_efficiency_bonus * 100)
		if produces_food:
			stats += "  • Produces food (reduced supply costs)\n"
		if zero_supply_costs:
			stats += "  • Zero supply costs (self-sufficient)\n"

	stats += "\nStatus: %s" % get_status()

	return stats

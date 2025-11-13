extends ShipSystem
class_name WeaponsSystem

## Weapons System
## Combat offense, self-defense
##
## Level 0: No Weapons (0 PU, 0 damage, cannot engage in combat)
## Level 1: Laser Cannon (10 PU, 15-25 dmg, 70% accuracy, precise crits)
## Level 2: Phaser Array (20 PU, 30-50 dmg, 80% accuracy, variable power, target systems)
## Level 3: Photon Torpedoes + Phasers (35 PU, 40-60 phaser / 80-120 torpedo, 85% accuracy)
## Level 4: Quantum Torpedoes + Pulse Phasers (55 PU, 60-90 pulse / 150-200 quantum, 90% accuracy, alpha strike)
## Level 5: Experimental Weapons (80 PU, variable damage, 95% accuracy, transphasic/graviton/tachyon/disruptor)

# Weapons-specific properties
var damage_min: int = 0  # Minimum damage
var damage_max: int = 0  # Maximum damage
var accuracy: float = 0.0  # Hit chance percentage (0.0 to 1.0)
var fire_rate: int = 1  # Attacks per turn
var has_torpedoes: bool = false  # Level 3+: Torpedo option
var torpedo_damage_min: int = 0  # Torpedo minimum damage
var torpedo_damage_max: int = 0  # Torpedo maximum damage
var torpedo_ammo: int = 0  # Torpedoes per encounter
var can_target_subsystems: bool = false  # Level 2+: Target specific systems
var has_variable_power: bool = false  # Level 2+: Can attack at 50% power for half cost
var has_alpha_strike: bool = false  # Level 4+: Fire everything at once
var has_experimental_weapons: bool = false  # Level 5: Special weapon abilities

# Spec tables from ship-systems.md
const DAMAGE_MIN_BY_LEVEL: Array[int] = [0, 15, 30, 40, 60, 100]  # Base weapon damage
const DAMAGE_MAX_BY_LEVEL: Array[int] = [0, 25, 50, 60, 90, 150]
const ACCURACY_BY_LEVEL: Array[float] = [0.0, 0.70, 0.80, 0.85, 0.90, 0.95]
const FIRE_RATE_BY_LEVEL: Array[int] = [0, 1, 1, 1, 2, 1]  # Level 4 has rapid fire (2x/turn)
const TORPEDO_MIN_BY_LEVEL: Array[int] = [0, 0, 0, 80, 150, 120]
const TORPEDO_MAX_BY_LEVEL: Array[int] = [0, 0, 0, 120, 200, 180]
const TORPEDO_AMMO_BY_LEVEL: Array[int] = [0, 0, 0, 10, 8, 5]
const POWER_COST_BY_LEVEL: Array[int] = [0, 10, 20, 35, 55, 80]

func _init() -> void:
	super._init("weapons")

	display_name = "Weapons"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 10, 20, 35, 55, 80]

	# Descriptions from design doc
	description_by_level = [
		"No weapons installed. Cannot engage in combat (auto-flee only).",
		"Salvaged mining laser. It'll hurt... eventually.",
		"Standard energy weapon. Reliable and accurate.",
		"Serious firepower. You can hold your own in a fight.",
		"Military arsenal. You're a threat to be respected.",
		"Cutting-edge experimental weapons. Devastating and versatile."
	]

## Override set_level to update weapons-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update damage from spec
	if new_level >= 0 and new_level < DAMAGE_MIN_BY_LEVEL.size():
		damage_min = DAMAGE_MIN_BY_LEVEL[new_level]
		damage_max = DAMAGE_MAX_BY_LEVEL[new_level]
	else:
		damage_min = 0
		damage_max = 0

	# Update accuracy from spec
	if new_level >= 0 and new_level < ACCURACY_BY_LEVEL.size():
		accuracy = ACCURACY_BY_LEVEL[new_level]
	else:
		accuracy = 0.0

	# Update fire rate from spec
	if new_level >= 0 and new_level < FIRE_RATE_BY_LEVEL.size():
		fire_rate = FIRE_RATE_BY_LEVEL[new_level]
	else:
		fire_rate = 0

	# Update torpedo stats from spec
	if new_level >= 3:
		has_torpedoes = true
		torpedo_damage_min = TORPEDO_MIN_BY_LEVEL[new_level]
		torpedo_damage_max = TORPEDO_MAX_BY_LEVEL[new_level]
		torpedo_ammo = TORPEDO_AMMO_BY_LEVEL[new_level]
	else:
		has_torpedoes = false
		torpedo_damage_min = 0
		torpedo_damage_max = 0
		torpedo_ammo = 0

	# Set special abilities
	if new_level >= 2:
		can_target_subsystems = true  # Level 2+: Precise targeting
		has_variable_power = true  # Level 2+: Can attack at 50% power for half cost
	else:
		can_target_subsystems = false
		has_variable_power = false

	if new_level >= 4:
		has_alpha_strike = true  # Level 4+: Fire everything at once (300-400 damage, 2/encounter)
	else:
		has_alpha_strike = false

	if new_level == 5:
		has_experimental_weapons = true  # Level 5: Special weapon abilities
	else:
		has_experimental_weapons = false

	# Update GameState weapons values
	_update_game_state_weapons()

	if new_level > 0:
		print("Weapons upgraded to Level %d: %d-%d damage, %.0f%% accuracy" % [
			level,
			damage_min,
			damage_max,
			accuracy * 100
		])

## Calculate damage for a single attack
func calculate_damage() -> int:
	if not active or damage_max == 0:
		return 0
	return randi_range(damage_min, damage_max)

## Calculate torpedo damage
func calculate_torpedo_damage() -> int:
	if not active or not has_torpedoes or torpedo_ammo <= 0:
		return 0
	return randi_range(torpedo_damage_min, torpedo_damage_max)

## Get hit chance as percentage (0-100)
func get_accuracy_percent() -> float:
	return accuracy * 100.0

## Check if attack hits (roll against accuracy)
func check_hit() -> bool:
	if not active:
		return false
	return randf() <= accuracy

## Get attacks per turn
func get_fire_rate() -> int:
	if not active:
		return 0
	return fire_rate

## Check if has torpedoes (Level 3+)
func has_torpedo_option() -> bool:
	return has_torpedoes and torpedo_ammo > 0

## Get torpedo ammo count
func get_torpedo_ammo() -> int:
	return torpedo_ammo

## Use a torpedo (consumes ammo)
func fire_torpedo() -> int:
	if not has_torpedoes or torpedo_ammo <= 0:
		return 0
	torpedo_ammo -= 1
	return calculate_torpedo_damage()

## Reload torpedoes (after encounter)
func reload_torpedoes() -> void:
	if level >= 3 and level < TORPEDO_AMMO_BY_LEVEL.size():
		torpedo_ammo = TORPEDO_AMMO_BY_LEVEL[level]

## Check if can target subsystems (Level 2+)
func can_target_specific_systems() -> bool:
	return can_target_subsystems

## Check if has variable power option (Level 2+)
func has_variable_power_mode() -> bool:
	return has_variable_power

## Check if has alpha strike ability (Level 4+)
func can_alpha_strike() -> bool:
	return has_alpha_strike

## Check if has experimental weapons (Level 5)
func has_experimental_weapon_options() -> bool:
	return has_experimental_weapons

## Update GameState with current weapons values
func _update_game_state_weapons() -> void:
	# Update system data in GameState
	GameState.ship.systems.weapons.level = level
	GameState.ship.systems.weapons.health = health
	GameState.ship.systems.weapons.max_health = max_health
	GameState.ship.systems.weapons.active = active

	# Recalculate ship power stats (weapons consume power)
	GameState._recalculate_ship_stats()

## Override to_dict to include weapons-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["damage_min"] = damage_min
	data["damage_max"] = damage_max
	data["accuracy"] = accuracy
	data["fire_rate"] = fire_rate
	data["has_torpedoes"] = has_torpedoes
	data["torpedo_damage_min"] = torpedo_damage_min
	data["torpedo_damage_max"] = torpedo_damage_max
	data["torpedo_ammo"] = torpedo_ammo
	data["can_target_subsystems"] = can_target_subsystems
	data["has_variable_power"] = has_variable_power
	data["has_alpha_strike"] = has_alpha_strike
	data["has_experimental_weapons"] = has_experimental_weapons
	return data

## Override from_dict to load weapons-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	damage_min = data.get("damage_min", 0)
	damage_max = data.get("damage_max", 0)
	accuracy = data.get("accuracy", 0.0)
	fire_rate = data.get("fire_rate", 1)
	has_torpedoes = data.get("has_torpedoes", false)
	torpedo_damage_min = data.get("torpedo_damage_min", 0)
	torpedo_damage_max = data.get("torpedo_damage_max", 0)
	torpedo_ammo = data.get("torpedo_ammo", 0)
	can_target_subsystems = data.get("can_target_subsystems", false)
	has_variable_power = data.get("has_variable_power", false)
	has_alpha_strike = data.get("has_alpha_strike", false)
	has_experimental_weapons = data.get("has_experimental_weapons", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Weapons not installed\nCannot engage in combat (auto-flee only)"

	var stats = "Damage: %d-%d\n" % [damage_min, damage_max]
	stats += "Accuracy: %.0f%%\n" % (accuracy * 100)
	stats += "Fire Rate: %dx per turn\n" % fire_rate

	if has_torpedoes:
		stats += "\nTorpedoes:\n"
		stats += "  Damage: %d-%d\n" % [torpedo_damage_min, torpedo_damage_max]
		stats += "  Ammo: %d/encounter\n" % torpedo_ammo

	stats += "\nPower Cost: %d PU\n" % get_power_cost()

	if level >= 2:
		stats += "\nSpecial Abilities:\n"
		if can_target_subsystems:
			stats += "  • Target specific systems\n"
		if has_variable_power:
			stats += "  • Variable power mode (50% dmg, half cost)\n"
		if has_alpha_strike:
			stats += "  • Alpha Strike (300-400 dmg, 2/encounter)\n"
		if has_experimental_weapons:
			stats += "  • Transphasic Torpedoes (ignore shields)\n"
			stats += "  • Graviton Beam (pull/push enemies)\n"
			stats += "  • Tachyon Burst (hit all enemies)\n"
			stats += "  • Disruptor Cannon (disable systems)\n"

	stats += "\nStatus: %s" % get_status()

	return stats

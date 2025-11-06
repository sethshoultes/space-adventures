extends ShipSystem
class_name HullSystem

## Hull & Structure System
## Physical integrity and damage resistance
##
## Level 0: No Hull (0 HP, 0 Armor)
## Level 1: Salvaged Hull (50 HP, 5% kinetic reduction)
## Level 2: Reinforced Structure (100 HP, 15% kinetic reduction)
## Level 3: Composite Armor (200 HP, 25% kinetic + 10% energy reduction, +10% radiation resist)
## Level 4: Ablative Plating (350 HP, 35% kinetic + 20% energy reduction, absorbs 50% first energy hit)
## Level 5: Regenerative Hull (500 HP, 45% kinetic + 30% energy reduction, 1% regen/turn, costs 10 PU)

# Hull-specific properties
var armor_kinetic: float = 0.0  # Kinetic damage reduction %
var armor_energy: float = 0.0   # Energy damage reduction %
var radiation_resist: float = 0.0  # Radiation damage reduction %
var regeneration_rate: float = 0.0  # HP regenerated per turn

# Spec tables from ship-systems.md
const HP_BY_LEVEL: Array[int] = [0, 50, 100, 200, 350, 500]
const KINETIC_ARMOR_BY_LEVEL: Array[float] = [0.0, 0.05, 0.15, 0.25, 0.35, 0.45]
const ENERGY_ARMOR_BY_LEVEL: Array[float] = [0.0, 0.0, 0.0, 0.10, 0.20, 0.30]
const RADIATION_RESIST_BY_LEVEL: Array[float] = [0.0, 0.0, 0.0, 0.10, 0.10, 0.10]

func _init() -> void:
	super._init("hull")

	display_name = "Hull & Structure"
	max_levels = 5

	# Power costs by level (Hull only costs power at Level 5 for regeneration)
	power_cost_by_level = [0, 0, 0, 0, 0, 10]

	# Descriptions from design doc
	description_by_level = [
		"Ship frame only, not spaceworthy.",
		"Patchwork hull cobbled from salvaged materials. It'll hold... probably.",
		"Proper hull plating with reinforced stress points. Now you're spaceworthy.",
		"Military-grade composite armor. Can withstand serious punishment.",
		"Advanced ablative armor disperses energy weapon impacts.",
		"Experimental self-repairing hull using nano-technology. Illegal in most sectors."
	]

## Override set_level to update hull-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update hull HP
	if new_level >= 0 and new_level < HP_BY_LEVEL.size():
		max_health = HP_BY_LEVEL[new_level]
		health = max_health
	else:
		max_health = 0
		health = 0

	# Update armor values
	if new_level >= 0 and new_level < KINETIC_ARMOR_BY_LEVEL.size():
		armor_kinetic = KINETIC_ARMOR_BY_LEVEL[new_level]
		armor_energy = ENERGY_ARMOR_BY_LEVEL[new_level]
		radiation_resist = RADIATION_RESIST_BY_LEVEL[new_level]

	# Set regeneration for Level 5
	if new_level == 5:
		regeneration_rate = 0.01  # 1% per turn = 5 HP/turn at 500 max HP
	else:
		regeneration_rate = 0.0

	# Update GameState ship hull HP
	_update_game_state_hull()

	print("Hull System upgraded to Level %d: %d HP, %.1f%% kinetic armor" % [
		level,
		max_health,
		armor_kinetic * 100
	])

## Get max HP for current level
func get_max_hp() -> int:
	return max_health

## Get current HP
func get_current_hp() -> int:
	return health

## Get armor reduction for damage type
func get_damage_reduction(damage_type: String) -> float:
	match damage_type:
		"kinetic":
			return armor_kinetic
		"energy":
			return armor_energy
		"radiation":
			return radiation_resist
		_:
			return 0.0

## Take hull damage (applies armor)
func take_hull_damage(amount: int, damage_type: String = "kinetic") -> int:
	if level == 0:
		return amount  # No hull, full damage

	var reduction = get_damage_reduction(damage_type)
	var reduced_damage = int(amount * (1.0 - reduction))

	take_damage(reduced_damage)

	return reduced_damage

## Regenerate hull (Level 5 only, called each turn)
func regenerate() -> int:
	if level != 5 or regeneration_rate == 0.0:
		return 0

	if health < max_health:
		var regen_amount = int(max_health * regeneration_rate)
		regen_amount = max(1, regen_amount)  # At least 1 HP per turn
		repair(regen_amount)
		return regen_amount

	return 0

## Update GameState with current hull values
func _update_game_state_hull() -> void:
	GameState.ship.max_hull_hp = max_health

	# Initialize hull HP if this is first installation
	if GameState.ship.hull_hp == 0 and max_health > 0:
		GameState.ship.hull_hp = max_health
	# Cap existing HP to new max if downgraded
	elif GameState.ship.hull_hp > max_health:
		GameState.ship.hull_hp = max_health

	# Update system data in GameState
	GameState.ship.systems.hull.level = level
	GameState.ship.systems.hull.health = health
	GameState.ship.systems.hull.max_health = max_health
	GameState.ship.systems.hull.active = active

## Override to_dict to include hull-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["armor_kinetic"] = armor_kinetic
	data["armor_energy"] = armor_energy
	data["radiation_resist"] = radiation_resist
	data["regeneration_rate"] = regeneration_rate
	return data

## Override from_dict to load hull-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	armor_kinetic = data.get("armor_kinetic", 0.0)
	armor_energy = data.get("armor_energy", 0.0)
	radiation_resist = data.get("radiation_resist", 0.0)
	regeneration_rate = data.get("regeneration_rate", 0.0)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Hull not installed"

	var stats = "HP: %d/%d\n" % [health, max_health]
	if armor_kinetic > 0:
		stats += "Kinetic Armor: %.0f%%\n" % (armor_kinetic * 100)
	if armor_energy > 0:
		stats += "Energy Armor: %.0f%%\n" % (armor_energy * 100)
	if radiation_resist > 0:
		stats += "Radiation Resist: %.0f%%\n" % (radiation_resist * 100)
	if regeneration_rate > 0:
		stats += "Regeneration: %.0f%% per turn (%d HP)\n" % [
			regeneration_rate * 100,
			int(max_health * regeneration_rate)
		]
	if level == 5:
		stats += "Power Cost: 10 PU (regeneration)"

	return stats

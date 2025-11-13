extends ShipSystem
class_name ShieldsSystem

## Shields System
## Energy defense, damage mitigation
##
## Level 0: No Shields (0 PU, hull takes all damage)
## Level 1: Deflector Screens (15 PU, 50 HP, 25% reduction, 5 HP/turn recharge)
## Level 2: Standard Shields (25 PU, 150 HP, 50% reduction, 15 HP/turn, block one shot completely)
## Level 3: Multi-Layered Shields (40 PU, 300 HP, 70% reduction, 30 HP/turn, rapid recharge)
## Level 4: Adaptive Shields (60 PU, 500 HP, 85% reduction, 50 HP/turn, adapt to damage type)
## Level 5: Phase Shields (85 PU, 800 HP, 95% reduction, 80 HP/turn, 30% phase out, extend to friendly ships)

# Shields-specific properties
var shield_hp: int = 0  # Current shield hit points
var max_shield_hp: int = 0  # Maximum shield hit points
var damage_reduction: float = 0.0  # Percentage of damage absorbed (0.0 to 1.0)
var recharge_rate: int = 0  # HP recharged per turn when not hit
var turns_since_hit: int = 0  # Track turns since last damage
var can_block_shot: bool = false  # Level 2+: Block one shot completely per encounter
var shots_blocked_this_encounter: int = 0  # Track blocked shots
var has_rapid_recharge: bool = false  # Level 3+: Full recharge in 3 turns if not hit
var is_adaptive: bool = false  # Level 4+: Adapt to damage types
var adapted_damage_type: String = ""  # Current adaptation
var adaptation_bonus: float = 0.25  # Additional 25% resistance to adapted type
var has_phase_shields: bool = false  # Level 5: 30% chance to completely avoid damage
var can_extend_to_allies: bool = false  # Level 5: Extend shields to nearby friendly ships

# Spec tables from ship-systems.md
const SHIELD_HP_BY_LEVEL: Array[int] = [0, 50, 150, 300, 500, 800]
const DAMAGE_REDUCTION_BY_LEVEL: Array[float] = [0.0, 0.25, 0.50, 0.70, 0.85, 0.95]
const RECHARGE_RATE_BY_LEVEL: Array[int] = [0, 5, 15, 30, 50, 80]
const POWER_COST_BY_LEVEL: Array[int] = [0, 15, 25, 40, 60, 85]

func _init() -> void:
	super._init("shields")

	display_name = "Shields"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 15, 25, 40, 60, 85]

	# Descriptions from design doc
	description_by_level = [
		"No shields installed. Hull takes all damage.",
		"Better than nothing. Barely.",
		"Solid protection. Standard across the galaxy.",
		"Multiple shield layers provide excellent protection.",
		"Military shields that learn and adapt to threats.",
		"Experimental phasing technology. Sometimes you're just not there when the shot arrives."
	]

## Override set_level to update shields-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update shield HP from spec
	if new_level >= 0 and new_level < SHIELD_HP_BY_LEVEL.size():
		max_shield_hp = SHIELD_HP_BY_LEVEL[new_level]
		shield_hp = max_shield_hp  # Start at full shields
	else:
		max_shield_hp = 0
		shield_hp = 0

	# Update damage reduction from spec
	if new_level >= 0 and new_level < DAMAGE_REDUCTION_BY_LEVEL.size():
		damage_reduction = DAMAGE_REDUCTION_BY_LEVEL[new_level]
	else:
		damage_reduction = 0.0

	# Update recharge rate from spec
	if new_level >= 0 and new_level < RECHARGE_RATE_BY_LEVEL.size():
		recharge_rate = RECHARGE_RATE_BY_LEVEL[new_level]
	else:
		recharge_rate = 0

	# Set special abilities
	if new_level >= 2:
		can_block_shot = true  # Level 2+: Block one shot completely (1/encounter)
	else:
		can_block_shot = false

	if new_level >= 3:
		has_rapid_recharge = true  # Level 3+: Full recharge in 3 turns if not hit
	else:
		has_rapid_recharge = false

	if new_level >= 4:
		is_adaptive = true  # Level 4+: Adapt to damage type (+25% resistance after being hit)
	else:
		is_adaptive = false
		adapted_damage_type = ""

	if new_level == 5:
		has_phase_shields = true  # Level 5: 30% chance to phase out and avoid damage
		can_extend_to_allies = true  # Level 5: Can extend shields to nearby friendly ships
	else:
		has_phase_shields = false
		can_extend_to_allies = false

	# Reset encounter counters
	turns_since_hit = 0
	shots_blocked_this_encounter = 0

	# Update GameState shields values
	_update_game_state_shields()

	if new_level > 0:
		print("Shields upgraded to Level %d: %d HP, %.0f%% damage reduction" % [
			level,
			max_shield_hp,
			damage_reduction * 100
		])

## Take damage to shields (returns overflow damage to hull)
func absorb_damage(incoming_damage: int, damage_type: String = "kinetic") -> int:
	if not active or shield_hp <= 0:
		return incoming_damage  # No shields, all damage passes through

	# Level 5: 30% chance to phase out and completely avoid damage
	if has_phase_shields and randf() < 0.30:
		print("Shields phased out - damage avoided!")
		return 0

	# Level 2+: Check if can block shot completely (once per encounter)
	if can_block_shot and shots_blocked_this_encounter == 0 and incoming_damage > shield_hp * 0.5:
		shots_blocked_this_encounter += 1
		print("Shield block activated - shot completely absorbed!")
		turns_since_hit = 0
		return 0

	# Calculate reduction
	var reduction = damage_reduction

	# Level 4+: Apply adaptation bonus if damage type matches
	if is_adaptive and damage_type == adapted_damage_type:
		reduction += adaptation_bonus
		reduction = min(reduction, 0.99)  # Cap at 99% to prevent invulnerability

	# Apply damage reduction
	var reduced_damage = int(incoming_damage * (1.0 - reduction))

	# Absorb damage with shields
	var damage_to_shields = min(reduced_damage, shield_hp)
	var overflow_damage = max(0, reduced_damage - shield_hp)

	shield_hp -= damage_to_shields
	turns_since_hit = 0

	# Level 4+: Adapt to damage type
	if is_adaptive and damage_type != "":
		if adapted_damage_type != damage_type:
			adapted_damage_type = damage_type
			print("Shields adapted to %s damage (+%.0f%% resistance)" % [damage_type, adaptation_bonus * 100])

	# Update GameState
	_update_game_state_shields()

	# Emit damage event
	EventBus.shields_hit.emit(damage_to_shields, shield_hp, max_shield_hp)

	return overflow_damage

## Recharge shields (called each turn)
func recharge_shields() -> void:
	if not active or shield_hp >= max_shield_hp:
		return

	turns_since_hit += 1

	# Level 3+: Rapid recharge if not hit for 3 turns
	if has_rapid_recharge and turns_since_hit >= 3:
		shield_hp = max_shield_hp
		print("Shields fully recharged (rapid recharge)")
	else:
		# Normal recharge
		var old_hp = shield_hp
		shield_hp = min(max_shield_hp, shield_hp + recharge_rate)
		if shield_hp > old_hp:
			EventBus.shields_recharged.emit(shield_hp - old_hp, shield_hp, max_shield_hp)

	# Update GameState
	_update_game_state_shields()

## Reset encounter counters (called at start of each encounter)
func reset_encounter() -> void:
	shots_blocked_this_encounter = 0
	turns_since_hit = 0
	shield_hp = max_shield_hp  # Start encounters with full shields

## Rotate shield frequency (Level 4+: reset adaptations manually)
func rotate_frequency() -> void:
	if not is_adaptive:
		return

	adapted_damage_type = ""
	print("Shield frequency rotated - adaptations reset")

## Get current shield HP percentage (0-100)
func get_shield_percent() -> float:
	if max_shield_hp == 0:
		return 0.0
	return (float(shield_hp) / float(max_shield_hp)) * 100.0

## Get damage reduction as percentage (0-100)
func get_damage_reduction_percent() -> float:
	var total_reduction = damage_reduction
	if is_adaptive and adapted_damage_type != "":
		total_reduction += adaptation_bonus
	return min(total_reduction, 0.99) * 100.0

## Check if can block shots (Level 2+)
func can_block_shots() -> bool:
	return can_block_shot and shots_blocked_this_encounter == 0

## Check if has rapid recharge (Level 3+)
func has_rapid_recharge_ability() -> bool:
	return has_rapid_recharge

## Check if shields are adaptive (Level 4+)
func are_shields_adaptive() -> bool:
	return is_adaptive

## Get current adaptation info
func get_adaptation_info() -> String:
	if not is_adaptive or adapted_damage_type == "":
		return "Not adapted"
	return "Adapted to %s (+%.0f%% resistance)" % [adapted_damage_type, adaptation_bonus * 100]

## Check if has phase shields (Level 5)
func has_phase_shield_ability() -> bool:
	return has_phase_shields

## Check if can extend shields to allies (Level 5)
func can_extend_shields() -> bool:
	return can_extend_to_allies

## Update GameState with current shields values
func _update_game_state_shields() -> void:
	# Update system data in GameState
	GameState.ship.systems.shields.level = level
	GameState.ship.systems.shields.health = health
	GameState.ship.systems.shields.max_health = max_health
	GameState.ship.systems.shields.active = active

	# Recalculate ship power stats (shields consume power)
	GameState._recalculate_ship_stats()

## Override to_dict to include shields-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["shield_hp"] = shield_hp
	data["max_shield_hp"] = max_shield_hp
	data["damage_reduction"] = damage_reduction
	data["recharge_rate"] = recharge_rate
	data["turns_since_hit"] = turns_since_hit
	data["can_block_shot"] = can_block_shot
	data["shots_blocked_this_encounter"] = shots_blocked_this_encounter
	data["has_rapid_recharge"] = has_rapid_recharge
	data["is_adaptive"] = is_adaptive
	data["adapted_damage_type"] = adapted_damage_type
	data["has_phase_shields"] = has_phase_shields
	data["can_extend_to_allies"] = can_extend_to_allies
	return data

## Override from_dict to load shields-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	shield_hp = data.get("shield_hp", 0)
	max_shield_hp = data.get("max_shield_hp", 0)
	damage_reduction = data.get("damage_reduction", 0.0)
	recharge_rate = data.get("recharge_rate", 0)
	turns_since_hit = data.get("turns_since_hit", 0)
	can_block_shot = data.get("can_block_shot", false)
	shots_blocked_this_encounter = data.get("shots_blocked_this_encounter", 0)
	has_rapid_recharge = data.get("has_rapid_recharge", false)
	is_adaptive = data.get("is_adaptive", false)
	adapted_damage_type = data.get("adapted_damage_type", "")
	has_phase_shields = data.get("has_phase_shields", false)
	can_extend_to_allies = data.get("can_extend_to_allies", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Shields not installed\nHull takes all damage"

	var stats = "Shield HP: %d / %d (%.0f%%)\n" % [shield_hp, max_shield_hp, get_shield_percent()]
	stats += "Damage Reduction: %.0f%%\n" % (damage_reduction * 100)
	stats += "Recharge Rate: %d HP/turn\n" % recharge_rate
	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 2:
		stats += "\nSpecial Abilities:\n"
		if can_block_shot:
			stats += "  • Block one shot completely (1/encounter)\n"
			if shots_blocked_this_encounter > 0:
				stats += "    (Already used this encounter)\n"
		if has_rapid_recharge:
			stats += "  • Rapid recharge (full in 3 turns)\n"
		if is_adaptive:
			stats += "  • Adaptive shields\n"
			stats += "    Current: %s\n" % get_adaptation_info()
		if has_phase_shields:
			stats += "  • Phase shields (30% avoid damage)\n"
		if can_extend_to_allies:
			stats += "  • Extend shields to friendly ships\n"

	stats += "\nStatus: %s" % get_status()

	return stats

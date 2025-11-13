extends ShipSystem
class_name ComputerSystem

## Computer Core System
## Ship automation, AI assistance, tactical calculations
##
## Level 0: No Computer (0 PU, manual control only)
## Level 1: Basic Computer (5 PU, manual ship control, basic calculations)
## Level 2: Standard AI (10 PU, +10% weapon accuracy, auto-navigation, basic threat assessment, unlocks AI personality)
## Level 3: Advanced AI (20 PU, tactical recommendations, predictive analysis, +20% weapon accuracy, +15% sensor effectiveness, auto-repair 20% faster)
## Level 4: Tactical AI (35 PU, combat automation, +35% weapon accuracy, +25% dodge, emergency protocols)
## Level 5: Sentient AI (50 PU, companion NPC, creative problem-solving, +50% all combat stats, autonomous operations, emotional intelligence)

# Computer-specific properties
var processing_power: int = 0  # AI capability (0-5)
var automation_level: float = 0.0  # Percentage of tasks automated (0.0 to 1.0)
var tactical_bonus: float = 0.0  # Combat calculation bonus
var weapon_accuracy_bonus: float = 0.0  # Bonus to weapon accuracy
var sensor_effectiveness_bonus: float = 0.0  # Bonus to sensor effectiveness
var dodge_bonus: float = 0.0  # Bonus to evasion
var repair_speed_bonus: float = 0.0  # Percentage faster repairs
var unlocks_ai_personality: bool = false  # Level 2+: AI personality system
var provides_tactical_advice: bool = false  # Level 3+: Suggests optimal actions
var has_predictive_analysis: bool = false  # Level 3+: Warns of probable dangers
var can_automate_combat: bool = false  # Level 4+: Fight autonomously
var has_emergency_protocols: bool = false  # Level 4+: Auto-activate shields when threatened
var is_sentient: bool = false  # Level 5: True artificial consciousness
var has_creative_problem_solving: bool = false  # Level 5: Generate novel solutions
var has_emotional_intelligence: bool = false  # Level 5: Better at diplomacy

# Spec tables from ship-systems.md
const PROCESSING_POWER_BY_LEVEL: Array[int] = [0, 1, 2, 3, 4, 5]
const AUTOMATION_BY_LEVEL: Array[float] = [0.0, 0.0, 0.20, 0.40, 0.70, 1.0]
const WEAPON_ACCURACY_BY_LEVEL: Array[float] = [0.0, 0.0, 0.10, 0.20, 0.35, 0.50]
const SENSOR_BONUS_BY_LEVEL: Array[float] = [0.0, 0.0, 0.0, 0.15, 0.25, 0.40]
const DODGE_BONUS_BY_LEVEL: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.25, 0.50]
const REPAIR_SPEED_BY_LEVEL: Array[float] = [0.0, 0.0, 0.0, 0.20, 0.35, 0.50]
const POWER_COST_BY_LEVEL: Array[int] = [0, 5, 10, 20, 35, 50]

func _init() -> void:
	super._init("computer")

	display_name = "Computer Core"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 5, 10, 20, 35, 50]

	# Descriptions from design doc
	description_by_level = [
		"No computer installed. Manual ship control only.",
		"Calculator with delusions of grandeur.",
		"Helpful AI assistant. Follows orders without complaint.",
		"Intelligent AI that learns and adapts. Almost like having a crew.",
		"Military-grade tactical computer. Thinks faster than you do.",
		"A true artificial consciousness. It's not just a ship anymore - it's a friend."
	]

## Override set_level to update computer-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update processing power from spec
	if new_level >= 0 and new_level < PROCESSING_POWER_BY_LEVEL.size():
		processing_power = PROCESSING_POWER_BY_LEVEL[new_level]
	else:
		processing_power = 0

	# Update automation level from spec
	if new_level >= 0 and new_level < AUTOMATION_BY_LEVEL.size():
		automation_level = AUTOMATION_BY_LEVEL[new_level]
	else:
		automation_level = 0.0

	# Update weapon accuracy bonus from spec
	if new_level >= 0 and new_level < WEAPON_ACCURACY_BY_LEVEL.size():
		weapon_accuracy_bonus = WEAPON_ACCURACY_BY_LEVEL[new_level]
	else:
		weapon_accuracy_bonus = 0.0

	# Update sensor effectiveness bonus from spec
	if new_level >= 0 and new_level < SENSOR_BONUS_BY_LEVEL.size():
		sensor_effectiveness_bonus = SENSOR_BONUS_BY_LEVEL[new_level]
	else:
		sensor_effectiveness_bonus = 0.0

	# Update dodge bonus from spec
	if new_level >= 0 and new_level < DODGE_BONUS_BY_LEVEL.size():
		dodge_bonus = DODGE_BONUS_BY_LEVEL[new_level]
	else:
		dodge_bonus = 0.0

	# Update repair speed bonus from spec
	if new_level >= 0 and new_level < REPAIR_SPEED_BY_LEVEL.size():
		repair_speed_bonus = REPAIR_SPEED_BY_LEVEL[new_level]
	else:
		repair_speed_bonus = 0.0

	# Set tactical bonus (general combat effectiveness)
	tactical_bonus = weapon_accuracy_bonus  # Use weapon accuracy as base tactical bonus

	# Set special abilities
	if new_level >= 2:
		unlocks_ai_personality = true  # Level 2+: AI personality system (ATLAS, etc.)
	else:
		unlocks_ai_personality = false

	if new_level >= 3:
		provides_tactical_advice = true  # Level 3+: Suggests optimal actions
		has_predictive_analysis = true  # Level 3+: Warns of probable dangers
	else:
		provides_tactical_advice = false
		has_predictive_analysis = false

	if new_level >= 4:
		can_automate_combat = true  # Level 4+: Can fight autonomously
		has_emergency_protocols = true  # Level 4+: Auto-activate shields when threatened
	else:
		can_automate_combat = false
		has_emergency_protocols = false

	if new_level == 5:
		is_sentient = true  # Level 5: True artificial consciousness
		has_creative_problem_solving = true  # Level 5: Generate novel solutions
		has_emotional_intelligence = true  # Level 5: Better at diplomacy
	else:
		is_sentient = false
		has_creative_problem_solving = false
		has_emotional_intelligence = false

	# Update GameState computer values
	_update_game_state_computer()

	if new_level > 0:
		print("Computer Core upgraded to Level %d: %.0f%% automation, +%.0f%% weapon accuracy" % [
			level,
			automation_level * 100,
			weapon_accuracy_bonus * 100
		])

## Get current processing power (AI capability)
func get_processing_power() -> int:
	if not active:
		return 0
	return processing_power

## Get automation level as percentage (0-100)
func get_automation_percent() -> float:
	return automation_level * 100.0

## Get tactical bonus as percentage (0-100)
func get_tactical_bonus_percent() -> float:
	return tactical_bonus * 100.0

## Get weapon accuracy bonus as percentage (0-100)
func get_weapon_accuracy_bonus_percent() -> float:
	return weapon_accuracy_bonus * 100.0

## Get sensor effectiveness bonus as percentage (0-100)
func get_sensor_bonus_percent() -> float:
	return sensor_effectiveness_bonus * 100.0

## Get dodge bonus as percentage (0-100)
func get_dodge_bonus_percent() -> float:
	return dodge_bonus * 100.0

## Get repair speed bonus as percentage (0-100)
func get_repair_speed_bonus_percent() -> float:
	return repair_speed_bonus * 100.0

## Check if AI personality system is unlocked (Level 2+)
func is_ai_personality_unlocked() -> bool:
	return unlocks_ai_personality

## Check if provides tactical advice (Level 3+)
func can_provide_tactical_advice() -> bool:
	return provides_tactical_advice

## Check if has predictive analysis (Level 3+)
func has_predictive_analysis_ability() -> bool:
	return has_predictive_analysis

## Check if can automate combat (Level 4+)
func can_automate_combat_operations() -> bool:
	return can_automate_combat

## Check if has emergency protocols (Level 4+)
func has_emergency_protocol_system() -> bool:
	return has_emergency_protocols

## Check if AI is sentient (Level 5)
func is_ai_sentient() -> bool:
	return is_sentient

## Check if has creative problem solving (Level 5)
func can_solve_problems_creatively() -> bool:
	return has_creative_problem_solving

## Check if has emotional intelligence (Level 5)
func has_emotional_intelligence_capability() -> bool:
	return has_emotional_intelligence

## Calculate modified repair time (faster repairs at higher levels)
func calculate_repair_time(base_time: float) -> float:
	if not active or repair_speed_bonus == 0.0:
		return base_time
	return base_time * (1.0 - repair_speed_bonus)

## Update GameState with current computer values
func _update_game_state_computer() -> void:
	# Update system data in GameState
	GameState.ship.systems.computer.level = level
	GameState.ship.systems.computer.health = health
	GameState.ship.systems.computer.max_health = max_health
	GameState.ship.systems.computer.active = active

	# Recalculate ship power stats (computer consumes power)
	GameState._recalculate_ship_stats()

## Override to_dict to include computer-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["processing_power"] = processing_power
	data["automation_level"] = automation_level
	data["tactical_bonus"] = tactical_bonus
	data["weapon_accuracy_bonus"] = weapon_accuracy_bonus
	data["sensor_effectiveness_bonus"] = sensor_effectiveness_bonus
	data["dodge_bonus"] = dodge_bonus
	data["repair_speed_bonus"] = repair_speed_bonus
	data["unlocks_ai_personality"] = unlocks_ai_personality
	data["provides_tactical_advice"] = provides_tactical_advice
	data["has_predictive_analysis"] = has_predictive_analysis
	data["can_automate_combat"] = can_automate_combat
	data["has_emergency_protocols"] = has_emergency_protocols
	data["is_sentient"] = is_sentient
	data["has_creative_problem_solving"] = has_creative_problem_solving
	data["has_emotional_intelligence"] = has_emotional_intelligence
	return data

## Override from_dict to load computer-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	processing_power = data.get("processing_power", 0)
	automation_level = data.get("automation_level", 0.0)
	tactical_bonus = data.get("tactical_bonus", 0.0)
	weapon_accuracy_bonus = data.get("weapon_accuracy_bonus", 0.0)
	sensor_effectiveness_bonus = data.get("sensor_effectiveness_bonus", 0.0)
	dodge_bonus = data.get("dodge_bonus", 0.0)
	repair_speed_bonus = data.get("repair_speed_bonus", 0.0)
	unlocks_ai_personality = data.get("unlocks_ai_personality", false)
	provides_tactical_advice = data.get("provides_tactical_advice", false)
	has_predictive_analysis = data.get("has_predictive_analysis", false)
	can_automate_combat = data.get("can_automate_combat", false)
	has_emergency_protocols = data.get("has_emergency_protocols", false)
	is_sentient = data.get("is_sentient", false)
	has_creative_problem_solving = data.get("has_creative_problem_solving", false)
	has_emotional_intelligence = data.get("has_emotional_intelligence", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Computer Core not installed\nManual ship control only"

	var stats = "Processing Power: Level %d\n" % processing_power
	stats += "Automation: %.0f%%\n" % (automation_level * 100)

	if weapon_accuracy_bonus > 0.0:
		stats += "Weapon Accuracy: +%.0f%%\n" % (weapon_accuracy_bonus * 100)
	if sensor_effectiveness_bonus > 0.0:
		stats += "Sensor Effectiveness: +%.0f%%\n" % (sensor_effectiveness_bonus * 100)
	if dodge_bonus > 0.0:
		stats += "Dodge Chance: +%.0f%%\n" % (dodge_bonus * 100)
	if repair_speed_bonus > 0.0:
		stats += "Repair Speed: +%.0f%%\n" % (repair_speed_bonus * 100)

	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 2:
		stats += "\nSpecial Abilities:\n"
		if unlocks_ai_personality:
			stats += "  • AI personality system unlocked\n"
		if provides_tactical_advice:
			stats += "  • Tactical recommendations\n"
		if has_predictive_analysis:
			stats += "  • Predictive analysis (danger warnings)\n"
		if can_automate_combat:
			stats += "  • Combat automation\n"
		if has_emergency_protocols:
			stats += "  • Emergency protocols (auto-shields)\n"
		if is_sentient:
			stats += "  • Sentient AI companion\n"
		if has_creative_problem_solving:
			stats += "  • Creative problem-solving\n"
		if has_emotional_intelligence:
			stats += "  • Emotional intelligence (diplomacy)\n"

	stats += "\nStatus: %s" % get_status()

	return stats

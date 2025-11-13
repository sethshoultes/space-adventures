extends ShipSystem
class_name SensorsSystem

## Sensors System
## Detection, scanning, situational awareness
##
## Level 0: No Sensors (0 PU, 0 AU range)
## Level 1: Optical Sensors (5 PU, 1 AU, basic visual data)
## Level 2: EM Spectrum Sensors (10 PU, 5 AU, detailed composition, +20% encounter warning)
## Level 3: Subspace Array (20 PU, 50 AU, long-range threat detection, +40% encounter warning, unlock detailed scan mini-game)
## Level 4: Multi-Phasic Sensors (35 PU, 500 AU system-wide, detect cloaked ships, +60% encounter warning)
## Level 5: Quantum Sensors (50 PU, entire sector, precognitive, +100% encounter warning, unlock "Future Vision")

# Sensors-specific properties
var detection_range_au: float = 0.0  # Detection range in AU
var scan_quality: String = "none"  # Quality of scan data
var encounter_warning_bonus: float = 0.0  # Percentage bonus to encounter warning time
var can_detect_life_signs: bool = false  # Level 2+: Basic life form detection
var can_detailed_scan: bool = false  # Level 3+: Comprehensive analysis
var can_detect_cloaked: bool = false  # Level 4+: Detect cloaked ships
var can_predict_positions: bool = false  # Level 5: Predict future positions
var has_future_vision: bool = false  # Level 5: See consequences before choosing

# Spec tables from ship-systems.md
const RANGE_BY_LEVEL: Array[float] = [0.0, 1.0, 5.0, 50.0, 500.0, 999999.0]  # AU (last is "entire sector")
const SCAN_QUALITY_BY_LEVEL: Array[String] = ["none", "basic visual", "detailed composition", "comprehensive analysis", "extremely detailed", "precognitive"]
const WARNING_BONUS_BY_LEVEL: Array[float] = [0.0, 0.0, 0.20, 0.40, 0.60, 1.00]
const POWER_COST_BY_LEVEL: Array[int] = [0, 5, 10, 20, 35, 50]

func _init() -> void:
	super._init("sensors")

	display_name = "Sensors"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 5, 10, 20, 35, 50]

	# Descriptions from design doc
	description_by_level = [
		"No sensors installed. Flying blind.",
		"Fancy cameras pointed at space.",
		"See across the electromagnetic spectrum. Much more useful.",
		"Peer deep into space. Little escapes your notice.",
		"Military sensor suite. Nothing hides from you.",
		"Experimental quantum technology. You see things before they happen."
	]

## Override set_level to update sensors-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update detection range from spec
	if new_level >= 0 and new_level < RANGE_BY_LEVEL.size():
		detection_range_au = RANGE_BY_LEVEL[new_level]
	else:
		detection_range_au = 0.0

	# Update scan quality from spec
	if new_level >= 0 and new_level < SCAN_QUALITY_BY_LEVEL.size():
		scan_quality = SCAN_QUALITY_BY_LEVEL[new_level]
	else:
		scan_quality = "none"

	# Update encounter warning bonus from spec
	if new_level >= 0 and new_level < WARNING_BONUS_BY_LEVEL.size():
		encounter_warning_bonus = WARNING_BONUS_BY_LEVEL[new_level]
	else:
		encounter_warning_bonus = 0.0

	# Set special abilities
	if new_level >= 2:
		can_detect_life_signs = true  # Level 2+: Basic life form detection
	else:
		can_detect_life_signs = false

	if new_level >= 3:
		can_detailed_scan = true  # Level 3+: Unlock detailed scan mini-game
	else:
		can_detailed_scan = false

	if new_level >= 4:
		can_detect_cloaked = true  # Level 4+: Detect cloaked ships
		can_predict_positions = false  # Not level 5 yet
	else:
		can_detect_cloaked = false
		can_predict_positions = false

	if new_level == 5:
		can_predict_positions = true  # Level 5: Predict future positions (1 hour ahead)
		has_future_vision = true  # Level 5: Unlock "Future Vision" ability
	else:
		can_predict_positions = false
		has_future_vision = false

	# Update GameState sensors values
	_update_game_state_sensors()

	if new_level > 0:
		print("Sensors upgraded to Level %d: %.0f AU range, %.0f%% encounter warning bonus" % [
			level,
			detection_range_au,
			encounter_warning_bonus * 100
		])

## Get current detection range in AU
func get_detection_range() -> float:
	if not active:
		return 0.0
	return detection_range_au

## Get detection range as human-readable string
func get_range_string() -> String:
	if detection_range_au >= 999999:
		return "Entire sector"
	elif detection_range_au >= 500:
		return "System-wide"
	else:
		return "%.0f AU" % detection_range_au

## Get scan quality description
func get_scan_quality() -> String:
	return scan_quality

## Get encounter warning bonus as percentage (0-100)
func get_encounter_warning_percent() -> float:
	return encounter_warning_bonus * 100.0

## Check if can detect life signs (Level 2+)
func can_detect_life_forms() -> bool:
	return can_detect_life_signs

## Check if can perform detailed scans (Level 3+)
func can_perform_detailed_scan() -> bool:
	return can_detailed_scan

## Check if can detect cloaked ships (Level 4+)
func can_detect_cloaked_ships() -> bool:
	return can_detect_cloaked

## Check if can predict future positions (Level 5)
func can_predict_future_positions() -> bool:
	return can_predict_positions

## Check if has future vision ability (Level 5)
func has_future_vision_ability() -> bool:
	return has_future_vision

## Update GameState with current sensors values
func _update_game_state_sensors() -> void:
	# Update system data in GameState
	GameState.ship.systems.sensors.level = level
	GameState.ship.systems.sensors.health = health
	GameState.ship.systems.sensors.max_health = max_health
	GameState.ship.systems.sensors.active = active

	# Recalculate ship power stats (sensors consume power)
	GameState._recalculate_ship_stats()

## Override to_dict to include sensors-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["detection_range_au"] = detection_range_au
	data["scan_quality"] = scan_quality
	data["encounter_warning_bonus"] = encounter_warning_bonus
	data["can_detect_life_signs"] = can_detect_life_signs
	data["can_detailed_scan"] = can_detailed_scan
	data["can_detect_cloaked"] = can_detect_cloaked
	data["can_predict_positions"] = can_predict_positions
	data["has_future_vision"] = has_future_vision
	return data

## Override from_dict to load sensors-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	detection_range_au = data.get("detection_range_au", 0.0)
	scan_quality = data.get("scan_quality", "none")
	encounter_warning_bonus = data.get("encounter_warning_bonus", 0.0)
	can_detect_life_signs = data.get("can_detect_life_signs", false)
	can_detailed_scan = data.get("can_detailed_scan", false)
	can_detect_cloaked = data.get("can_detect_cloaked", false)
	can_predict_positions = data.get("can_predict_positions", false)
	has_future_vision = data.get("has_future_vision", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Sensors not installed\nFlying blind"

	var stats = "Detection Range: %s\n" % get_range_string()
	stats += "Scan Quality: %s\n" % scan_quality.capitalize()

	if encounter_warning_bonus > 0.0:
		stats += "Encounter Warning: +%.0f%%\n" % (encounter_warning_bonus * 100)

	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 2:
		stats += "\nSpecial Abilities:\n"
		if can_detect_life_signs:
			stats += "  • Detect life forms\n"
		if can_detailed_scan:
			stats += "  • Detailed scan mini-game\n"
		if can_detect_cloaked:
			stats += "  • Detect cloaked ships\n"
		if can_predict_positions:
			stats += "  • Predict future positions (1 hour)\n"
		if has_future_vision:
			stats += "  • Future Vision (see consequences)\n"

	stats += "\nStatus: %s" % get_status()

	return stats

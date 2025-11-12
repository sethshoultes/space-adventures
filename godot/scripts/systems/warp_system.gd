extends ShipSystem
class_name WarpSystem

## Warp Drive System
## Faster-than-light travel between star systems
##
## Level 0: No FTL (Trapped in starting system, 0 PU)
## Level 1: Warp 1 Drive (1× light speed, 2 LY range, 20 PU)
## Level 2: Warp 3 Drive (9× light speed, 10 LY range, 30 PU)
## Level 3: Warp 5 Drive (125× light speed, 50 LY range, 50 PU, can escape encounters)
## Level 4: Warp 7 Drive (343× light speed, 200 LY range, 80 PU, tactical jumps)
## Level 5: Warp 9 + Transwarp (729× light speed, unlimited range, 120 PU, transwarp corridors)

# Warp-specific properties
var warp_factor: float = 0.0  # Warp factor (1, 3, 5, 7, 9)
var light_speed_multiplier: float = 0.0  # How many times faster than light
var range_light_years: float = 0.0  # Maximum range in light years
var travel_time_per_ly: float = 0.0  # Hours per light year
var accessible_systems: int = 0  # Number of systems within range
var can_escape_encounters: bool = false  # Level 3+: Can escape hostile encounters
var has_tactical_jumps: bool = false  # Level 4+: Short-range combat repositioning
var has_transwarp: bool = false  # Level 5: Transwarp corridors for instant travel

# Spec tables from ship-systems.md
const WARP_FACTOR_BY_LEVEL: Array[float] = [0.0, 1.0, 3.0, 5.0, 7.0, 9.0]
const LIGHT_SPEED_MULT_BY_LEVEL: Array[float] = [0.0, 1.0, 9.0, 125.0, 343.0, 729.0]
const RANGE_BY_LEVEL: Array[float] = [0.0, 2.0, 10.0, 50.0, 200.0, 999999.0]  # Last is "unlimited"
const TRAVEL_TIME_BY_LEVEL: Array[float] = [0.0, 24.0, 3.0, 0.5, 0.083, 0.0]  # Hours per LY
const ACCESSIBLE_SYSTEMS_BY_LEVEL: Array[int] = [0, 3, 12, 50, 150, 999999]  # Last is "entire galaxy"
const POWER_COST_BY_LEVEL: Array[int] = [0, 20, 30, 50, 80, 120]

func _init() -> void:
	super._init("warp")

	display_name = "Warp Drive"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 20, 30, 50, 80, 120]

	# Descriptions from design doc
	description_by_level = [
		"No warp drive installed. Trapped in starting system.",
		"Your ticket off Earth. Barely faster than light, but it counts.",
		"Now we're traveling. The close sectors are yours to explore.",
		"Standard deep-space warp drive. The galaxy opens up.",
		"Military-spec drive. Fast enough to outrun trouble.",
		"Bleeding-edge tech. Jump across the galaxy in moments."
	]

## Override set_level to update warp-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update warp factor from spec
	if new_level >= 0 and new_level < WARP_FACTOR_BY_LEVEL.size():
		warp_factor = WARP_FACTOR_BY_LEVEL[new_level]
	else:
		warp_factor = 0.0

	# Update light speed multiplier from spec
	if new_level >= 0 and new_level < LIGHT_SPEED_MULT_BY_LEVEL.size():
		light_speed_multiplier = LIGHT_SPEED_MULT_BY_LEVEL[new_level]
	else:
		light_speed_multiplier = 0.0

	# Update range from spec
	if new_level >= 0 and new_level < RANGE_BY_LEVEL.size():
		range_light_years = RANGE_BY_LEVEL[new_level]
	else:
		range_light_years = 0.0

	# Update travel time from spec
	if new_level >= 0 and new_level < TRAVEL_TIME_BY_LEVEL.size():
		travel_time_per_ly = TRAVEL_TIME_BY_LEVEL[new_level]
	else:
		travel_time_per_ly = 0.0

	# Update accessible systems from spec
	if new_level >= 0 and new_level < ACCESSIBLE_SYSTEMS_BY_LEVEL.size():
		accessible_systems = ACCESSIBLE_SYSTEMS_BY_LEVEL[new_level]
	else:
		accessible_systems = 0

	# Set special abilities
	if new_level >= 3:
		can_escape_encounters = true  # Level 3+: Can escape most hostile encounters
	else:
		can_escape_encounters = false

	if new_level >= 4:
		has_tactical_jumps = true  # Level 4+: Short-range combat repositioning
	else:
		has_tactical_jumps = false

	if new_level == 5:
		has_transwarp = true  # Level 5: Instant travel to discovered systems
	else:
		has_transwarp = false

	# Update GameState warp values
	_update_game_state_warp()

	if new_level > 0:
		print("Warp Drive upgraded to Level %d: Warp %.0f (%.0fx light speed), %.0f LY range" % [
			level,
			warp_factor,
			light_speed_multiplier,
			range_light_years
		])

## Get current warp factor
func get_warp_factor() -> float:
	if not active:
		return 0.0
	return warp_factor

## Get light speed multiplier
func get_light_speed_multiplier() -> float:
	if not active:
		return 0.0
	return light_speed_multiplier

## Get maximum range in light years
func get_range() -> float:
	if not active:
		return 0.0
	return range_light_years

## Get travel time for a given distance in light years
func calculate_travel_time(distance_ly: float) -> float:
	if not active or distance_ly <= 0.0:
		return 0.0
	if travel_time_per_ly == 0.0:  # Transwarp - instant
		return 0.0
	return distance_ly * travel_time_per_ly

## Check if can reach a system at given distance
func can_reach_system(distance_ly: float) -> bool:
	if not active:
		return false
	return distance_ly <= range_light_years

## Get number of accessible systems at current level
func get_accessible_systems_count() -> int:
	return accessible_systems

## Check if can escape encounters (Level 3+)
func can_escape_hostile_encounters() -> bool:
	return can_escape_encounters

## Check if has tactical warp jumps (Level 4+)
func can_tactical_jump() -> bool:
	return has_tactical_jumps

## Check if has transwarp capability (Level 5)
func can_use_transwarp() -> bool:
	return has_transwarp

## Update GameState with current warp values
func _update_game_state_warp() -> void:
	# Update system data in GameState
	GameState.ship.systems.warp.level = level
	GameState.ship.systems.warp.health = health
	GameState.ship.systems.warp.max_health = max_health
	GameState.ship.systems.warp.active = active

	# Recalculate ship power stats (warp consumes power when traveling)
	GameState._recalculate_ship_stats()

## Override to_dict to include warp-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["warp_factor"] = warp_factor
	data["light_speed_multiplier"] = light_speed_multiplier
	data["range_light_years"] = range_light_years
	data["travel_time_per_ly"] = travel_time_per_ly
	data["accessible_systems"] = accessible_systems
	data["can_escape_encounters"] = can_escape_encounters
	data["has_tactical_jumps"] = has_tactical_jumps
	data["has_transwarp"] = has_transwarp
	return data

## Override from_dict to load warp-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	warp_factor = data.get("warp_factor", 0.0)
	light_speed_multiplier = data.get("light_speed_multiplier", 0.0)
	range_light_years = data.get("range_light_years", 0.0)
	travel_time_per_ly = data.get("travel_time_per_ly", 0.0)
	accessible_systems = data.get("accessible_systems", 0)
	can_escape_encounters = data.get("can_escape_encounters", false)
	has_tactical_jumps = data.get("has_tactical_jumps", false)
	has_transwarp = data.get("has_transwarp", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Warp Drive not installed\nTrapped in starting system"

	var stats = "Warp Factor: %.1f\n" % warp_factor
	stats += "Speed: %.0fx light speed\n" % light_speed_multiplier

	if range_light_years > 999999:
		stats += "Range: Unlimited\n"
	else:
		stats += "Range: %.0f light years\n" % range_light_years

	if travel_time_per_ly == 0.0:
		stats += "Travel Time: Instant\n"
	elif travel_time_per_ly < 1.0:
		stats += "Travel Time: %.0f minutes per LY\n" % (travel_time_per_ly * 60)
	else:
		stats += "Travel Time: %.1f hours per LY\n" % travel_time_per_ly

	if accessible_systems > 999999:
		stats += "Accessible Systems: Entire galaxy\n"
	else:
		stats += "Accessible Systems: %d\n" % accessible_systems

	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 3:
		stats += "\nSpecial Abilities:\n"
		if can_escape_encounters:
			stats += "  • Can escape hostile encounters\n"
		if has_tactical_jumps:
			stats += "  • Tactical warp jumps (combat repositioning)\n"
		if has_transwarp:
			stats += "  • Transwarp corridors (instant travel)\n"

	stats += "\nStatus: %s" % get_status()

	return stats

extends ShipSystem
class_name CommunicationsSystem

## Communications Array System
## Long-range communication, translation, diplomacy
##
## Level 0: No Communications (0 PU, cannot communicate)
## Level 1: Radio Transceiver (5 PU, short range, basic Earth comms, receive distress signals)
## Level 2: Subspace Radio (8 PU, system-wide, access local networks, receive missions, +10% diplomacy)
## Level 3: Universal Translator (12 PU, galaxy-wide, all alien species, +20% diplomacy, unlock "Diplomacy" alternative to combat)
## Level 4: Quantum Entanglement Communicator (18 PU, unlimited instant, cannot be intercepted, +35% diplomacy, special missions)
## Level 5: Psionic Amplifier (25 PU, unlimited empathic, telepathic comms, detect lies, +50% diplomacy, hidden dialogue options)

# Communications-specific properties
var comm_range: String = "none"  # Communication range description
var comm_range_ly: float = 0.0  # Range in light years (for system comparison)
var translation_capability: int = 0  # Number of languages (0 = none, 999999 = all)
var encryption_strength: int = 0  # Security level (0-5)
var diplomacy_bonus: float = 0.0  # Percentage bonus to diplomacy checks
var can_receive_distress: bool = false  # Level 1+: Receive distress signals
var can_access_networks: bool = false  # Level 2+: Access information networks
var can_receive_missions: bool = false  # Level 2+: NPCs can send missions
var unlocks_diplomacy: bool = false  # Level 3+: Diplomacy as alternative to combat
var is_instant: bool = false  # Level 4+: Instant communication (no delay)
var cannot_be_intercepted: bool = false  # Level 4+: Quantum-encrypted
var can_access_classified: bool = false  # Level 4+: Classified information networks
var has_telepathy: bool = false  # Level 5: Telepathic communication
var can_detect_lies: bool = false  # Level 5: Sense emotions and intentions
var unlocks_hidden_dialogue: bool = false  # Level 5: Hidden dialogue options
var can_communicate_nonverbal: bool = false  # Level 5: Communicate with non-verbal life

# Spec tables from ship-systems.md
const RANGE_BY_LEVEL: Array[String] = ["none", "short (same planet/station)", "system-wide", "galaxy-wide", "unlimited (instant)", "unlimited + empathic"]
const RANGE_LY_BY_LEVEL: Array[float] = [0.0, 0.1, 10.0, 100000.0, 999999.0, 999999.0]  # Approximate LY equivalents
const TRANSLATION_BY_LEVEL: Array[int] = [0, 1, 10, 999999, 999999, 999999]  # Languages (999999 = all known)
const ENCRYPTION_BY_LEVEL: Array[int] = [0, 1, 2, 3, 5, 5]  # Security level
const DIPLOMACY_BONUS_BY_LEVEL: Array[float] = [0.0, 0.0, 0.10, 0.20, 0.35, 0.50]
const POWER_COST_BY_LEVEL: Array[int] = [0, 5, 8, 12, 18, 25]

func _init() -> void:
	super._init("communications")

	display_name = "Communications"
	max_levels = 5

	# Power costs by level
	power_cost_by_level = [0, 5, 8, 12, 18, 25]

	# Descriptions from design doc
	description_by_level = [
		"No communications system installed. Cannot communicate.",
		"Hello? Can anyone hear me?",
		"Connected to the local network. Information is power.",
		"Speak to anyone, anywhere. The galaxy becomes much friendlier.",
		"Quantum-encrypted instant communication. No delay, no interception.",
		"Touch minds across the void. You understand species on a deeper level."
	]

## Override set_level to update communications-specific stats
func set_level(new_level: int) -> void:
	super.set_level(new_level)

	# Update comm range from spec
	if new_level >= 0 and new_level < RANGE_BY_LEVEL.size():
		comm_range = RANGE_BY_LEVEL[new_level]
		comm_range_ly = RANGE_LY_BY_LEVEL[new_level]
	else:
		comm_range = "none"
		comm_range_ly = 0.0

	# Update translation capability from spec
	if new_level >= 0 and new_level < TRANSLATION_BY_LEVEL.size():
		translation_capability = TRANSLATION_BY_LEVEL[new_level]
	else:
		translation_capability = 0

	# Update encryption strength from spec
	if new_level >= 0 and new_level < ENCRYPTION_BY_LEVEL.size():
		encryption_strength = ENCRYPTION_BY_LEVEL[new_level]
	else:
		encryption_strength = 0

	# Update diplomacy bonus from spec
	if new_level >= 0 and new_level < DIPLOMACY_BONUS_BY_LEVEL.size():
		diplomacy_bonus = DIPLOMACY_BONUS_BY_LEVEL[new_level]
	else:
		diplomacy_bonus = 0.0

	# Set special abilities
	if new_level >= 1:
		can_receive_distress = true  # Level 1+: Receive distress signals
	else:
		can_receive_distress = false

	if new_level >= 2:
		can_access_networks = true  # Level 2+: Access local information networks
		can_receive_missions = true  # Level 2+: Receive missions from NPCs
	else:
		can_access_networks = false
		can_receive_missions = false

	if new_level >= 3:
		unlocks_diplomacy = true  # Level 3+: Diplomacy as alternative to combat
	else:
		unlocks_diplomacy = false

	if new_level >= 4:
		is_instant = true  # Level 4+: Instant communication (quantum entanglement)
		cannot_be_intercepted = true  # Level 4+: Cannot be jammed or intercepted
		can_access_classified = true  # Level 4+: Access classified information networks
	else:
		is_instant = false
		cannot_be_intercepted = false
		can_access_classified = false

	if new_level == 5:
		has_telepathy = true  # Level 5: Telepathic communication with psionic species
		can_detect_lies = false  # Level 5: Sense emotions and intentions (detect lies/hostility)
		unlocks_hidden_dialogue = true  # Level 5: Unlock hidden dialogue options
		can_communicate_nonverbal = true  # Level 5: Communicate with non-verbal life forms
	else:
		has_telepathy = false
		can_detect_lies = false
		unlocks_hidden_dialogue = false
		can_communicate_nonverbal = false

	# Update GameState communications values
	_update_game_state_communications()

	if new_level > 0:
		print("Communications upgraded to Level %d: %s range, +%.0f%% diplomacy" % [
			level,
			comm_range,
			diplomacy_bonus * 100
		])

## Get current communication range description
func get_comm_range() -> String:
	return comm_range

## Get communication range in light years (for comparison)
func get_comm_range_ly() -> float:
	if not active:
		return 0.0
	return comm_range_ly

## Get translation capability description
func get_translation_capability() -> String:
	if translation_capability == 0:
		return "None"
	elif translation_capability >= 999999:
		return "All known species"
	else:
		return "%d languages" % translation_capability

## Get encryption strength (0-5)
func get_encryption_strength() -> int:
	return encryption_strength

## Get diplomacy bonus as percentage (0-100)
func get_diplomacy_bonus_percent() -> float:
	return diplomacy_bonus * 100.0

## Check if can receive distress signals (Level 1+)
func can_receive_distress_signals() -> bool:
	return can_receive_distress

## Check if can access information networks (Level 2+)
func can_access_information_networks() -> bool:
	return can_access_networks

## Check if can receive NPC missions (Level 2+)
func can_receive_npc_missions() -> bool:
	return can_receive_missions

## Check if diplomacy is unlocked (Level 3+)
func is_diplomacy_unlocked() -> bool:
	return unlocks_diplomacy

## Check if has instant communication (Level 4+)
func has_instant_communication() -> bool:
	return is_instant

## Check if communication cannot be intercepted (Level 4+)
func is_secure_communication() -> bool:
	return cannot_be_intercepted

## Check if can access classified networks (Level 4+)
func can_access_classified_networks() -> bool:
	return can_access_classified

## Check if has telepathic capability (Level 5)
func has_telepathic_communication() -> bool:
	return has_telepathy

## Check if can detect lies/emotions (Level 5)
func can_detect_deception() -> bool:
	return can_detect_lies

## Check if has hidden dialogue options (Level 5)
func has_hidden_dialogue_options() -> bool:
	return unlocks_hidden_dialogue

## Check if can communicate with non-verbal species (Level 5)
func can_communicate_with_nonverbal_species() -> bool:
	return can_communicate_nonverbal

## Update GameState with current communications values
func _update_game_state_communications() -> void:
	# Update system data in GameState
	GameState.ship.systems.communications.level = level
	GameState.ship.systems.communications.health = health
	GameState.ship.systems.communications.max_health = max_health
	GameState.ship.systems.communications.active = active

	# Recalculate ship power stats (communications consume power)
	GameState._recalculate_ship_stats()

## Override to_dict to include communications-specific data
func to_dict() -> Dictionary:
	var data = super.to_dict()
	data["comm_range"] = comm_range
	data["comm_range_ly"] = comm_range_ly
	data["translation_capability"] = translation_capability
	data["encryption_strength"] = encryption_strength
	data["diplomacy_bonus"] = diplomacy_bonus
	data["can_receive_distress"] = can_receive_distress
	data["can_access_networks"] = can_access_networks
	data["can_receive_missions"] = can_receive_missions
	data["unlocks_diplomacy"] = unlocks_diplomacy
	data["is_instant"] = is_instant
	data["cannot_be_intercepted"] = cannot_be_intercepted
	data["can_access_classified"] = can_access_classified
	data["has_telepathy"] = has_telepathy
	data["can_detect_lies"] = can_detect_lies
	data["unlocks_hidden_dialogue"] = unlocks_hidden_dialogue
	data["can_communicate_nonverbal"] = can_communicate_nonverbal
	return data

## Override from_dict to load communications-specific data
func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	comm_range = data.get("comm_range", "none")
	comm_range_ly = data.get("comm_range_ly", 0.0)
	translation_capability = data.get("translation_capability", 0)
	encryption_strength = data.get("encryption_strength", 0)
	diplomacy_bonus = data.get("diplomacy_bonus", 0.0)
	can_receive_distress = data.get("can_receive_distress", false)
	can_access_networks = data.get("can_access_networks", false)
	can_receive_missions = data.get("can_receive_missions", false)
	unlocks_diplomacy = data.get("unlocks_diplomacy", false)
	is_instant = data.get("is_instant", false)
	cannot_be_intercepted = data.get("cannot_be_intercepted", false)
	can_access_classified = data.get("can_access_classified", false)
	has_telepathy = data.get("has_telepathy", false)
	can_detect_lies = data.get("can_detect_lies", false)
	unlocks_hidden_dialogue = data.get("unlocks_hidden_dialogue", false)
	can_communicate_nonverbal = data.get("can_communicate_nonverbal", false)

## Get detailed stats as string
func get_stats_string() -> String:
	if level == 0:
		return "Communications not installed\nCannot communicate"

	var stats = "Range: %s\n" % comm_range.capitalize()
	stats += "Translation: %s\n" % get_translation_capability()
	stats += "Encryption: Level %d\n" % encryption_strength

	if diplomacy_bonus > 0.0:
		stats += "Diplomacy Bonus: +%.0f%%\n" % (diplomacy_bonus * 100)

	stats += "Power Cost: %d PU\n" % get_power_cost()

	if level >= 1:
		stats += "\nSpecial Abilities:\n"
		if can_receive_distress:
			stats += "  • Receive distress signals\n"
		if can_access_networks:
			stats += "  • Access information networks\n"
		if can_receive_missions:
			stats += "  • Receive NPC missions\n"
		if unlocks_diplomacy:
			stats += "  • Diplomacy (alternative to combat)\n"
		if is_instant:
			stats += "  • Instant communication (no delay)\n"
		if cannot_be_intercepted:
			stats += "  • Cannot be intercepted/jammed\n"
		if can_access_classified:
			stats += "  • Access classified networks\n"
		if has_telepathy:
			stats += "  • Telepathic communication\n"
		if can_detect_lies:
			stats += "  • Detect lies and emotions\n"
		if unlocks_hidden_dialogue:
			stats += "  • Unlock hidden dialogue options\n"
		if can_communicate_nonverbal:
			stats += "  • Communicate with non-verbal life\n"

	stats += "\nStatus: %s" % get_status()

	return stats

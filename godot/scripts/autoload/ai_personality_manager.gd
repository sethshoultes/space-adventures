extends Node

## AIPersonalityManager Singleton
## Manages multiple active AI personalities and their interactions
## Coordinates UI state transitions for Magentic-style adaptive interface

# UI States
enum UIState {
	NARRATIVE_FOCUS,      # Mission story primary (default)
	AI_INTERJECTION,      # One AI speaking/offering input
	MULTI_AI_DISCUSSION,  # Multiple AIs conversing
	PLAYER_AI_CHAT,       # Direct player-AI conversation
	COMBAT_COMPRESSED     # Combat mode (minimal UI)
}

# AI Personality data structure
class AIPersonality:
	var name: String
	var display_name: String
	var active: bool = false
	var presence: float = 0.0  # 0.0 = quiet, 1.0 = prominent
	var state: String = "quiet"  # quiet, speaking, listening, inactive
	var color: Color = Color.WHITE
	var description: String = ""

	func _init(p_name: String, p_display: String, p_color: Color, p_desc: String):
		name = p_name
		display_name = p_display
		color = p_color
		description = p_desc

# Available AI personalities
var personalities: Dictionary = {}

# Current UI state
var current_state: UIState = UIState.NARRATIVE_FOCUS
var previous_state: UIState = UIState.NARRATIVE_FOCUS

# Active interjection
var current_interjection: Dictionary = {}

# Signals
signal ui_state_changed(new_state: UIState, old_state: UIState)
signal ai_interjection_triggered(personality: String, message: String, context: Dictionary)
signal ai_discussion_started(participants: Array, topic: String)
signal ai_conversation_started(personality: String)

func _ready() -> void:
	print("AIPersonalityManager initialized")
	_initialize_personalities()

func _initialize_personalities() -> void:
	"""Initialize all available AI personalities"""

	# ATLAS - Ship Computer (Technical, Factual)
	personalities["atlas"] = AIPersonality.new(
		"atlas",
		"ATLAS",
		Color(0.4, 0.7, 1.0),  # Blue
		"Ship's AI - Technical data, scans, navigation"
	)

	# Companion - Crew/Friend (Emotional, Supportive)
	personalities["companion"] = AIPersonality.new(
		"companion",
		"Companion",
		Color(0.9, 0.6, 0.3),  # Orange
		"Your friend - Emotional support, moral guidance"
	)

	# MENTOR - Strategic AI (Tactical, Analytical)
	personalities["mentor"] = AIPersonality.new(
		"mentor",
		"MENTOR",
		Color(0.5, 0.9, 0.5),  # Green
		"Strategic advisor - Planning, risk assessment"
	)

	# CHIEF - Engineering AI (Technical, Solutions)
	personalities["chief"] = AIPersonality.new(
		"chief",
		"CHIEF",
		Color(0.9, 0.7, 0.2),  # Yellow
		"Engineering expert - Systems, repairs, diagnostics"
	)

	# ATLAS active by default (ship computer always present)
	activate_ai("atlas", 0.2)

	print("AIPersonalityManager: Initialized %d personalities" % personalities.size())

## Activate an AI personality
func activate_ai(personality_name: String, presence_level: float = 0.5) -> bool:
	if not personalities.has(personality_name):
		push_error("AIPersonalityManager: Unknown personality: " + personality_name)
		return false

	var ai = personalities[personality_name]
	ai.active = true
	ai.presence = clamp(presence_level, 0.0, 1.0)
	ai.state = "quiet" if presence_level < 0.5 else "listening"

	print("AIPersonalityManager: Activated %s (presence: %.1f)" % [ai.display_name, ai.presence])
	return true

## Deactivate an AI personality
func deactivate_ai(personality_name: String) -> void:
	if not personalities.has(personality_name):
		return

	var ai = personalities[personality_name]
	ai.active = false
	ai.presence = 0.0
	ai.state = "inactive"

	print("AIPersonalityManager: Deactivated %s" % ai.display_name)

## Get active AI personalities
func get_active_ais() -> Array:
	var active = []
	for personality_name in personalities:
		var ai = personalities[personality_name]
		if ai.active:
			active.append(personality_name)
	return active

## AI offers input/interjection during mission
func ai_interject(personality_name: String, message: String, context: Dictionary = {}) -> void:
	if not personalities.has(personality_name):
		push_error("AIPersonalityManager: Unknown personality for interjection: " + personality_name)
		return

	var ai = personalities[personality_name]

	# Build interjection data
	current_interjection = {
		"personality": personality_name,
		"display_name": ai.display_name,
		"message": message,
		"color": ai.color,
		"context": context,
		"timestamp": Time.get_ticks_msec()
	}

	# Change UI state
	transition_ui_state(UIState.AI_INTERJECTION)

	# Emit signal for UI to handle
	ai_interjection_triggered.emit(personality_name, message, context)

	print("AIPersonalityManager: %s interjected: %s" % [ai.display_name, message])

## Start multi-AI discussion
func start_ai_discussion(participants: Array, topic: String = "") -> void:
	# Validate participants
	var valid_participants = []
	for p_name in participants:
		if personalities.has(p_name):
			valid_participants.append(p_name)

	if valid_participants.size() < 2:
		push_error("AIPersonalityManager: Need at least 2 valid AIs for discussion")
		return

	# Activate all participants
	for p_name in valid_participants:
		activate_ai(p_name, 0.8)

	# Transition to discussion state
	transition_ui_state(UIState.MULTI_AI_DISCUSSION)

	# Emit signal
	ai_discussion_started.emit(valid_participants, topic)

	print("AIPersonalityManager: Started discussion with %d AIs: %s" % [valid_participants.size(), topic])

## Start direct conversation with an AI
func start_conversation(personality_name: String) -> void:
	if not personalities.has(personality_name):
		push_error("AIPersonalityManager: Unknown personality for conversation: " + personality_name)
		return

	activate_ai(personality_name, 1.0)
	transition_ui_state(UIState.PLAYER_AI_CHAT)
	ai_conversation_started.emit(personality_name)

	print("AIPersonalityManager: Started conversation with %s" % personalities[personality_name].display_name)

## Transition UI state with animation support
func transition_ui_state(new_state: UIState, duration: float = 0.3) -> void:
	if new_state == current_state:
		return

	previous_state = current_state
	current_state = new_state

	ui_state_changed.emit(new_state, previous_state)

	print("AIPersonalityManager: UI state changed: %s → %s" % [
		_state_to_string(previous_state),
		_state_to_string(new_state)
	])

## Return to previous UI state
func return_to_previous_state() -> void:
	transition_ui_state(previous_state)

## Return to narrative focus (default state)
func return_to_narrative() -> void:
	transition_ui_state(UIState.NARRATIVE_FOCUS)

## Get current UI state
func get_current_state() -> UIState:
	return current_state

## Get current interjection data
func get_current_interjection() -> Dictionary:
	return current_interjection

## Clear current interjection
func clear_interjection() -> void:
	current_interjection = {}
	if current_state == UIState.AI_INTERJECTION:
		return_to_narrative()

## Check if AI should interject based on context
func should_ai_interject(personality_name: String, context: Dictionary) -> bool:
	if not personalities.has(personality_name):
		return false

	var ai = personalities[personality_name]
	if not ai.active:
		return false

	# Context-based interjection rules
	match personality_name:
		"atlas":
			# ATLAS interjects for technical/scan opportunities
			if context.has("scan_available") or context.has("technical_info"):
				return randf() > 0.3  # 70% chance

		"companion":
			# Companion reacts to moral/emotional moments
			if context.has("moral_dilemma") or context.has("risk_to_player"):
				return randf() > 0.4  # 60% chance

		"mentor":
			# MENTOR offers strategic advice
			if context.has("strategic_choice") or context.has("tactical_situation"):
				return randf() > 0.5  # 50% chance

		"chief":
			# CHIEF comments on technical/engineering matters
			if context.has("system_issue") or context.has("repair_needed"):
				return randf() > 0.4  # 60% chance

	return false

## Generate AI interjection message based on context
func generate_interjection_message(personality_name: String, context: Dictionary) -> String:
	# This would ideally call AIService, but for now use templates
	match personality_name:
		"atlas":
			if context.has("scan_available"):
				return "Captain, I can perform a detailed scan of this area. Shall I proceed?"
			elif context.has("technical_info"):
				return "I have relevant technical data that may assist your decision."

		"companion":
			if context.has("moral_dilemma"):
				return "This feels wrong. Are you sure about this?"
			elif context.has("risk_to_player"):
				return "Be careful. I have a bad feeling about this."

		"mentor":
			if context.has("strategic_choice"):
				return "Consider the strategic implications before deciding."
			elif context.has("tactical_situation"):
				return "Tactically speaking, we have several options here."

		"chief":
			if context.has("system_issue"):
				return "I'm detecting a system anomaly. I can provide a detailed analysis."
			elif context.has("repair_needed"):
				return "Those systems need immediate attention. Want me to prioritize repairs?"

	return "I have something to add, if you're interested."

## Helper: Convert state enum to string
func _state_to_string(state: UIState) -> String:
	match state:
		UIState.NARRATIVE_FOCUS: return "NARRATIVE_FOCUS"
		UIState.AI_INTERJECTION: return "AI_INTERJECTION"
		UIState.MULTI_AI_DISCUSSION: return "MULTI_AI_DISCUSSION"
		UIState.PLAYER_AI_CHAT: return "PLAYER_AI_CHAT"
		UIState.COMBAT_COMPRESSED: return "COMBAT_COMPRESSED"
	return "UNKNOWN"

## Get personality data
func get_personality(personality_name: String) -> AIPersonality:
	return personalities.get(personality_name)

## Get all personalities
func get_all_personalities() -> Dictionary:
	return personalities

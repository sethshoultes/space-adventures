extends Node

## AdaptiveLayoutManager Singleton
## Calculates and manages adaptive layout configurations
## Handles smooth transitions between layout states

# Layout configuration
var current_layout: Dictionary = {}
var target_layout: Dictionary = {}
var is_transitioning: bool = false

# Default layout weights
const DEFAULT_WEIGHTS = {
	"narrative": 1.0,
	"ai_panel_base": 0.3,
	"transition_duration": 0.4
}

# Signals
signal layout_changed(new_layout: Dictionary)
signal transition_started(from_layout: Dictionary, to_layout: Dictionary)
signal transition_completed()

func _ready() -> void:
	print("AdaptiveLayoutManager initialized")
	_initialize_default_layout()

func _initialize_default_layout() -> void:
	"""Initialize default layout configuration"""
	current_layout = _calculate_narrative_focus_layout()

## Calculate layout for NARRATIVE_FOCUS state
func _calculate_narrative_focus_layout() -> Dictionary:
	return {
		"state": AIPersonalityManager.UIState.NARRATIVE_FOCUS,
		"narrative": {
			"visible": true,
			"weight": 1.0,
			"size_flags": Control.SIZE_EXPAND_FILL
		},
		"ai_panels": {
			"visible": true,
			"mode": "minimized",  # Icons only
			"layout": "horizontal_bottom",
			"size": Vector2(80, 80)  # Per panel
		},
		"choices": {
			"visible": true,
			"position": "below_narrative"
		}
	}

## Calculate layout for AI_INTERJECTION state
func _calculate_ai_interjection_layout(personality: String) -> Dictionary:
	return {
		"state": AIPersonalityManager.UIState.AI_INTERJECTION,
		"narrative": {
			"visible": true,
			"weight": 0.5,  # Compressed to 50%
			"size_flags": Control.SIZE_EXPAND_FILL
		},
		"ai_interjection_panel": {
			"visible": true,
			"personality": personality,
			"weight": 0.5,
			"position": "right",  # Slides in from right
			"size_flags": Control.SIZE_EXPAND_FILL
		},
		"ai_panels": {
			"visible": true,
			"mode": "minimized",
			"layout": "horizontal_bottom",
			"highlight": personality  # Highlight active AI
		},
		"choices": {
			"visible": false  # Hidden during interjection
		}
	}

## Calculate layout for MULTI_AI_DISCUSSION state
func _calculate_multi_ai_discussion_layout(participants: Array) -> Dictionary:
	var panel_count = participants.size()
	var panel_weight = 0.7 / panel_count  # Split 70% among AIs

	var ai_panel_configs = []
	for p in participants:
		ai_panel_configs.append({
			"personality": p,
			"weight": panel_weight,
			"visible": true,
			"mode": "expanded"
		})

	return {
		"state": AIPersonalityManager.UIState.MULTI_AI_DISCUSSION,
		"narrative": {
			"visible": true,
			"weight": 0.3,  # Compressed to 30%
			"mode": "context_only"  # Just context summary
		},
		"ai_discussion_panels": ai_panel_configs,
		"choices": {
			"visible": true,
			"mode": "compact",
			"position": "bottom"
		}
	}

## Calculate layout for PLAYER_AI_CHAT state
func _calculate_player_ai_chat_layout(personality: String) -> Dictionary:
	return {
		"state": AIPersonalityManager.UIState.PLAYER_AI_CHAT,
		"narrative": {
			"visible": false  # Hidden during direct chat
		},
		"ai_chat_panel": {
			"visible": true,
			"personality": personality,
			"weight": 1.0,  # Full screen
			"mode": "conversation",
			"features": ["chat_history", "text_input", "quick_questions"]
		},
		"ai_panels": {
			"visible": false  # Hidden in chat mode
		},
		"choices": {
			"visible": false
		}
	}

## Calculate optimal layout based on UI state
func calculate_layout_for_state(ui_state: int, context: Dictionary = {}) -> Dictionary:
	match ui_state:
		AIPersonalityManager.UIState.NARRATIVE_FOCUS:
			return _calculate_narrative_focus_layout()

		AIPersonalityManager.UIState.AI_INTERJECTION:
			var personality = context.get("personality", "atlas")
			return _calculate_ai_interjection_layout(personality)

		AIPersonalityManager.UIState.MULTI_AI_DISCUSSION:
			var participants = context.get("participants", ["atlas", "companion"])
			return _calculate_multi_ai_discussion_layout(participants)

		AIPersonalityManager.UIState.PLAYER_AI_CHAT:
			var personality = context.get("personality", "atlas")
			return _calculate_player_ai_chat_layout(personality)

		AIPersonalityManager.UIState.COMBAT_COMPRESSED:
			# TODO: Implement combat layout
			return _calculate_narrative_focus_layout()

	return current_layout

## Request layout transition
func transition_to_state(ui_state: int, context: Dictionary = {}, duration: float = 0.4) -> void:
	if is_transitioning:
		print("AdaptiveLayoutManager: Already transitioning, queuing request")
		return

	target_layout = calculate_layout_for_state(ui_state, context)

	if target_layout == current_layout:
		return

	is_transitioning = true
	transition_started.emit(current_layout, target_layout)

	# Perform transition (actual animation handled by UI components)
	await get_tree().create_timer(duration).timeout

	current_layout = target_layout
	is_transitioning = false

	layout_changed.emit(current_layout)
	transition_completed.emit()

	print("AdaptiveLayoutManager: Transitioned to state: %s" % target_layout.get("state"))

## Get current layout
func get_current_layout() -> Dictionary:
	return current_layout

## Check if specific element is visible in current layout
func is_element_visible(element_name: String) -> bool:
	if not current_layout.has(element_name):
		return false
	var element = current_layout[element_name]
	return element.get("visible", false)

## Get element configuration
func get_element_config(element_name: String) -> Dictionary:
	return current_layout.get(element_name, {})

## Optimize space allocation for elements
func optimize_space(available_rect: Rect2, elements: Array) -> Dictionary:
	"""Calculate optimal sizes and positions for elements"""

	var total_weight = 0.0
	for element in elements:
		total_weight += element.get("weight", 1.0)

	var allocations = {}
	var current_y = available_rect.position.y

	for element in elements:
		var weight = element.get("weight", 1.0)
		var height = (available_rect.size.y * weight) / total_weight

		allocations[element.name] = Rect2(
			available_rect.position.x,
			current_y,
			available_rect.size.x,
			height
		)

		current_y += height

	return allocations

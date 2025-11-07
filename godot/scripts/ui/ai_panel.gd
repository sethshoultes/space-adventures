extends PanelContainer

## AIPanel Component
## Displays AI personality interjections and conversations
## Morphs between different states (quiet, speaking, listening)

# UI References
@onready var personality_name_label: Label = $MarginContainer/VBoxContainer/Header/PersonalityName
@onready var state_indicator: Label = $MarginContainer/VBoxContainer/Header/StateIndicator
@onready var message_label: RichTextLabel = $MarginContainer/VBoxContainer/Message
@onready var actions_container: HBoxContainer = $MarginContainer/VBoxContainer/Actions
@onready var dismiss_button: Button = $MarginContainer/VBoxContainer/Actions/DismissButton
@onready var ask_more_button: Button = $MarginContainer/VBoxContainer/Actions/AskMoreButton

# Properties
@export var personality_name: String = "atlas"
@export var personality_color: Color = Color(0.4, 0.7, 1.0)

var current_state: String = "quiet"  # quiet, speaking, listening, inactive
var interjection_data: Dictionary = {}

# Signals
signal dismissed()
signal ask_more_pressed()

func _ready() -> void:
	# Start hidden
	modulate.a = 0.0
	visible = false

## Display an AI interjection
func show_interjection(data: Dictionary) -> void:
	interjection_data = data

	# Set personality info
	personality_name = data.get("personality", "atlas")
	var personality = AIPersonalityManager.get_personality(personality_name)

	if personality:
		personality_name_label.text = personality.display_name
		personality_color = personality.color

		# Apply color theme
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = personality_color
		style.bg_color.a = 0.3  # Semi-transparent
		add_theme_stylebox_override("panel", style)

	# Set message
	var message = data.get("message", "")
	message_label.text = "[color=#%s]%s[/color]" % [personality_color.to_html(false), message]

	# Set state
	current_state = "speaking"
	state_indicator.text = "[SPEAKING]"
	state_indicator.modulate = personality_color

	# Show actions
	actions_container.visible = true

	# Animate in
	_animate_show()

## Hide/dismiss the interjection
func hide_interjection() -> void:
	_animate_hide()

## Animate panel appearing
func _animate_show() -> void:
	visible = true

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

	# Slide in from right
	var start_pos = position
	position.x += 50
	tween.tween_property(self, "position", start_pos, 0.4)

## Animate panel disappearing
func _animate_hide() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.3)

	# Slide out to right
	var end_pos = position
	end_pos.x += 50
	tween.tween_property(self, "position", end_pos, 0.3)

	await tween.finished
	visible = false

## Set state (quiet, speaking, listening, inactive)
func set_panel_state(new_state: String) -> void:
	current_state = new_state

	match new_state:
		"quiet":
			state_indicator.text = "[QUIET]"
			state_indicator.modulate = Color.GRAY
			actions_container.visible = false

		"speaking":
			state_indicator.text = "[SPEAKING]"
			state_indicator.modulate = personality_color
			actions_container.visible = true

		"listening":
			state_indicator.text = "[LISTENING]"
			state_indicator.modulate = Color.WHITE
			actions_container.visible = false

		"inactive":
			visible = false

## Button handlers
func _on_dismiss_pressed() -> void:
	hide_interjection()
	dismissed.emit()

	# Clear interjection in manager
	AIPersonalityManager.clear_interjection()

func _on_ask_more_pressed() -> void:
	ask_more_pressed.emit()

	# This could trigger a full conversation
	# AIPersonalityManager.start_conversation(personality_name)

	print("AIPanel: Player wants to ask %s more" % personality_name)

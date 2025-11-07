extends Control

## Mission Scene Controller
## Handles mission playback, displaying stages, and player choices
## Integrates with AIPersonalityManager for adaptive UI and AI interjections

# UI References - Updated for MainLayout/NarrativeContainer structure
@onready var narrative_container: MarginContainer = $MainLayout/NarrativeContainer
@onready var ai_panel: PanelContainer = $MainLayout/AIInterjectionPanel
@onready var mission_title: Label = $MainLayout/NarrativeContainer/VBoxContainer/Header/MissionTitle
@onready var location_label: Label = $MainLayout/NarrativeContainer/VBoxContainer/Header/Location
@onready var stage_title: Label = $MainLayout/NarrativeContainer/VBoxContainer/StageContent/StageText/StageTitle
@onready var description: RichTextLabel = $MainLayout/NarrativeContainer/VBoxContainer/StageContent/StageText/Description
@onready var result_text: RichTextLabel = $MainLayout/NarrativeContainer/VBoxContainer/StageContent/StageText/ResultText
@onready var choices_label: Label = $MainLayout/NarrativeContainer/VBoxContainer/ChoicesLabel
@onready var choice_buttons: Array = [
	$MainLayout/NarrativeContainer/VBoxContainer/Choices/Choice1,
	$MainLayout/NarrativeContainer/VBoxContainer/Choices/Choice2,
	$MainLayout/NarrativeContainer/VBoxContainer/Choices/Choice3,
	$MainLayout/NarrativeContainer/VBoxContainer/Choices/Choice4
]
@onready var exit_button: Button = $MainLayout/NarrativeContainer/VBoxContainer/Actions/ExitButton

# Current state
var current_choices: Array = []
var ai_panel_visible: bool = false

func _ready() -> void:
	print("Mission scene initialized")

	# Connect to AIPersonalityManager signals
	AIPersonalityManager.ai_interjection_triggered.connect(_on_ai_interjection_triggered)
	AIPersonalityManager.ui_state_changed.connect(_on_ui_state_changed)

	# Set initial UI state to NARRATIVE_FOCUS
	AIPersonalityManager.transition_ui_state(AIPersonalityManager.UIState.NARRATIVE_FOCUS)

	# Check if there's an active mission
	if not MissionManager.is_mission_active():
		push_error("Mission: No active mission found")
		EventBus.show_error.emit("Mission Error", "No mission loaded")
		_return_to_menu()
		return

	# Load mission header
	var mission = MissionManager.get_active_mission()
	mission_title.text = mission.title
	location_label.text = mission.get("location", "Unknown Location")

	# Load first stage
	_load_current_stage()

func _load_current_stage() -> void:
	"""Load and display the current mission stage"""

	var stage = MissionManager.get_current_stage()
	if stage.is_empty():
		push_error("Mission: Failed to load current stage")
		_return_to_menu()
		return

	# Display stage info
	stage_title.text = stage.get("title", "")
	description.text = stage.get("description", "")

	# Keep result text visible for continuity, let it fade naturally
	# (Will be hidden on next choice)

	# Load choices
	current_choices = stage.get("choices", [])
	_display_choices()

	print("Mission: Loaded stage '%s' with %d choices" % [stage.get("stage_id", ""), current_choices.size()])

	# Check for AI interjection triggers
	_check_ai_interjections(stage)

func _display_choices() -> void:
	"""Display available choices for current stage"""

	# Hide all choice buttons first
	for button in choice_buttons:
		button.visible = false

	# Show and configure available choices
	for i in range(min(current_choices.size(), choice_buttons.size())):
		var choice = current_choices[i]
		var button = choice_buttons[i]

		# Set button text
		button.text = choice.get("text", "Choice %d" % (i + 1))

		# Check if choice is available (requirements met)
		if _check_choice_requirements(choice):
			button.disabled = false
			button.visible = true
		else:
			# Show but disabled if requirements not met
			button.text += " [LOCKED]"
			button.disabled = true
			button.visible = true

	# Show choices section
	choices_label.visible = current_choices.size() > 0

func _check_choice_requirements(choice: Dictionary) -> bool:
	"""Check if player meets requirements for a choice"""

	if not choice.has("requirements"):
		return true

	var reqs = choice.requirements

	# Check skill requirement
	if reqs.has("skill") and reqs.has("skill_level"):
		var skill_name = reqs.skill
		var required_level = reqs.skill_level
		var player_skill = GameState.player.skills.get(skill_name, 0)

		if player_skill < required_level:
			return false

	# Check system requirements
	if reqs.has("system") and reqs.has("system_level"):
		var system_name = reqs.system
		var required_level = reqs.system_level
		var system_level = GameState.ship.systems.get(system_name, {}).get("level", 0)

		if system_level < required_level:
			return false

	return true

func _on_choice_pressed(choice_index: int) -> void:
	"""Handle player choice selection"""

	if choice_index < 0 or choice_index >= current_choices.size():
		push_error("Mission: Invalid choice index: %d" % choice_index)
		return

	var choice = current_choices[choice_index]
	print("Mission: Player chose: %s" % choice.get("text", ""))

	# Hide previous result text (if any)
	result_text.visible = false

	# Disable all choice buttons
	for button in choice_buttons:
		button.disabled = true

	# Process choice through MissionManager
	var result = MissionManager.make_choice(choice.choice_id)

	if result.is_empty():
		push_error("Mission: Failed to process choice")
		return

	# Display result
	_display_result(result)

func _display_result(result: Dictionary) -> void:
	"""Display the result of a choice"""

	var consequence = result.get("consequence", {})
	var result_message = consequence.get("text", "")

	# Show result text
	if result_message != "":
		result_text.text = "[i]%s[/i]" % result_message
		result_text.visible = true

	# Check if mission continues or ends
	if consequence.has("next_stage"):
		# Continue to next stage automatically after delay
		choices_label.visible = false
		await get_tree().create_timer(2.0).timeout
		_load_current_stage()

	elif consequence.has("mission_complete") or consequence.get("mission_complete", false):
		# Mission completed
		_show_mission_complete()

	elif consequence.has("mission_failed"):
		# Mission failed
		_show_mission_failed(consequence.get("reason", "Mission failed"))

	else:
		# No next stage specified - assume mission complete
		_show_mission_complete()

func _show_mission_complete() -> void:
	"""Show mission completion screen"""

	var mission = MissionManager.get_active_mission()

	result_text.text = "[b][color=green]MISSION COMPLETE[/color][/b]\n\n"
	result_text.text += "You have successfully completed: %s\n\n" % mission.title

	# Show rewards
	if mission.has("rewards"):
		result_text.text += "[b]Rewards:[/b]\n"

		if mission.rewards.has("xp"):
			result_text.text += "• %d XP\n" % mission.rewards.xp

		if mission.rewards.has("items"):
			for item_id in mission.rewards.items:
				result_text.text += "• %s\n" % _format_item_name(item_id)

	result_text.visible = true
	choices_label.visible = false

	# Hide all choice buttons
	for button in choice_buttons:
		button.visible = false

	# Show exit button prominently
	exit_button.text = "RETURN TO WORKSHOP"

	print("Mission: Mission completed successfully")

func _show_mission_failed(reason: String) -> void:
	"""Show mission failure screen"""

	result_text.text = "[b][color=red]MISSION FAILED[/color][/b]\n\n"
	result_text.text += reason
	result_text.visible = true
	choices_label.visible = false

	# Hide all choice buttons
	for button in choice_buttons:
		button.visible = false

	# Show exit button
	exit_button.text = "RETURN TO WORKSHOP"

	print("Mission: Mission failed - %s" % reason)

func _format_item_name(item_id: String) -> String:
	"""Format item ID into readable name"""

	if item_id.begins_with("hull_system_"):
		var level = item_id.substr(-1)
		return "Hull System Level %s" % level
	elif item_id.begins_with("power_core_"):
		var level = item_id.substr(-1)
		return "Power Core Level %s" % level
	elif item_id.begins_with("propulsion_system_"):
		var level = item_id.substr(-1)
		return "Propulsion System Level %s" % level
	else:
		return item_id.replace("_", " ").capitalize()

func _on_exit_pressed() -> void:
	"""Exit mission and return to main menu/workshop"""

	print("Mission: Exiting mission")
	_return_to_menu()

func _return_to_menu() -> void:
	"""Return to workshop or main menu"""

	# Save game before returning
	SaveManager.auto_save()

	# Return to workshop (where missions are launched from)
	get_tree().change_scene_to_file("res://scenes/workshop.tscn")

func _check_ai_interjections(stage: Dictionary) -> void:
	"""Check if this stage triggers any AI interjections"""

	var stage_id = stage.get("stage_id", "")
	var mission = MissionManager.get_active_mission()
	var effects = MissionManager.mission_effects

	# Tutorial mission: ATLAS interjections
	if mission.mission_id == "tutorial_first_salvage":
		_trigger_tutorial_interjections(stage_id, effects)

func _trigger_tutorial_interjections(stage_id: String, effects: Array) -> void:
	"""Trigger ATLAS commentary for tutorial mission"""

	match stage_id:
		"arrival":
			# ATLAS comments on the museum's active power systems
			await get_tree().create_timer(2.0).timeout
			AIPersonalityManager.ai_interject(
				"atlas",
				"Captain, I'm detecting active power signatures from the museum. Solar arrays functioning at 78% efficiency. Interior systems still operational. This facility has remarkable longevity—most pre-exodus infrastructure collapsed decades ago.",
				{"stage": stage_id, "type": "technical_observation"}
			)

		"workshop_contested":
			# ATLAS analyzes the scavengers
			if "encountered_scavengers" in effects:
				await get_tree().create_timer(1.5).timeout
				AIPersonalityManager.ai_interject(
					"atlas",
					"Bioscan complete. Two humans, armed but showing non-aggressive postures. Plasma cutter: tool, not weapon. Sidearm: defensive carry. Heart rates elevated but not combat-ready. Probability of peaceful resolution: 67%.",
					{"stage": stage_id, "type": "threat_assessment"}
				)

		"workshop_informed":
			# ATLAS provides technical insight on security system
			if "gathered_intel" in effects:
				await get_tree().create_timer(1.0).timeout
				AIPersonalityManager.ai_interject(
					"atlas",
					"Security grid analysis: Pre-exodus museum automation, surprisingly intact. If you can access a maintenance terminal, I can interface with their systems. Service robots, door controls, possibly environmental systems. Recommend attempting computer access.",
					{"stage": stage_id, "type": "technical_opportunity"}
				)

		"workshop_open":
			# ATLAS assesses the ship frame
			await get_tree().create_timer(2.5).timeout
			AIPersonalityManager.ai_interject(
				"atlas",
				"Structural scan complete. Ship frame: titanium-aluminum alloy, stress fractures within acceptable parameters. Designed for light exploration. Hull hard points: 10 systems. Power routing: functional. This frame can support Level 3 systems across all categories. Your grandfather chose well.",
				{"stage": stage_id, "type": "ship_analysis"}
			)

		"workshop_claimed":
			# ATLAS confirms systems operational
			await get_tree().create_timer(2.0).timeout
			AIPersonalityManager.ai_interject(
				"atlas",
				"All systems installed successfully. Hull: 50 HP nominal. Power core: 100 PU output steady. Propulsion: thrusters responsive. Computer core: ... that would be me. Welcome aboard, Captain. I've initialized ship protocols. We're ready for your first flight.",
				{"stage": stage_id, "type": "systems_confirmation"}
			)

		"mission_complete":
			# ATLAS celebrates completion
			await get_tree().create_timer(1.0).timeout
			AIPersonalityManager.ai_interject(
				"atlas",
				"Mission complete, Captain. Your grandfather would be proud. Ship classification: Scout, Level 1. Current capabilities: limited. But every starship begins with a single flight. Where shall we go next?",
				{"stage": stage_id, "type": "mission_complete"}
			)

## AI Interjection Handlers

func _on_ai_interjection_triggered(personality: String, message: String, context: Dictionary) -> void:
	"""Handle AI personality interjection during mission"""

	print("Mission: AI interjection from %s: %s" % [personality, message])

	# Show the AI panel with interjection data
	var interjection_data = {
		"personality": personality,
		"message": message,
		"context": context
	}

	ai_panel.show_interjection(interjection_data)
	ai_panel_visible = true

	# Adjust narrative container to 50% width
	_adjust_layout_for_ai_panel(true)

func _on_ai_panel_dismissed() -> void:
	"""Handle AI panel dismissal"""

	print("Mission: AI panel dismissed")
	ai_panel_visible = false

	# Restore narrative container to full width
	_adjust_layout_for_ai_panel(false)

	# Transition back to NARRATIVE_FOCUS
	AIPersonalityManager.transition_ui_state(AIPersonalityManager.UIState.NARRATIVE_FOCUS)

func _on_ui_state_changed(new_state: int, old_state: int) -> void:
	"""Handle UI state changes from AIPersonalityManager"""

	print("Mission: UI state changed from %d to %d" % [old_state, new_state])

	# Adjust layout based on new state
	match new_state:
		AIPersonalityManager.UIState.NARRATIVE_FOCUS:
			_adjust_layout_for_ai_panel(false)

		AIPersonalityManager.UIState.AI_INTERJECTION:
			_adjust_layout_for_ai_panel(true)

		_:
			# Other states not yet implemented
			pass

func _adjust_layout_for_ai_panel(show_panel: bool) -> void:
	"""Adjust the narrative container size to accommodate AI panel"""

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	if show_panel:
		# Compress narrative to 50% width (size_flags_stretch_ratio)
		# Note: HBoxContainer with size_flags_horizontal = 3 means it will shrink
		# when AIPanel becomes visible with its fixed width of 600px
		ai_panel.visible = true
		ai_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tween.tween_property(ai_panel, "custom_minimum_size:x", 600, 0.4)
	else:
		# Restore narrative to full width
		tween.tween_property(ai_panel, "custom_minimum_size:x", 0, 0.4)
		await tween.finished
		ai_panel.visible = false
		ai_panel.size_flags_horizontal = 0

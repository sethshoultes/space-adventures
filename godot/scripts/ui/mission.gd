extends Control

## Mission Scene Controller
## Handles mission playback, displaying stages, and player choices

# UI References
@onready var mission_title: Label = $MarginContainer/VBoxContainer/Header/MissionTitle
@onready var location_label: Label = $MarginContainer/VBoxContainer/Header/Location
@onready var stage_title: Label = $MarginContainer/VBoxContainer/StageContent/StageText/StageTitle
@onready var description: RichTextLabel = $MarginContainer/VBoxContainer/StageContent/StageText/Description
@onready var result_text: RichTextLabel = $MarginContainer/VBoxContainer/StageContent/StageText/ResultText
@onready var choices_label: Label = $MarginContainer/VBoxContainer/ChoicesLabel
@onready var choice_buttons: Array = [
	$MarginContainer/VBoxContainer/Choices/Choice1,
	$MarginContainer/VBoxContainer/Choices/Choice2,
	$MarginContainer/VBoxContainer/Choices/Choice3,
	$MarginContainer/VBoxContainer/Choices/Choice4
]
@onready var continue_button: Button = $MarginContainer/VBoxContainer/Actions/ContinueButton
@onready var exit_button: Button = $MarginContainer/VBoxContainer/Actions/ExitButton

# Current state
var current_choices: Array = []
var waiting_for_continue: bool = false

func _ready() -> void:
	print("Mission scene initialized")

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

	# Hide result text
	result_text.visible = false

	# Load choices
	current_choices = stage.get("choices", [])
	_display_choices()

	# Reset continue button
	continue_button.visible = false
	waiting_for_continue = false

	print("Mission: Loaded stage '%s' with %d choices" % [stage.get("stage_id", ""), current_choices.size()])

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
		# Continue to next stage
		waiting_for_continue = true
		continue_button.visible = true
		choices_label.visible = false

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

func _on_continue_pressed() -> void:
	"""Continue to next stage"""

	if not waiting_for_continue:
		return

	print("Mission: Continuing to next stage")
	_load_current_stage()

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

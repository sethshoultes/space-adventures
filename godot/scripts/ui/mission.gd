extends Control

## Mission Scene Controller - Scrolling Narrative Log
## Appends all story content chronologically - nothing disappears
## Three-panel layout: Left (narrative), Top Right (scene image), Bottom Right (ATLAS chat)

# UI References - Narrative Panel (Left)
@onready var narrative_container: MarginContainer = $MainVBox/TopPanels/NarrativeContainer
@onready var mission_title: Label = $MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Header/MissionTitle
@onready var location_label: Label = $MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Header/Location
@onready var narrative_scroll: ScrollContainer = $MainVBox/TopPanels/NarrativeContainer/VBoxContainer/NarrativeScroll
@onready var narrative_log: VBoxContainer = $MainVBox/TopPanels/NarrativeContainer/VBoxContainer/NarrativeScroll/NarrativeLog
@onready var choices_label: Label = $MainVBox/TopPanels/NarrativeContainer/VBoxContainer/ChoicesLabel
@onready var choice_buttons: Array = [
	$MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Choices/Choice1,
	$MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Choices/Choice2,
	$MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Choices/Choice3,
	$MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Choices/Choice4
]
@onready var exit_button: Button = $MainVBox/TopPanels/NarrativeContainer/VBoxContainer/Actions/ExitButton

# UI References - Right Panels
@onready var scene_image: TextureRect = $MainVBox/TopPanels/RightPanels/SceneImagePanel/MarginContainer/VBoxContainer/SceneImage
@onready var atlas_avatar: TextureRect = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/Header/Avatar
@onready var atlas_label: Label = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/Header/ATLASLabel
@onready var agent_selector: OptionButton = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/Header/AgentSelector
@onready var chat_scroll: ScrollContainer = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/ChatScroll
@onready var chat_history: VBoxContainer = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/ChatScroll/ChatHistory

# UI References - Bottom Panels
@onready var atlas_input: LineEdit = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/TextInputContainer/InputField
@onready var send_button: Button = $MainVBox/TopPanels/RightPanels/ATLASChatPanel/MarginContainer/VBoxContainer/TextInputContainer/SendButton
@onready var status_label: Label = $MainVBox/StatusTicker/MarginContainer/ScrollContainer/StatusLabel

# State tracking
var current_choices: Array = []
var current_stage_id: String = ""
var stage_count: int = 0  # For stardate generation
var base_stardate: float = 2247.05  # Starting stardate
var is_first_stage: bool = true  # First stage has no separator
var scroll_indicator: Button = null  # Manual scroll button indicator
var conversation_id: String = ""  # AI orchestrator conversation ID

# AI Chat State
var current_agent: String = "atlas"
const AGENT_NAMES = ["atlas", "storyteller", "tactical", "companion"]

# Autonomous AI agent timers
var atlas_timer: Timer = null
var storyteller_timer: Timer = null
var tactical_timer: Timer = null
var companion_timer: Timer = null

func _ready() -> void:
	print("Mission scene initialized - Three-panel layout mode")

	# Initialize AI conversation
	conversation_id = "mission_" + str(Time.get_ticks_msec())
	print("Mission: AI conversation ID: %s" % conversation_id)

	# Initialize AI agent selector
	current_agent = "atlas"
	agent_selector.selected = 0
	_update_chat_placeholder()

	# Connect AI chat signals
	agent_selector.item_selected.connect(_on_agent_selected)
	atlas_input.text_submitted.connect(_on_atlas_input_submitted)
	send_button.pressed.connect(_on_atlas_send_pressed)

	# Initialize autonomous AI agent timers
	_initialize_agent_timers()

	# Initialize status ticker
	_update_status_ticker()

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
	"""Load and append the current mission stage to narrative log"""

	var stage = MissionManager.get_current_stage()
	if stage.is_empty():
		push_error("Mission: Failed to load current stage")
		_return_to_menu()
		return

	# Update current stage tracking
	current_stage_id = stage.get("stage_id", "")
	stage_count += 1

	# Append stage to narrative log
	_append_stage_to_log(stage)

	# Load choices into fixed choice area
	current_choices = stage.get("choices", [])
	_display_choices()

	print("Mission: Loaded stage '%s' with %d choices" % [current_stage_id, current_choices.size()])

	# Check for AI interjection triggers
	_check_ai_interjections(stage)

func _append_stage_to_log(stage: Dictionary) -> void:
	"""Append a new stage entry to the scrolling narrative log"""

	# Create stage entry container
	var stage_entry = VBoxContainer.new()
	stage_entry.set("theme_override_constants/separation", 15)

	# Add separator with stardate (skip for first stage)
	if not is_first_stage:
		var separator_container = VBoxContainer.new()
		separator_container.set("theme_override_constants/separation", 5)

		# Stardate label
		var stardate_label = Label.new()
		var stardate = _generate_stardate()
		stardate_label.text = "Stardate %s" % stardate
		stardate_label.add_theme_font_size_override("font_size", 16)
		stardate_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1.0))
		stardate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		separator_container.add_child(stardate_label)

		# Horizontal line
		var separator = HSeparator.new()
		separator_container.add_child(separator)

		# Add spacing
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		separator_container.add_child(spacer)

		stage_entry.add_child(separator_container)

	is_first_stage = false

	# Stage title
	var title_label = Label.new()
	title_label.text = stage.get("title", "")
	title_label.add_theme_font_size_override("font_size", 32)
	stage_entry.add_child(title_label)

	# Stage description - check if hybrid or static
	var desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.fit_content = true
	desc_label.scroll_active = false
	desc_label.add_theme_font_size_override("normal_font_size", 20)

	# Check if hybrid stage (has narrative_structure)
	if _is_hybrid_stage(stage):
		# Show loading indicator
		desc_label.text = "[i]Generating narrative...[/i]"
		stage_entry.add_child(desc_label)
		await get_tree().process_frame  # Allow UI to update

		# Generate dynamic narrative
		var narrative = await _generate_stage_narrative(stage)
		desc_label.text = narrative
	else:
		# Static narrative
		desc_label.text = stage.get("description", "")
		stage_entry.add_child(desc_label)

	# Add to narrative log
	narrative_log.add_child(stage_entry)

	# No auto-scroll - let player control pacing
	await get_tree().process_frame

func _append_result_to_log(result_message: String) -> void:
	"""Append result text to the last stage entry and show scroll indicator"""

	if result_message == "":
		return

	# Get last stage entry
	var last_entry = narrative_log.get_child(narrative_log.get_child_count() - 1)

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	last_entry.add_child(spacer)

	# Result label
	var result_label = RichTextLabel.new()
	result_label.bbcode_enabled = true
	result_label.fit_content = true
	result_label.scroll_active = false
	result_label.add_theme_font_size_override("normal_font_size", 18)
	result_label.add_theme_color_override("default_color", Color(0.8, 0.9, 1, 1))
	result_label.text = "[i]%s[/i]" % result_message
	last_entry.add_child(result_label)

	# Add scroll indicator inline
	_add_scroll_indicator(last_entry)

	# No auto-scroll - let player control pacing
	await get_tree().process_frame

func _dim_previous_stages() -> void:
	"""Dim all stages except the last one to 80% opacity"""

	var child_count = narrative_log.get_child_count()
	if child_count <= 1:
		return

	# Dim all but last stage to 80%
	for i in range(child_count - 1):
		var stage_entry = narrative_log.get_child(i)
		stage_entry.modulate.a = 0.8

func _generate_stardate() -> String:
	"""Generate stardate based on stage progression"""
	# Simple placeholder: increment by 0.12 per stage
	var stardate = base_stardate + (stage_count * 0.12)
	return "%.2f" % stardate

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
		var base_text = choice.get("text", "Choice %d" % (i + 1))

		# Check if choice is available (requirements met)
		var requirement_info = _get_requirement_info(choice)

		if requirement_info.met:
			# Requirements met - show normal
			button.text = base_text
			button.disabled = false
			button.visible = true
			button.tooltip_text = ""
		else:
			# Requirements not met - show locked with info
			button.text = base_text + " 🔒"
			button.disabled = true
			button.visible = true
			button.tooltip_text = requirement_info.tooltip

	# Show choices section
	choices_label.visible = current_choices.size() > 0

	# If no choices, check if this is a completion stage
	if current_choices.size() == 0:
		# Mission has ended - trigger completion
		await get_tree().create_timer(0.5).timeout  # Brief pause to read final text
		await _append_mission_complete()

func _get_requirement_info(choice: Dictionary) -> Dictionary:
	"""Get detailed requirement information for a choice
	Returns: {met: bool, tooltip: String}"""

	if not choice.has("requirements"):
		return {"met": true, "tooltip": ""}

	var reqs = choice.requirements
	var requirements_met = true
	var tooltip_parts = []

	# Check skill requirement
	if reqs.has("skill") and reqs.has("skill_level"):
		var skill_name = reqs.skill
		var required_level = reqs.skill_level
		var player_skill = GameState.player.skills.get(skill_name, 0)

		var skill_display = skill_name.capitalize()
		if player_skill < required_level:
			requirements_met = false
			tooltip_parts.append("Requires %s %d (You have: %d)" % [skill_display, required_level, player_skill])
		else:
			tooltip_parts.append("%s %d ✓" % [skill_display, required_level])

	# Check system requirements
	if reqs.has("system") and reqs.has("system_level"):
		var system_name = reqs.system
		var required_level = reqs.system_level
		var system_level = GameState.ship.systems.get(system_name, {}).get("level", 0)

		var system_display = system_name.capitalize()
		if system_level < required_level:
			requirements_met = false
			tooltip_parts.append("Requires %s Level %d (You have: %d)" % [system_display, required_level, system_level])
		else:
			tooltip_parts.append("%s Level %d ✓" % [system_display, required_level])

	var tooltip = "\n".join(tooltip_parts) if tooltip_parts.size() > 0 else ""

	return {"met": requirements_met, "tooltip": tooltip}

func _check_choice_requirements(choice: Dictionary) -> bool:
	"""Check if player meets requirements for a choice"""
	return _get_requirement_info(choice).met

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

	# Check if hybrid choice (has outcome_prompt)
	if _is_hybrid_choice(choice):
		# Generate dynamic outcome via StoryService
		await _handle_hybrid_choice(choice)
	else:
		# Process static choice through MissionManager
		var result = MissionManager.make_choice(choice.choice_id)

		if result.is_empty():
			push_error("Mission: Failed to process choice")
			# Re-enable buttons so player can try again
			for button in choice_buttons:
				button.disabled = false
			return

		# Display result (await because it has async operations)
		await _display_result(result)

func _display_result(result: Dictionary) -> void:
	"""Display the result of a choice"""

	var consequence = result.get("consequence", {})
	var result_message = consequence.get("text", "")

	# Check if mission continues or ends
	if consequence.has("next_stage"):
		# Append result to log
		await _append_result_to_log(result_message)

		# Dim previous stages
		_dim_previous_stages()

		# Hide choices temporarily during transition
		choices_label.visible = false
		for button in choice_buttons:
			button.visible = false

		# Update status ticker
		_update_status_ticker()

		# Short pause for readability
		await get_tree().create_timer(1.0).timeout

		# Load new stage (appends to log)
		_load_current_stage()

	elif consequence.has("mission_complete") or consequence.get("mission_complete", false):
		# Append result if present
		if result_message != "":
			await _append_result_to_log(result_message)
			await get_tree().create_timer(1.0).timeout

		# Append mission complete to log
		await _append_mission_complete()

	elif consequence.has("mission_failed"):
		# Append result if present
		if result_message != "":
			await _append_result_to_log(result_message)
			await get_tree().create_timer(1.0).timeout

		# Append mission failed to log
		await _append_mission_failed(consequence.get("reason", "Mission failed"))

	else:
		# Append result if present
		if result_message != "":
			await _append_result_to_log(result_message)
			await get_tree().create_timer(1.0).timeout

		# No next stage - assume mission complete
		await _append_mission_complete()

func _append_mission_complete() -> void:
	"""Append mission completion message to narrative log"""

	var mission = MissionManager.get_active_mission()

	# If mission is still active in MissionManager, complete it to award rewards
	# (This handles missions that end with a "mission_complete" stage instead of
	#  having "mission_complete": true in the consequence)
	if MissionManager.is_mission_active() and mission.has("mission_id"):
		MissionManager.complete_current_mission()
		print("Mission: Manually completed mission in MissionManager to award rewards")

	# Create completion entry
	var completion_entry = VBoxContainer.new()
	completion_entry.set("theme_override_constants/separation", 15)

	# Separator with stardate
	stage_count += 1
	var separator_container = VBoxContainer.new()
	var stardate_label = Label.new()
	stardate_label.text = "Stardate %s" % _generate_stardate()
	stardate_label.add_theme_font_size_override("font_size", 16)
	stardate_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1.0))
	stardate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separator_container.add_child(stardate_label)
	separator_container.add_child(HSeparator.new())
	completion_entry.add_child(separator_container)

	# Mission complete text
	var complete_label = RichTextLabel.new()
	complete_label.bbcode_enabled = true
	complete_label.fit_content = true
	complete_label.scroll_active = false
	complete_label.add_theme_font_size_override("normal_font_size", 24)

	var text = "[b][color=green]MISSION COMPLETE[/color][/b]\n\n"
	text += "You have successfully completed: %s\n\n" % mission.title

	# Show rewards
	if mission.has("rewards"):
		text += "[b]Rewards:[/b]\n"
		if mission.rewards.has("xp"):
			text += "• +%d XP\n" % mission.rewards.xp
		if mission.rewards.has("credits"):
			text += "• +%d CR\n" % mission.rewards.credits
		if mission.rewards.has("items"):
			for item in mission.rewards.items:
				text += "• %s\n" % _format_item_reward(item)
		if mission.rewards.has("discovered_parts"):
			text += "\n[b]Parts Discovered:[/b]\n"
			for part_id in mission.rewards.discovered_parts:
				var part_data = PartRegistry.get_part(part_id)
				if not part_data.is_empty():
					text += "• [color=yellow]%s[/color]\n" % part_data.name
				else:
					text += "• [color=yellow]%s[/color]\n" % part_id

	complete_label.text = text
	completion_entry.add_child(complete_label)

	narrative_log.add_child(completion_entry)

	# Auto-scroll
	await get_tree().process_frame
	narrative_scroll.scroll_vertical = narrative_scroll.get_v_scroll_bar().max_value

	# Hide choices
	choices_label.visible = false
	for button in choice_buttons:
		button.visible = false

	# Update exit button
	exit_button.text = "RETURN TO WORKSHOP"

	# Update status ticker
	_update_status_ticker()

	print("Mission: Mission completed successfully")

func _append_mission_failed(reason: String) -> void:
	"""Append mission failure message to narrative log"""

	# Create failure entry
	var failure_entry = VBoxContainer.new()
	failure_entry.set("theme_override_constants/separation", 15)

	# Separator with stardate
	stage_count += 1
	var separator_container = VBoxContainer.new()
	var stardate_label = Label.new()
	stardate_label.text = "Stardate %s" % _generate_stardate()
	stardate_label.add_theme_font_size_override("font_size", 16)
	stardate_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1.0))
	stardate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separator_container.add_child(stardate_label)
	separator_container.add_child(HSeparator.new())
	failure_entry.add_child(separator_container)

	# Mission failed text
	var failed_label = RichTextLabel.new()
	failed_label.bbcode_enabled = true
	failed_label.fit_content = true
	failed_label.scroll_active = false
	failed_label.add_theme_font_size_override("normal_font_size", 24)
	failed_label.text = "[b][color=red]MISSION FAILED[/color][/b]\n\n" + reason
	failure_entry.add_child(failed_label)

	narrative_log.add_child(failure_entry)

	# Auto-scroll
	await get_tree().process_frame
	narrative_scroll.scroll_vertical = narrative_scroll.get_v_scroll_bar().max_value

	# Hide choices
	choices_label.visible = false
	for button in choice_buttons:
		button.visible = false

	# Update exit button
	exit_button.text = "RETURN TO WORKSHOP"

	print("Mission: Mission failed - %s" % reason)

func _format_item_name(item_id: String) -> String:
	"""Format item ID into readable name (legacy function)"""

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

func _format_item_reward(item) -> String:
	"""Format item reward (supports both String and Dictionary formats)"""

	if item is String:
		# Old format: item_id as string
		return _format_item_name(item)
	elif item is Dictionary:
		# New format: {part_id: String, quantity: int}
		var part_id = item.get("part_id", item.get("item_id", ""))
		var quantity = item.get("quantity", 1)

		if part_id == "":
			return "Unknown Item"

		# Get part data from PartRegistry
		var part_data = PartRegistry.get_part(part_id)
		if not part_data.is_empty():
			if quantity > 1:
				return "%s x%d" % [part_data.name, quantity]
			else:
				return part_data.name
		else:
			# Fallback to formatting the part_id
			if quantity > 1:
				return "%s x%d" % [_format_item_name(part_id), quantity]
			else:
				return _format_item_name(part_id)
	else:
		return "Unknown Item"

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

## Manual Scroll Pacing System

func _add_scroll_indicator(parent: VBoxContainer) -> void:
	"""Add inline scroll indicator button after result text"""

	# Remove previous indicator if it exists
	if scroll_indicator != null and is_instance_valid(scroll_indicator):
		scroll_indicator.queue_free()
		scroll_indicator = null

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	parent.add_child(spacer)

	# Create scroll indicator button
	scroll_indicator = Button.new()
	scroll_indicator.text = "▼ Scroll Down ▼"
	scroll_indicator.add_theme_font_size_override("font_size", 16)
	scroll_indicator.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 1.0))
	scroll_indicator.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	scroll_indicator.flat = true
	scroll_indicator.custom_minimum_size = Vector2(200, 40)
	scroll_indicator.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# Connect button click
	scroll_indicator.pressed.connect(_on_scroll_indicator_pressed)

	# Add to parent
	parent.add_child(scroll_indicator)

	# Monitor scroll to hide indicator when scrolled past
	_start_scroll_monitoring()

func _on_scroll_indicator_pressed() -> void:
	"""Scroll to next stage when indicator button is clicked"""

	# Smooth scroll to bottom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(narrative_scroll, "scroll_vertical",
		narrative_scroll.get_v_scroll_bar().max_value, 0.5)

	# Hide indicator after scroll
	await tween.finished
	_hide_scroll_indicator()

func _start_scroll_monitoring() -> void:
	"""Monitor scroll position to hide indicator when scrolled past"""

	if scroll_indicator == null or not is_instance_valid(scroll_indicator):
		return

	# Connect to scroll bar changes
	var scroll_bar = narrative_scroll.get_v_scroll_bar()
	if not scroll_bar.value_changed.is_connected(_on_scroll_changed):
		scroll_bar.value_changed.connect(_on_scroll_changed)

func _on_scroll_changed(value: float) -> void:
	"""Hide scroll indicator when player scrolls past it"""

	if scroll_indicator == null or not is_instance_valid(scroll_indicator):
		return

	# Get scroll indicator position
	var indicator_pos = scroll_indicator.global_position.y
	var scroll_bottom = narrative_scroll.global_position.y + narrative_scroll.size.y

	# Hide if indicator is above visible area (scrolled past)
	if indicator_pos < scroll_bottom - 100:  # 100px threshold
		_hide_scroll_indicator()

func _hide_scroll_indicator() -> void:
	"""Remove scroll indicator from UI"""

	if scroll_indicator != null and is_instance_valid(scroll_indicator):
		scroll_indicator.queue_free()
		scroll_indicator = null

func _input(event: InputEvent) -> void:
	"""Handle keyboard input for manual scrolling"""

	# Only handle when indicator is visible
	if scroll_indicator == null or not is_instance_valid(scroll_indicator):
		return

	# Down arrow key triggers scroll
	if event.is_action_pressed("ui_down"):
		_on_scroll_indicator_pressed()
		accept_event()  # Consume the event

## ATLAS Chat System

func _update_chat_placeholder() -> void:
	"""Update message input placeholder based on selected agent"""
	match current_agent:
		"atlas":
			atlas_input.placeholder_text = "Ask ATLAS about ship systems..."
		"storyteller":
			atlas_input.placeholder_text = "Ask Storyteller about missions..."
		"tactical":
			atlas_input.placeholder_text = "Ask Tactical for combat advice..."
		"companion":
			atlas_input.placeholder_text = "Chat with your Companion..."

func _on_agent_selected(index: int) -> void:
	"""Handle agent selection changed"""
	if index >= 0 and index < AGENT_NAMES.size():
		current_agent = AGENT_NAMES[index]
		_update_chat_placeholder()
		print("Mission: Selected agent: %s" % current_agent)

func _get_agent_color(agent_name: String) -> Color:
	"""Get color for agent messages"""
	match agent_name:
		"atlas":
			return Color(0.678, 0.847, 0.902)  # Light blue #ACD8E6
		"storyteller":
			return Color(0.576, 0.439, 0.859)  # Purple #9370DB
		"tactical":
			return Color(1.0, 0.42, 0.208)  # Orange/Red #FF6B35
		"companion":
			return Color(0.125, 0.698, 0.667)  # Cyan/Teal #20B2AA
		_:
			return Color(0.9, 0.9, 1.0, 1.0)  # Default white

func _add_ai_message(message: String, is_player: bool = false, agent_name: String = "atlas") -> void:
	"""Add a message to AI chat history"""

	var message_container = HBoxContainer.new()
	message_container.set("theme_override_constants/separation", 8)

	if not is_player:
		# AI message - show avatar (optional)
		var avatar_small = TextureRect.new()
		avatar_small.custom_minimum_size = Vector2(32, 32)
		avatar_small.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		avatar_small.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		message_container.add_child(avatar_small)

	# Message label
	var message_label = RichTextLabel.new()
	message_label.bbcode_enabled = true
	message_label.fit_content = true
	message_label.scroll_active = false
	message_label.add_theme_font_size_override("normal_font_size", 14)
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if is_player:
		message_label.add_theme_color_override("default_color", Color(0.8, 1.0, 0.8, 1.0))
		message_label.text = "[i]You: %s[/i]" % message
	else:
		var agent_color = _get_agent_color(agent_name)
		message_label.add_theme_color_override("default_color", agent_color)
		message_label.text = "[b]%s:[/b] %s" % [agent_name.capitalize(), message]

	message_container.add_child(message_label)
	chat_history.add_child(message_container)

	# Auto-scroll to bottom
	await get_tree().process_frame
	chat_scroll.scroll_vertical = chat_scroll.get_v_scroll_bar().max_value

# Legacy wrapper for backward compatibility
func _add_atlas_message(message: String, is_player: bool = false) -> void:
	"""Legacy wrapper - redirects to _add_ai_message with atlas as agent"""
	_add_ai_message(message, is_player, "atlas")

func _on_atlas_input_submitted(text: String) -> void:
	"""Handle Enter key in ATLAS input field"""
	if text.strip_edges() != "":
		_send_atlas_message(text)

func _on_atlas_send_pressed() -> void:
	"""Handle Send button click"""
	var text = atlas_input.text
	if text.strip_edges() != "":
		_send_atlas_message(text)

func _send_atlas_message(message: String) -> void:
	"""Send player message to selected AI agent and get response"""

	# Add player message to history
	_add_ai_message(message, true, current_agent)

	# Clear input
	atlas_input.text = ""

	# Call AI orchestrator with selected agent
	var result = await AIService.chat_with_agent(
		current_agent,
		message,
		conversation_id,
		true  # include_functions
	)

	if result.success:
		var response = result.data.response
		if response and response != "":
			_add_ai_message(response, false, current_agent)

		# Handle function calls
		if result.data.has("function_call") and result.data.function_call:
			var func_name = result.data.function_call.name
			var func_result = result.data.function_call.result
			print("%s executed function: %s" % [current_agent.capitalize(), func_name])

			# Optionally show function execution feedback
			if func_result.has("message"):
				_add_ai_message("[%s]" % func_result.message, false, current_agent)
	else:
		var error = result.get("error", "Unknown error")
		_add_ai_message("Error: %s" % error, false, current_agent)
		print("%s chat error: %s" % [current_agent.capitalize(), error])

func _update_status_ticker() -> void:
	"""Update status ticker with current game state"""

	var credits = GameState.player.credits
	var hull = GameState.ship.systems.hull.health if GameState.ship.systems.has("hull") else 0
	var max_hull = GameState.ship.systems.hull.max_health if GameState.ship.systems.has("hull") else 0
	var location = location_label.text
	var mission = mission_title.text

	status_label.text = "Credits: %d CR | Hull: %d/%d | Location: %s | Mission: %s" % [
		credits, hull, max_hull, location, mission
	]

## AI Interjection System

func _check_ai_interjections(stage: Dictionary) -> void:
	"""Check if this stage triggers any AI interjections"""

	var stage_id = stage.get("stage_id", "")
	var mission = MissionManager.get_active_mission()
	var effects = MissionManager.mission_effects

	# Tutorial mission: ATLAS interjections
	if mission.mission_id == "tutorial_first_salvage":
		_trigger_tutorial_interjections(stage_id, effects)

func _trigger_tutorial_interjections(stage_id: String, effects: Array) -> void:
	"""Trigger ATLAS commentary for tutorial mission - adds to chat instead of showing panel"""

	match stage_id:
		"arrival":
			# ATLAS comments on the museum's active power systems
			await get_tree().create_timer(2.0).timeout
			if current_stage_id != stage_id:
				return  # Stage changed, don't fire stale interjection
			_add_atlas_message(
				"Captain, I'm detecting active power signatures from the museum. Solar arrays functioning at 78% efficiency. Interior systems still operational. This facility has remarkable longevity—most pre-exodus infrastructure collapsed decades ago."
			)

		"workshop_contested":
			# ATLAS analyzes the scavengers
			if "encountered_scavengers" in effects:
				await get_tree().create_timer(1.5).timeout
				if current_stage_id != stage_id:
					return
				_add_atlas_message(
					"Bioscan complete. Two humans, armed but showing non-aggressive postures. Plasma cutter: tool, not weapon. Sidearm: defensive carry. Heart rates elevated but not combat-ready. Probability of peaceful resolution: 67%."
				)

		"workshop_informed":
			# ATLAS provides technical insight on security system
			if "gathered_intel" in effects:
				await get_tree().create_timer(1.0).timeout
				if current_stage_id != stage_id:
					return
				_add_atlas_message(
					"Security grid analysis: Pre-exodus museum automation, surprisingly intact. If you can access a maintenance terminal, I can interface with their systems. Service robots, door controls, possibly environmental systems. Recommend attempting computer access."
				)

		"workshop_open":
			# ATLAS assesses the ship frame
			await get_tree().create_timer(2.5).timeout
			if current_stage_id != stage_id:
				return
			_add_atlas_message(
				"Structural scan complete. Ship frame: titanium-aluminum alloy, stress fractures within acceptable parameters. Designed for light exploration. Hull hard points: 10 systems. Power routing: functional. This frame can support Level 3 systems across all categories. Your grandfather chose well."
			)

		"workshop_claimed":
			# ATLAS confirms systems operational
			await get_tree().create_timer(2.0).timeout
			if current_stage_id != stage_id:
				return
			_add_atlas_message(
				"All systems installed successfully. Hull: 50 HP nominal. Power core: 100 PU output steady. Propulsion: thrusters responsive. Computer core: ... that would be me. Welcome aboard, Captain. I've initialized ship protocols. We're ready for your first flight."
			)

		"mission_complete":
			# ATLAS celebrates completion
			await get_tree().create_timer(1.0).timeout
			if current_stage_id != stage_id:
				return
			_add_atlas_message(
				"Mission complete, Captain. Your grandfather would be proud. Ship classification: Scout, Level 1. Current capabilities: limited. But every starship begins with a single flight. Where shall we go next?"
			)

## Autonomous AI Agent System

func _initialize_agent_timers() -> void:
	"""Initialize timers for all autonomous AI agent checks with staggered delays"""

	# ATLAS timer (45s interval, immediate start)
	atlas_timer = Timer.new()
	atlas_timer.wait_time = 45.0
	atlas_timer.timeout.connect(_on_atlas_agent_check)
	atlas_timer.autostart = true
	add_child(atlas_timer)
	print("Mission: ATLAS autonomous agent timer initialized (45s interval, immediate start)")

	# Storyteller timer (90s interval, delay 20s)
	storyteller_timer = Timer.new()
	storyteller_timer.wait_time = 90.0
	storyteller_timer.one_shot = false
	storyteller_timer.timeout.connect(_on_storyteller_agent_check)
	add_child(storyteller_timer)

	# Start storyteller after 20s delay
	get_tree().create_timer(20.0).timeout.connect(func():
		storyteller_timer.start()
		print("Mission: Storyteller autonomous agent timer started (90s interval)")
	)

	# Tactical timer (30s interval, delay 10s)
	tactical_timer = Timer.new()
	tactical_timer.wait_time = 30.0
	tactical_timer.one_shot = false
	tactical_timer.timeout.connect(_on_tactical_agent_check)
	add_child(tactical_timer)

	# Start tactical after 10s delay
	get_tree().create_timer(10.0).timeout.connect(func():
		tactical_timer.start()
		print("Mission: Tactical autonomous agent timer started (30s interval)")
	)

	# Companion timer (120s interval, delay 30s)
	companion_timer = Timer.new()
	companion_timer.wait_time = 120.0
	companion_timer.one_shot = false
	companion_timer.timeout.connect(_on_companion_agent_check)
	add_child(companion_timer)

	# Start companion after 30s delay
	get_tree().create_timer(30.0).timeout.connect(func():
		companion_timer.start()
		print("Mission: Companion autonomous agent timer started (120s interval)")
	)

	print("Mission: All autonomous agent timers initialized with staggered delays")

func _on_atlas_agent_check() -> void:
	"""Handle ATLAS autonomous agent check timer"""
	print("Mission: ATLAS agent check triggered")

	# Skip if AI service unavailable
	if not ServiceManager.is_service_available("ai"):
		print("Mission: AI service unavailable, skipping ATLAS check")
		return

	# Call agent loop endpoint
	var result = await AIService.agent_loop_check("atlas")

	if result.success and result.data.has("should_act"):
		var should_act = result.data.get("should_act", false)

		if should_act and result.data.has("message"):
			var message = result.data.message
			var urgency = result.data.get("urgency", "INFO")

			print("Mission: ATLAS autonomous message (%s): %s" % [urgency, message.substr(0, 50)])

			# Add to chat (light blue color for ATLAS)
			_add_atlas_message(message)
		else:
			print("Mission: ATLAS staying silent (no message)")
	else:
		if result.has("error"):
			print("Mission: ATLAS agent check error: %s" % result.error)

func _on_storyteller_agent_check() -> void:
	"""Handle Storyteller autonomous agent check timer"""
	print("Mission: Storyteller agent check triggered")

	# Skip if AI service unavailable
	if not ServiceManager.is_service_available("ai"):
		print("Mission: AI service unavailable, skipping Storyteller check")
		return

	# Call agent loop endpoint
	var result = await AIService.agent_loop_check("storyteller")

	if result.success and result.data.has("should_act"):
		var should_act = result.data.get("should_act", false)

		if should_act and result.data.has("message"):
			var message = result.data.message
			var urgency = result.data.get("urgency", "INFO")

			print("Mission: Storyteller autonomous message (%s): %s" % [urgency, message.substr(0, 50)])

			# Add to chat (purple/violet color for Storyteller)
			var storyteller_label = RichTextLabel.new()
			storyteller_label.bbcode_enabled = true
			storyteller_label.fit_content = true
			storyteller_label.scroll_active = false
			storyteller_label.add_theme_font_size_override("normal_font_size", 14)
			storyteller_label.add_theme_color_override("default_color", Color(0.576, 0.439, 0.859))  # #9370DB
			storyteller_label.text = "[b]Storyteller:[/b] %s" % message

			var message_container = HBoxContainer.new()
			message_container.add_child(storyteller_label)
			chat_history.add_child(message_container)

			# Auto-scroll to bottom
			await get_tree().process_frame
			chat_scroll.scroll_vertical = chat_scroll.get_v_scroll_bar().max_value
		else:
			print("Mission: Storyteller staying silent (no message)")
	else:
		if result.has("error"):
			print("Mission: Storyteller agent check error: %s" % result.error)

func _on_tactical_agent_check() -> void:
	"""Handle Tactical autonomous agent check timer"""
	print("Mission: Tactical agent check triggered")

	# Skip if AI service unavailable
	if not ServiceManager.is_service_available("ai"):
		print("Mission: AI service unavailable, skipping Tactical check")
		return

	# Call agent loop endpoint
	var result = await AIService.agent_loop_check("tactical")

	if result.success and result.data.has("should_act"):
		var should_act = result.data.get("should_act", false)

		if should_act and result.data.has("message"):
			var message = result.data.message
			var urgency = result.data.get("urgency", "INFO")

			print("Mission: Tactical autonomous message (%s): %s" % [urgency, message.substr(0, 50)])

			# Add to chat (orange/red color for Tactical)
			var tactical_label = RichTextLabel.new()
			tactical_label.bbcode_enabled = true
			tactical_label.fit_content = true
			tactical_label.scroll_active = false
			tactical_label.add_theme_font_size_override("normal_font_size", 14)
			tactical_label.add_theme_color_override("default_color", Color(1.0, 0.42, 0.208))  # #FF6B35
			tactical_label.text = "[b]Tactical:[/b] %s" % message

			var message_container = HBoxContainer.new()
			message_container.add_child(tactical_label)
			chat_history.add_child(message_container)

			# Auto-scroll to bottom
			await get_tree().process_frame
			chat_scroll.scroll_vertical = chat_scroll.get_v_scroll_bar().max_value
		else:
			print("Mission: Tactical staying silent (no message)")
	else:
		if result.has("error"):
			print("Mission: Tactical agent check error: %s" % result.error)

func _on_companion_agent_check() -> void:
	"""Handle Companion autonomous agent check timer"""
	print("Mission: Companion agent check triggered")

	# Skip if AI service unavailable
	if not ServiceManager.is_service_available("ai"):
		print("Mission: AI service unavailable, skipping Companion check")
		return

	# Call agent loop endpoint
	var result = await AIService.agent_loop_check("companion")

	if result.success and result.data.has("should_act"):
		var should_act = result.data.get("should_act", false)

		if should_act and result.data.has("message"):
			var message = result.data.message
			var urgency = result.data.get("urgency", "INFO")

			print("Mission: Companion autonomous message (%s): %s" % [urgency, message.substr(0, 50)])

			# Add to chat (cyan/teal color for Companion)
			var companion_label = RichTextLabel.new()
			companion_label.bbcode_enabled = true
			companion_label.fit_content = true
			companion_label.scroll_active = false
			companion_label.add_theme_font_size_override("normal_font_size", 14)
			companion_label.add_theme_color_override("default_color", Color(0.125, 0.698, 0.667))  # #20B2AA
			companion_label.text = "[b]Companion:[/b] %s" % message

			var message_container = HBoxContainer.new()
			message_container.add_child(companion_label)
			chat_history.add_child(message_container)

			# Auto-scroll to bottom
			await get_tree().process_frame
			chat_scroll.scroll_vertical = chat_scroll.get_v_scroll_bar().max_value
		else:
			print("Mission: Companion staying silent (no message)")
	else:
		if result.has("error"):
			print("Mission: Companion agent check error: %s" % result.error)


# ============================================================================
# HYBRID MISSION SUPPORT - Dynamic Narrative Generation
# ============================================================================

func _is_hybrid_mission() -> bool:
	"""Check if current mission uses hybrid narrative generation"""
	var mission = MissionManager.get_active_mission()
	if not mission or not mission.has("stages"):
		return false

	# Check if any stage has narrative_structure
	for stage in mission.stages:
		if stage.has("narrative_structure"):
			return true

	return false


func _is_hybrid_stage(stage: Dictionary) -> bool:
	"""Check if a specific stage uses hybrid narrative generation"""
	return stage.has("narrative_structure")


func _is_hybrid_choice(choice: Dictionary) -> bool:
	"""Check if a choice uses hybrid outcome generation"""
	return choice.has("outcome_prompt")


func _generate_stage_narrative(stage: Dictionary) -> String:
	"""Generate narrative text for a hybrid stage using StoryService"""

	print("[Mission] Generating dynamic narrative for stage: %s" % stage.get("stage_id", "unknown"))

	# Check if StoryService is available
	if not StoryService.is_available():
		push_warning("[Mission] StoryService not available, using static fallback")
		return stage.get("description", "The story continues...")

	# Build request data
	var mission = MissionManager.get_active_mission()
	var request_data = {
		"player_id": StoryService.get_player_id(),
		"mission_template": mission,
		"stage_id": stage.get("stage_id", ""),
		"player_state": StoryService.build_player_state(),
		"world_context": null  # Story API will fetch if needed
	}

	# Call StoryService
	var result = await StoryService.generate_narrative(request_data)

	if result.success:
		var cached_indicator = " [cached]" if result.get("cached", false) else ""
		print("[Mission] Narrative generated%s (%dms)" % [cached_indicator, result.get("generation_time_ms", 0)])
		return result.narrative
	else:
		push_error("[Mission] Narrative generation failed: %s" % result.get("error", "Unknown"))
		# Fallback to static description if available
		return stage.get("description", "The story continues...")


func _generate_choice_outcome(choice: Dictionary, outcome_type: String) -> Dictionary:
	"""Generate outcome narrative for a hybrid choice using StoryService"""

	print("[Mission] Generating dynamic outcome for choice: %s (outcome: %s)" % [choice.get("choice_id", "unknown"), outcome_type])

	# Check if StoryService is available
	if not StoryService.is_available():
		push_warning("[Mission] StoryService not available, using static fallback")
		return _get_static_outcome(choice, outcome_type)

	# Get outcome prompt for this outcome type
	var outcome_prompt = choice.get("outcome_prompt", {}).get(outcome_type)
	if not outcome_prompt:
		# Fallback to static if outcome_prompt missing for this type
		return _get_static_outcome(choice, outcome_type)

	# Build choice data for API
	var choice_data = {
		"choice_id": choice.get("choice_id", ""),
		"text": choice.get("text", ""),
		"outcome_prompt": outcome_prompt,
		"consequences": choice.get("consequences", {}).get(outcome_type, {})
	}

	# Build request data
	var request_data = {
		"player_id": StoryService.get_player_id(),
		"choice": choice_data,
		"player_state": StoryService.build_player_state(),
		"world_context": null
	}

	# Call StoryService
	var result = await StoryService.generate_outcome(request_data)

	if result.success:
		print("[Mission] Outcome generated (%dms)" % result.get("generation_time_ms", 0))

		# Return narrative at root level (matching API format)
		return {
			"narrative": result.narrative,
			"cached": result.get("cached", false)
		}
	else:
		push_error("[Mission] Outcome generation failed: %s" % result.get("error", "Unknown"))
		# Fallback to static
		return _get_static_outcome(choice, outcome_type)


func _get_static_outcome(choice: Dictionary, outcome_type: String) -> Dictionary:
	"""Get static outcome from choice data (fallback)"""
	var consequences = choice.get("consequences", {})
	var consequence = consequences.get(outcome_type, {})

	return {
		"consequence": consequence
	}


func _handle_hybrid_choice(choice: Dictionary) -> void:
	"""Handle hybrid choice with dynamic outcome generation"""

	print("[Mission] Handling hybrid choice: %s" % choice.get("choice_id", "unknown"))

	# Step 1: Determine success/failure based on requirements
	var requirements_met = _check_choice_requirements(choice)
	var outcome_type = "success" if requirements_met else "failure"

	print("[Mission] Requirements met: %s → outcome type: %s" % [requirements_met, outcome_type])

	# Step 2: Get consequence from mission JSON (same as static missions)
	var all_consequences = choice.get("consequences", {})
	var consequence = all_consequences.get(outcome_type, {})

	if consequence.is_empty():
		push_error("[Mission] No consequence defined for outcome type: %s" % outcome_type)
		for button in choice_buttons:
			button.disabled = false
		return

	# Step 3: Generate dynamic narrative for this outcome
	# Show loading indicator
	var loading_label = Label.new()
	loading_label.text = "⏳ Generating outcome..."
	loading_label.add_theme_font_size_override("font_size", 18)
	loading_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0, 1.0))
	narrative_log.add_child(loading_label)
	await get_tree().process_frame  # Allow UI to update

	var result = await _generate_choice_outcome(choice, outcome_type)

	# Remove loading indicator
	narrative_log.remove_child(loading_label)
	loading_label.queue_free()

	var narrative = ""
	if not result.is_empty() and result.has("narrative"):
		narrative = result.narrative
	else:
		# Fallback: use basic description
		narrative = "The choice has consequences..."
		push_warning("[Mission] Failed to generate narrative, using fallback")

	# Step 4: Apply effects to GameState (from mission JSON, not API)
	_apply_choice_effects(consequence)

	# Step 5: Update MissionManager state (from mission JSON)
	var next_stage = consequence.get("next_stage", null)
	if next_stage != null and next_stage != "":
		MissionManager.current_stage_id = next_stage
		print("[Mission] Advanced to next stage: %s" % next_stage)
	else:
		print("[Mission] No next_stage in consequence, staying on current stage")

	# Store effects in MissionManager for tracking
	if consequence.has("effects"):
		for effect in consequence.effects:
			if effect not in MissionManager.mission_effects:
				MissionManager.mission_effects.append(effect)

	# Step 6: Display narrative and continue (same as static missions)
	if next_stage != null and next_stage != "":
		# Append narrative to log
		await _append_result_to_log(narrative)

		# Dim previous stages
		_dim_previous_stages()

		# Hide choices during transition
		choices_label.visible = false
		for button in choice_buttons:
			button.visible = false

		# Update status ticker
		_update_status_ticker()

		# Short pause
		await get_tree().create_timer(1.0).timeout

		# Load new stage (MissionManager.current_stage_id already updated)
		_load_current_stage()
	else:
		# Mission complete
		await _append_result_to_log(narrative)
		await get_tree().create_timer(1.0).timeout
		await _append_mission_complete()


func _apply_choice_effects(consequence: Dictionary) -> void:
	"""Apply consequences of a choice to GameState"""

	# Apply XP bonus
	if consequence.has("xp_bonus"):
		var xp_bonus = consequence.xp_bonus
		if xp_bonus > 0:
			GameState.player.xp += xp_bonus
			print("[Mission] Applied XP bonus: +%d" % xp_bonus)
			EventBus.xp_gained.emit(xp_bonus)

	# Apply story flags
	if consequence.has("story_flags"):
		var story_flags = consequence.story_flags
		for flag in story_flags.keys():
			var value = story_flags[flag]
			# Store in GameState progress
			if not GameState.progress.has("story_flags"):
				GameState.progress.story_flags = {}
			GameState.progress.story_flags[flag] = value
			print("[Mission] Set story flag: %s = %s" % [flag, value])

	# Apply relationships
	if consequence.has("relationships"):
		var relationships = consequence.relationships
		for character in relationships.keys():
			var delta = relationships[character]
			# Store in GameState progress
			if not GameState.progress.has("relationships"):
				GameState.progress.relationships = {}

			var current = GameState.progress.relationships.get(character, 0)
			GameState.progress.relationships[character] = clamp(current + delta, -100, 100)
			print("[Mission] Updated relationship: %s %+d → %d" % [character, delta, GameState.progress.relationships[character]])


# ============================================================================
# CLEANUP - Resource Management
# ============================================================================

func _exit_tree() -> void:
	"""Cleanup resources when mission scene is exited"""

	print("[Mission] Cleaning up mission scene resources...")

	# Stop and free all autonomous agent timers
	if atlas_timer and is_instance_valid(atlas_timer):
		atlas_timer.stop()
		atlas_timer.queue_free()

	if storyteller_timer and is_instance_valid(storyteller_timer):
		storyteller_timer.stop()
		storyteller_timer.queue_free()

	if tactical_timer and is_instance_valid(tactical_timer):
		tactical_timer.stop()
		tactical_timer.queue_free()

	if companion_timer and is_instance_valid(companion_timer):
		companion_timer.stop()
		companion_timer.queue_free()

	# Clean up scroll indicator
	_hide_scroll_indicator()

	print("[Mission] Cleanup complete")

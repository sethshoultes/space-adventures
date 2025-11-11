extends Control

## Mission Selection Scene
## Two-panel UI for browsing and selecting missions
## Left panel: Mission cards with status indicators
## Right panel: Detailed mission information

# Color constants matching Penpot design
const COLOR_BG_DARK: Color = Color("1a1d2e")
const COLOR_CYAN: Color = Color("00e5ff")
const COLOR_GREEN: Color = Color("00ff88")
const COLOR_RED: Color = Color("ff4444")
const COLOR_GRAY: Color = Color("5a5e7a")
const COLOR_YELLOW: Color = Color("ffaa00")
const COLOR_WHITE: Color = Color("ffffff")

# UI References
@onready var mission_list_container: VBoxContainer = $HBoxContainer/LeftPanel/ScrollContainer/MissionList
@onready var details_panel: VBoxContainer = $HBoxContainer/RightPanel/DetailsContainer
@onready var launch_button: Button = $HBoxContainer/RightPanel/DetailsContainer/LaunchButton
@onready var back_button: Button = $Header/BackButton
@onready var random_mission_button: Button = $Header/RandomMissionButton

# Mission title and info labels
@onready var detail_title: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var detail_type_difficulty: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/TypeDifficultyLabel
@onready var detail_time: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/TimeLabel
@onready var detail_location: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/LocationContainer/LocationLabel
@onready var detail_briefing: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/BriefingContainer/BriefingLabel
@onready var detail_requirements: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/RequirementsContainer/RequirementsLabel
@onready var detail_rewards: Label = $HBoxContainer/RightPanel/DetailsContainer/MarginContainer/VBoxContainer/RewardsContainer/RewardsLabel

# State
var all_missions: Array = []
var selected_mission: Dictionary = {}
var selected_card: Control = null

func _ready() -> void:
	print("Mission Selection initialized")

	# Connect signals
	back_button.pressed.connect(_on_back_pressed)
	launch_button.pressed.connect(_on_launch_pressed)

	# Connect Random Mission button if it exists
	if random_mission_button:
		random_mission_button.pressed.connect(_on_random_mission_pressed)

	# Load and display missions
	_load_missions()
	_populate_mission_list()

	# Auto-select first available mission
	_auto_select_first_available()

func _load_missions() -> void:
	"""Load all missions from MissionManager"""
	all_missions = []

	# Get all loaded missions from MissionManager
	for mission_id in MissionManager.loaded_missions:
		var mission = MissionManager.loaded_missions[mission_id]
		all_missions.append(mission)

	print("Loaded %d missions for selection" % all_missions.size())

func _populate_mission_list() -> void:
	"""Create mission cards for all missions"""
	# Clear existing cards
	for child in mission_list_container.get_children():
		child.queue_free()

	# Create card for each mission
	for mission in all_missions:
		var card = _create_mission_card(mission)
		mission_list_container.add_child(card)

func _create_mission_card(mission: Dictionary) -> Control:
	"""Create a mission card UI element"""
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 120)

	# Store mission data in metadata
	card.set_meta("mission_data", mission)

	# Card background style
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_BG_DARK
	style.border_width_left = 4
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	# Determine card status
	var status = _get_mission_status(mission)

	# Set border color based on status
	match status:
		"READY":
			style.border_color = COLOR_GREEN
		"LOCKED":
			style.border_color = COLOR_RED
		"DONE":
			style.border_color = COLOR_GRAY

	card.add_theme_stylebox_override("panel", style)

	# Card content container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks through to button below
	card.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks through to button below
	margin.add_child(vbox)

	# Top row: Title and Type Badge
	var top_row = HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks through
	vbox.add_child(top_row)

	var title_label = Label.new()
	title_label.text = mission.title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", COLOR_WHITE)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title_label)

	var type_badge = Label.new()
	type_badge.text = mission.type.to_upper()
	type_badge.add_theme_font_size_override("font_size", 12)
	type_badge.add_theme_color_override("font_color", COLOR_CYAN)
	top_row.add_child(type_badge)

	# Time estimate
	var time_label = Label.new()
	var estimated_time = mission.get("estimated_time", "10-15 min")
	time_label.text = "⏱ " + estimated_time
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.add_theme_color_override("font_color", COLOR_YELLOW)
	vbox.add_child(time_label)

	# Difficulty stars
	var difficulty_label = Label.new()
	var difficulty = mission.get("difficulty", 1)
	difficulty_label.text = "DIFFICULTY: " + _get_difficulty_stars(difficulty)
	difficulty_label.add_theme_font_size_override("font_size", 12)
	difficulty_label.add_theme_color_override("font_color", COLOR_WHITE)
	vbox.add_child(difficulty_label)

	# Rewards row
	var rewards_label = Label.new()
	var rewards = mission.get("rewards", {})
	var credits = rewards.get("credits", 0)
	var xp = rewards.get("xp", 0)
	rewards_label.text = "%d CR | %d XP" % [credits, xp]
	rewards_label.add_theme_font_size_override("font_size", 12)
	rewards_label.add_theme_color_override("font_color", COLOR_YELLOW)
	vbox.add_child(rewards_label)

	# Description (brief)
	var desc_label = Label.new()
	var full_desc = mission.get("description", "")
	desc_label.text = full_desc.substr(0, 60) + "..." if full_desc.length() > 60 else full_desc
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# Bottom row: Status badge
	var bottom_row = HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_END
	bottom_row.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks through
	vbox.add_child(bottom_row)

	var status_badge = Label.new()
	match status:
		"READY":
			status_badge.text = "✓ READY"
			status_badge.add_theme_color_override("font_color", COLOR_GREEN)
		"LOCKED":
			status_badge.text = "🔒 LOCKED"
			status_badge.add_theme_color_override("font_color", COLOR_RED)
		"DONE":
			status_badge.text = "✓ DONE"
			status_badge.add_theme_color_override("font_color", COLOR_GRAY)

	status_badge.add_theme_font_size_override("font_size", 12)
	bottom_row.add_child(status_badge)

	# Adjust opacity for locked/done missions
	if status == "LOCKED":
		card.modulate.a = 0.6
	elif status == "DONE":
		card.modulate = Color(0.7, 0.7, 0.7, 0.8)

	# Make card clickable
	var click_detector = Button.new()
	click_detector.flat = true
	click_detector.custom_minimum_size = card.custom_minimum_size
	click_detector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	click_detector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	click_detector.pressed.connect(_on_mission_card_clicked.bind(card))

	# Add click detector as overlay
	card.add_child(click_detector)
	card.move_child(click_detector, 0)  # Move to back so it doesn't cover content

	return card

func _get_mission_status(mission: Dictionary) -> String:
	"""Determine if mission is READY, LOCKED, or DONE"""
	var mission_id = mission.mission_id

	# Check if completed
	if GameState.is_mission_completed(mission_id):
		return "DONE"

	# Check requirements
	var requirements = mission.get("requirements", {})

	# Check minimum level
	if requirements.has("min_level"):
		if GameState.player.level < requirements.min_level:
			return "LOCKED"

	# Check required systems
	if requirements.has("required_systems") and requirements.required_systems is Array:
		for system_name in requirements.required_systems:
			if GameState.ship.systems[system_name].level == 0:
				return "LOCKED"

	# Check completed missions
	if requirements.has("completed_missions") and requirements.completed_missions is Array:
		for prereq_mission in requirements.completed_missions:
			if not GameState.is_mission_completed(prereq_mission):
				return "LOCKED"

	# Mission is available
	return "READY"

func _get_difficulty_stars(difficulty: int) -> String:
	"""Convert difficulty number to star string"""
	var stars = ""
	for i in range(5):
		if i < difficulty:
			stars += "★"
		else:
			stars += "☆"
	return stars

func _on_mission_card_clicked(card: Control) -> void:
	"""Handle mission card selection"""
	var mission = card.get_meta("mission_data")

	# Deselect previous card
	if selected_card and selected_card != card:
		_deselect_card(selected_card)

	# Select new card
	selected_card = card
	selected_mission = mission
	_highlight_card(card)

	# Update details panel
	_update_details_panel(mission)

func _highlight_card(card: Control) -> void:
	"""Add cyan highlight to selected card"""
	var style = card.get_theme_stylebox("panel").duplicate()
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.set_border_width_all(2)
	style.border_color = COLOR_CYAN
	card.add_theme_stylebox_override("panel", style)

func _deselect_card(card: Control) -> void:
	"""Remove highlight from card"""
	var mission = card.get_meta("mission_data")
	var status = _get_mission_status(mission)

	var style = card.get_theme_stylebox("panel").duplicate()
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.border_width_left = 4

	# Restore original border color
	match status:
		"READY":
			style.border_color = COLOR_GREEN
		"LOCKED":
			style.border_color = COLOR_RED
		"DONE":
			style.border_color = COLOR_GRAY

	card.add_theme_stylebox_override("panel", style)

func _update_details_panel(mission: Dictionary) -> void:
	"""Update right panel with mission details"""
	# Title
	detail_title.text = mission.title.to_upper()
	detail_title.add_theme_color_override("font_color", COLOR_CYAN)
	detail_title.add_theme_font_size_override("font_size", 24)

	# Type and Difficulty
	var difficulty_stars = _get_difficulty_stars(mission.get("difficulty", 1))
	detail_type_difficulty.text = "TYPE: %s | DIFFICULTY: %s" % [
		mission.type.to_upper(),
		difficulty_stars
	]
	detail_type_difficulty.add_theme_font_size_override("font_size", 14)

	# Estimated Time
	var estimated_time = mission.get("estimated_time", "10-15 min")
	detail_time.text = "⏱ ESTIMATED TIME: %s" % estimated_time.to_upper()
	detail_time.add_theme_color_override("font_color", COLOR_YELLOW)
	detail_time.add_theme_font_size_override("font_size", 14)

	# Location
	detail_location.text = mission.get("location", "Unknown Location")
	detail_location.add_theme_font_size_override("font_size", 14)

	# Mission Briefing
	detail_briefing.text = mission.get("description", "No description available.")
	detail_briefing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_briefing.add_theme_font_size_override("font_size", 14)

	# Requirements
	var requirements = mission.get("requirements", {})
	var req_text = _format_requirements(requirements, mission)
	detail_requirements.text = req_text
	detail_requirements.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_requirements.add_theme_font_size_override("font_size", 14)

	# Rewards
	var rewards = mission.get("rewards", {})
	var reward_text = _format_rewards(rewards)
	detail_rewards.text = reward_text
	detail_rewards.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_rewards.add_theme_font_size_override("font_size", 14)

	# Launch button state
	var status = _get_mission_status(mission)
	match status:
		"READY":
			launch_button.disabled = false
			launch_button.text = "LAUNCH MISSION"
			launch_button.modulate = Color.WHITE
		"LOCKED":
			launch_button.disabled = true
			launch_button.text = "LOCKED"
			launch_button.modulate = Color(1.0, 0.5, 0.5)
		"DONE":
			launch_button.disabled = false
			launch_button.text = "REPLAY"
			launch_button.modulate = Color.WHITE

func _format_requirements(requirements: Dictionary, mission: Dictionary) -> String:
	"""Format requirements text with color coding"""
	if requirements.is_empty():
		return "✓ None - Mission available to all pilots"

	var req_lines = []
	var all_met = true

	# Check level requirement
	if requirements.has("min_level"):
		var required_level = requirements.min_level
		var player_level = GameState.player.level
		if player_level >= required_level:
			req_lines.append("✓ Level %d (You: %d)" % [required_level, player_level])
		else:
			req_lines.append("✗ Requires Level %d (You: %d)" % [required_level, player_level])
			all_met = false

	# Check system requirements
	if requirements.has("required_systems") and requirements.required_systems is Array:
		for system_name in requirements.required_systems:
			var system = GameState.ship.systems.get(system_name, {})
			var system_level = system.get("level", 0)
			if system_level > 0:
				req_lines.append("✓ %s System Installed" % system_name.capitalize())
			else:
				req_lines.append("✗ Requires %s System" % system_name.capitalize())
				all_met = false

	# Check completed mission requirements
	if requirements.has("completed_missions") and requirements.completed_missions is Array:
		for prereq_mission in requirements.completed_missions:
			if GameState.is_mission_completed(prereq_mission):
				var prereq_data = MissionManager.get_mission(prereq_mission)
				var prereq_title = prereq_data.get("title", prereq_mission)
				req_lines.append("✓ Completed: %s" % prereq_title)
			else:
				var prereq_data = MissionManager.get_mission(prereq_mission)
				var prereq_title = prereq_data.get("title", prereq_mission)
				req_lines.append("✗ Requires: %s" % prereq_title)
				all_met = false

	if req_lines.is_empty():
		return "✓ None - Mission available to all pilots"

	return "\n".join(req_lines)

func _format_rewards(rewards: Dictionary) -> String:
	"""Format rewards text"""
	var reward_lines = []

	# Credits
	if rewards.has("credits"):
		reward_lines.append("+%d CREDITS" % rewards.credits)

	# XP
	if rewards.has("xp"):
		reward_lines.append("+%d EXPERIENCE POINTS" % rewards.xp)

	# Items/Parts
	if rewards.has("items") and rewards.items is Array and rewards.items.size() > 0:
		var item_count = rewards.items.size()
		reward_lines.append("+Possible salvage: %d parts" % item_count)

	if reward_lines.is_empty():
		return "No rewards listed"

	return "\n".join(reward_lines)

func _auto_select_first_available() -> void:
	"""Auto-select the first READY mission, or first mission if none ready"""
	# Wait for cards to be created
	await get_tree().process_frame

	var cards = mission_list_container.get_children()
	if cards.is_empty():
		return

	# Try to find first READY mission
	for card in cards:
		var mission = card.get_meta("mission_data")
		var status = _get_mission_status(mission)
		if status == "READY":
			_on_mission_card_clicked(card)
			return

	# If no READY missions, select first card
	if cards.size() > 0:
		_on_mission_card_clicked(cards[0])

func _on_launch_pressed() -> void:
	"""Launch the selected mission"""
	if selected_mission.is_empty():
		print("No mission selected")
		return

	var mission_id = selected_mission.mission_id
	print("Launching mission: %s" % mission_id)

	# Start the mission
	var mission_started = MissionManager.start_mission(mission_id)

	if mission_started:
		# Auto-save before starting mission
		SaveManager.auto_save()

		# Load mission scene
		get_tree().change_scene_to_file("res://scenes/mission.tscn")
	else:
		print("Failed to start mission")
		# TODO: Show error dialog

func _on_random_mission_pressed() -> void:
	"""Generate and load a random mission from Mission Pool"""
	print("Generating random mission...")

	# Disable button during generation
	if random_mission_button:
		random_mission_button.disabled = true
		random_mission_button.text = "GENERATING..."

	# Fetch random mission from Mission Pool
	var difficulty = "medium"  # TODO: Could make this selectable
	var result = await StoryService.get_pool_mission(difficulty)

	# Re-enable button
	if random_mission_button:
		random_mission_button.disabled = false
		random_mission_button.text = "🎲 RANDOM MISSION"

	if not result.get("success", false):
		print("Failed to generate random mission: %s" % result.get("error", "Unknown error"))
		# TODO: Show error dialog
		return

	var mission = result.get("mission", {})
	if mission.is_empty():
		print("Received empty mission from Mission Pool")
		return

	print("Generated random mission: %s (%s)" % [mission.get("title", "Unknown"), mission.get("mission_id", "unknown")])

	# Add mission to MissionManager temporarily (for this session only)
	MissionManager.add_temporary_mission(mission)

	# Reload mission list to include new mission
	_load_missions()
	_populate_mission_list()

	# Auto-select the new random mission
	await get_tree().process_frame
	var cards = mission_list_container.get_children()
	for card in cards:
		var card_mission = card.get_meta("mission_data")
		if card_mission.get("mission_id") == mission.get("mission_id"):
			_on_mission_card_clicked(card)
			break

func _on_back_pressed() -> void:
	"""Return to workshop"""
	print("Returning to workshop")
	get_tree().change_scene_to_file("res://scenes/workshop.tscn")

extends Control

## Load Game Screen
## Displays 3 save slots and allows loading a saved game

# Color constants
const COLOR_CYAN: Color = Color(0.0, 0.898, 1.0)  # #00e5ff
const COLOR_GREEN: Color = Color(0.0, 1.0, 0.533)  # #00ff88
const COLOR_GRAY: Color = Color(0.69, 0.69, 0.69)  # #b0b0b0
const COLOR_RED: Color = Color(1.0, 0.267, 0.267)  # #ff4444

@onready var slot1_panel: PanelContainer = $MarginContainer/VBoxContainer/SaveSlotsContainer/Slot1
@onready var slot2_panel: PanelContainer = $MarginContainer/VBoxContainer/SaveSlotsContainer/Slot2
@onready var slot3_panel: PanelContainer = $MarginContainer/VBoxContainer/SaveSlotsContainer/Slot3

func _ready() -> void:
	print("Load Game: Initializing...")

	# Setup each save slot
	_setup_slot(slot1_panel, 1)
	_setup_slot(slot2_panel, 2)
	_setup_slot(slot3_panel, 3)

	print("Load Game: Ready")

# ============================================================================
# SLOT SETUP
# ============================================================================

func _setup_slot(panel: PanelContainer, slot_number: int) -> void:
	"""Setup a save slot panel with data or empty state"""
	# Apply panel styling
	_apply_panel_style(panel)

	# Create content container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# Check if save exists
	if SaveManager.save_exists(slot_number):
		_populate_slot_with_data(vbox, slot_number, panel)
	else:
		_populate_empty_slot(vbox, slot_number)

func _apply_panel_style(panel: PanelContainer) -> void:
	"""Apply styling to save slot panel"""
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	stylebox.border_width_left = 4
	stylebox.border_color = COLOR_CYAN
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	stylebox.corner_radius_bottom_left = 5
	stylebox.corner_radius_bottom_right = 5

	panel.add_theme_stylebox_override("panel", stylebox)

func _populate_slot_with_data(container: VBoxContainer, slot_number: int, panel: PanelContainer) -> void:
	"""Populate slot with save data"""
	var save_info = SaveManager.get_save_info(slot_number)

	# Slot header
	var header_hbox = HBoxContainer.new()
	container.add_child(header_hbox)

	var slot_label = Label.new()
	slot_label.text = "SLOT %d" % slot_number
	slot_label.add_theme_color_override("font_color", COLOR_CYAN)
	slot_label.add_theme_font_size_override("font_size", 14)
	header_hbox.add_child(slot_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	var timestamp_label = Label.new()
	timestamp_label.text = save_info.get("save_date", "Unknown")
	timestamp_label.add_theme_color_override("font_color", COLOR_GRAY)
	timestamp_label.add_theme_font_size_override("font_size", 12)
	header_hbox.add_child(timestamp_label)

	# Player info
	var player_label = Label.new()
	player_label.text = "%s - Level %d %s" % [
		save_info.get("player_name", "Unknown"),
		save_info.get("player_level", 1),
		save_info.get("player_rank", "Cadet")
	]
	player_label.add_theme_color_override("font_color", COLOR_GREEN)
	player_label.add_theme_font_size_override("font_size", 16)
	container.add_child(player_label)

	# Ship info
	var ship_label = Label.new()
	ship_label.text = "Ship: %s (%s)" % [
		save_info.get("ship_name", "Unnamed Vessel"),
		save_info.get("ship_class", "None")
	]
	ship_label.add_theme_color_override("font_color", COLOR_GRAY)
	ship_label.add_theme_font_size_override("font_size", 14)
	container.add_child(ship_label)

	# Progress info
	var progress_hbox = HBoxContainer.new()
	progress_hbox.add_theme_constant_override("separation", 30)
	container.add_child(progress_hbox)

	var missions_label = Label.new()
	missions_label.text = "Missions: %d" % save_info.get("completed_missions", 0)
	missions_label.add_theme_color_override("font_color", COLOR_GRAY)
	missions_label.add_theme_font_size_override("font_size", 12)
	progress_hbox.add_child(missions_label)

	var playtime_label = Label.new()
	var playtime = SaveManager.format_playtime(save_info.get("playtime_seconds", 0.0))
	playtime_label.text = "Playtime: %s" % playtime
	playtime_label.add_theme_color_override("font_color", COLOR_GRAY)
	playtime_label.add_theme_font_size_override("font_size", 12)
	progress_hbox.add_child(playtime_label)

	# Make panel clickable
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_slot_clicked.bind(slot_number))

	# Add hover effect
	panel.mouse_entered.connect(_on_slot_mouse_entered.bind(panel))
	panel.mouse_exited.connect(_on_slot_mouse_exited.bind(panel))

func _populate_empty_slot(container: VBoxContainer, slot_number: int) -> void:
	"""Populate empty slot"""
	# Slot header
	var slot_label = Label.new()
	slot_label.text = "SLOT %d" % slot_number
	slot_label.add_theme_color_override("font_color", COLOR_CYAN)
	slot_label.add_theme_font_size_override("font_size", 14)
	container.add_child(slot_label)

	# Empty message
	var empty_label = Label.new()
	empty_label.text = "EMPTY SLOT"
	empty_label.add_theme_color_override("font_color", COLOR_GRAY)
	empty_label.add_theme_font_size_override("font_size", 24)
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(empty_label)

# ============================================================================
# INPUT HANDLERS
# ============================================================================

func _on_slot_clicked(event: InputEvent, slot_number: int) -> void:
	"""Handle slot click"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_load_slot(slot_number)

func _load_slot(slot_number: int) -> void:
	"""Load a save slot"""
	if not SaveManager.save_exists(slot_number):
		EventBus.notify("Save slot is empty", "error")
		return

	print("Load Game: Loading slot %d..." % slot_number)

	if SaveManager.load_game(slot_number):
		print("Load Game: Save loaded successfully, navigating to workshop...")
		get_tree().change_scene_to_file("res://scenes/workshop.tscn")
	else:
		EventBus.notify("Failed to load save file", "error")

func _on_back_button_pressed() -> void:
	"""Return to main menu"""
	print("Load Game: Returning to main menu...")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ============================================================================
# HOVER EFFECTS
# ============================================================================

func _on_slot_mouse_entered(panel: PanelContainer) -> void:
	"""Brighten panel on hover"""
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1.15, 1.15, 1.15), 0.15)

func _on_slot_mouse_exited(panel: PanelContainer) -> void:
	"""Reset panel brightness"""
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1.0, 1.0, 1.0), 0.15)

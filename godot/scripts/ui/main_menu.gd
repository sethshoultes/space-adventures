extends Control

## Main Menu Scene
## Complete main menu with service status, save info, and navigation

# Color constants
const COLOR_CYAN: Color = Color(0.0, 0.898, 1.0)  # #00e5ff
const COLOR_GREEN: Color = Color(0.0, 1.0, 0.533)  # #00ff88
const COLOR_YELLOW: Color = Color(1.0, 0.733, 0.0)  # #ffbb00
const COLOR_RED: Color = Color(1.0, 0.267, 0.267)  # #ff4444
const COLOR_WHITE: Color = Color(1.0, 1.0, 1.0)
const COLOR_GRAY: Color = Color(0.69, 0.69, 0.69)  # #b0b0b0

# Node references
@onready var background_image: TextureRect = $BackgroundLayer/BackgroundImage

@onready var menu_panel: Control = $MenuPanel
@onready var cyan_border: Control = $MenuPanel/CyanBorder
@onready var yellow_bracket_tl: Control = $MenuPanel/YellowBracketTL
@onready var yellow_bracket_tr: Control = $MenuPanel/YellowBracketTR
@onready var yellow_bracket_bl: Control = $MenuPanel/YellowBracketBL
@onready var yellow_bracket_br: Control = $MenuPanel/YellowBracketBR

@onready var gateway_label: Label = $MenuPanel/MarginContainer/MainVBox/SystemStatusPanel/MarginContainer/VBoxContainer/StatusHBox/GatewayLabel
@onready var ai_label: Label = $MenuPanel/MarginContainer/MainVBox/SystemStatusPanel/MarginContainer/VBoxContainer/StatusHBox/AILabel
@onready var whisper_label: Label = $MenuPanel/MarginContainer/MainVBox/SystemStatusPanel/MarginContainer/VBoxContainer/StatusHBox/WhisperLabel

@onready var continue_button: Button = $MenuPanel/MarginContainer/MainVBox/MenuButtons/ContinueButton
@onready var new_game_button: Button = $MenuPanel/MarginContainer/MainVBox/MenuButtons/NewGameButton
@onready var load_game_button: Button = $MenuPanel/MarginContainer/MainVBox/MenuButtons/LoadGameButton
@onready var settings_button: Button = $MenuPanel/MarginContainer/MainVBox/MenuButtons/SettingsButton
@onready var quit_button: Button = $MenuPanel/MarginContainer/MainVBox/MenuButtons/QuitButton

@onready var save_info_label: Label = $MenuPanel/MarginContainer/MainVBox/SaveInfoPanel/SaveInfoLabel
@onready var save_time_label: Label = $MenuPanel/MarginContainer/MainVBox/SaveInfoPanel/SaveTimeLabel

func _ready() -> void:
	print("Main Menu: Initializing...")

	# Try to load background image if it exists
	_load_background_image()

	# Draw cyan border and yellow corner brackets
	_setup_menu_panel_borders()

	# Update system status
	_update_system_status()

	# Update save info and Continue button state
	_update_save_info()

	# Apply button styling
	_setup_button_styles()

	print("Main Menu: Ready")

func _draw() -> void:
	# This is called when queue_redraw() is invoked
	pass

# ============================================================================
# INITIALIZATION
# ============================================================================

func _load_background_image() -> void:
	"""Try to load the background image if it exists"""
	var bg_path = "res://assets/sprites/backgrounds/main_menu_bg.png"

	if FileAccess.file_exists(bg_path):
		var texture = load(bg_path) as Texture2D
		if texture:
			background_image.texture = texture
			background_image.visible = true
			print("Main Menu: Background image loaded")
		else:
			print("Main Menu: Background image exists but failed to load")
	else:
		print("Main Menu: No background image found, using fallback color")
		# BackgroundFallback ColorRect is already visible by default

func _setup_menu_panel_borders() -> void:
	"""Setup cyan border and yellow corner brackets for menu panel"""
	# Connect draw signals
	cyan_border.draw.connect(_draw_cyan_border)
	yellow_bracket_tl.draw.connect(_draw_bracket_top_left)
	yellow_bracket_tr.draw.connect(_draw_bracket_top_right)
	yellow_bracket_bl.draw.connect(_draw_bracket_bottom_left)
	yellow_bracket_br.draw.connect(_draw_bracket_bottom_right)

	# Queue redraws
	cyan_border.queue_redraw()
	yellow_bracket_tl.queue_redraw()
	yellow_bracket_tr.queue_redraw()
	yellow_bracket_bl.queue_redraw()
	yellow_bracket_br.queue_redraw()

func _draw_cyan_border() -> void:
	"""Draw cyan rectangular border around menu panel"""
	var panel_size = menu_panel.size
	var border_width = 2.0

	# Draw rectangle outline
	cyan_border.draw_rect(
		Rect2(Vector2.ZERO, panel_size),
		COLOR_CYAN,
		false,
		border_width
	)

func _draw_bracket_top_left() -> void:
	"""Draw yellow L-bracket in top-left corner"""
	var bracket_length = 45.0
	var line_width = 3.0

	# Top line (horizontal)
	yellow_bracket_tl.draw_line(
		Vector2(0, 0),
		Vector2(bracket_length, 0),
		COLOR_YELLOW,
		line_width
	)

	# Left line (vertical)
	yellow_bracket_tl.draw_line(
		Vector2(0, 0),
		Vector2(0, bracket_length),
		COLOR_YELLOW,
		line_width
	)

func _draw_bracket_top_right() -> void:
	"""Draw yellow L-bracket in top-right corner"""
	var bracket_length = 45.0
	var line_width = 3.0
	var width = 50.0  # Control width

	# Top line (horizontal)
	yellow_bracket_tr.draw_line(
		Vector2(width - bracket_length, 0),
		Vector2(width, 0),
		COLOR_YELLOW,
		line_width
	)

	# Right line (vertical)
	yellow_bracket_tr.draw_line(
		Vector2(width, 0),
		Vector2(width, bracket_length),
		COLOR_YELLOW,
		line_width
	)

func _draw_bracket_bottom_left() -> void:
	"""Draw yellow L-bracket in bottom-left corner"""
	var bracket_length = 45.0
	var line_width = 3.0
	var height = 50.0  # Control height

	# Left line (vertical)
	yellow_bracket_bl.draw_line(
		Vector2(0, height - bracket_length),
		Vector2(0, height),
		COLOR_YELLOW,
		line_width
	)

	# Bottom line (horizontal)
	yellow_bracket_bl.draw_line(
		Vector2(0, height),
		Vector2(bracket_length, height),
		COLOR_YELLOW,
		line_width
	)

func _draw_bracket_bottom_right() -> void:
	"""Draw yellow L-bracket in bottom-right corner"""
	var bracket_length = 45.0
	var line_width = 3.0
	var width = 50.0  # Control width
	var height = 50.0  # Control height

	# Right line (vertical)
	yellow_bracket_br.draw_line(
		Vector2(width, height - bracket_length),
		Vector2(width, height),
		COLOR_YELLOW,
		line_width
	)

	# Bottom line (horizontal)
	yellow_bracket_br.draw_line(
		Vector2(width - bracket_length, height),
		Vector2(width, height),
		COLOR_YELLOW,
		line_width
	)

func _setup_button_styles() -> void:
	"""Apply custom styling to buttons"""
	# Continue button (green accent)
	_apply_button_border(continue_button, COLOR_GREEN, 4.0)

	# New Game, Load Game (cyan accent)
	_apply_button_border(new_game_button, COLOR_CYAN, 4.0)
	_apply_button_border(load_game_button, COLOR_CYAN, 4.0)

	# Settings (white accent)
	_apply_button_border(settings_button, COLOR_WHITE, 4.0)

	# Quit button (red accent)
	_apply_button_border(quit_button, COLOR_RED, 4.0)
	var quit_stylebox = quit_button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	quit_stylebox.set_border_width_all(4)
	quit_stylebox.border_color = COLOR_RED
	quit_button.add_theme_color_override("font_color", COLOR_RED)

func _apply_button_border(button: Button, border_color: Color, border_width: float) -> void:
	"""Apply a colored left border to a button"""
	var stylebox_normal = StyleBoxFlat.new()
	stylebox_normal.bg_color = Color(0.2, 0.2, 0.25, 0.8)
	stylebox_normal.border_width_left = int(border_width)
	stylebox_normal.border_color = border_color
	stylebox_normal.content_margin_left = 15
	stylebox_normal.content_margin_top = 10
	stylebox_normal.content_margin_right = 15
	stylebox_normal.content_margin_bottom = 10

	var stylebox_hover = stylebox_normal.duplicate() as StyleBoxFlat
	stylebox_hover.bg_color = Color(0.25, 0.25, 0.3, 0.9)

	var stylebox_pressed = stylebox_normal.duplicate() as StyleBoxFlat
	stylebox_pressed.bg_color = Color(0.15, 0.15, 0.2, 1.0)

	var stylebox_disabled = stylebox_normal.duplicate() as StyleBoxFlat
	stylebox_disabled.bg_color = Color(0.1, 0.1, 0.15, 0.5)
	stylebox_disabled.border_color = COLOR_GRAY

	button.add_theme_stylebox_override("normal", stylebox_normal)
	button.add_theme_stylebox_override("hover", stylebox_hover)
	button.add_theme_stylebox_override("pressed", stylebox_pressed)
	button.add_theme_stylebox_override("disabled", stylebox_disabled)

# ============================================================================
# SYSTEM STATUS
# ============================================================================

func _update_system_status() -> void:
	"""Check backend service availability and update status display"""
	# Check each service asynchronously
	_check_service("gateway", gateway_label)
	_check_service("ai", ai_label)
	_check_service("whisper", whisper_label)

func _check_service(service_name: String, label: Label) -> void:
	"""Check if a service is available"""
	var status = await ServiceManager.check_service(service_name)

	if status.available:
		label.text = "%s: ● OK" % service_name.capitalize()
		label.add_theme_color_override("font_color", COLOR_GREEN)
	else:
		label.text = "%s: ● OFFLINE" % service_name.capitalize()
		label.add_theme_color_override("font_color", COLOR_RED)

# ============================================================================
# SAVE INFO
# ============================================================================

func _update_save_info() -> void:
	"""Update save info display and Continue button state"""
	var recent_slot = SaveManager.get_most_recent_save()

	if recent_slot == -1:
		# No save found
		save_info_label.text = "No save data found"
		save_time_label.text = ""
		continue_button.disabled = true
		return

	# Load save metadata
	var save_data = SaveManager.get_save_info(recent_slot)
	if save_data.is_empty():
		save_info_label.text = "No save data found"
		save_time_label.text = ""
		continue_button.disabled = true
		return

	# Enable Continue button
	continue_button.disabled = false

	# Format save info
	var player_name = save_data.get("player_name", "Unknown")
	var level = save_data.get("player_level", 1)
	var rank = save_data.get("player_rank", "Cadet")
	var ship_name = save_data.get("ship_name", "Unnamed Vessel")
	var ship_class = save_data.get("ship_class", "None")

	save_info_label.text = "Player: %s | Level %d %s | Ship: %s (%s)" % [
		player_name, level, rank, ship_name, ship_class
	]

	# Calculate time ago
	var last_played = save_data.get("timestamp", 0.0)
	if last_played > 0:
		var now = Time.get_unix_time_from_system()
		var diff = now - last_played
		var hours = int(diff / 3600.0)
		var minutes = int(fmod(diff, 3600.0) / 60.0)

		if hours == 0 and minutes < 1:
			save_time_label.text = "Last played: Less than 1 minute ago"
		elif hours == 0:
			save_time_label.text = "Last played: %d minute%s ago" % [minutes, "s" if minutes != 1 else ""]
		elif hours == 1:
			save_time_label.text = "Last played: 1 hour ago"
		elif hours < 24:
			save_time_label.text = "Last played: %d hours ago" % hours
		else:
			var days = int(hours / 24)
			save_time_label.text = "Last played: %d day%s ago" % [days, "s" if days != 1 else ""]
	else:
		save_time_label.text = ""

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_continue_pressed() -> void:
	"""Load most recent save and continue"""
	var recent_save = SaveManager.get_most_recent_save()
	if recent_save == -1:
		EventBus.notify("No save file found", "error")
		return

	print("Main Menu: Loading save slot %d..." % recent_save)

	if SaveManager.load_game(recent_save):
		print("Main Menu: Save loaded, navigating to workshop...")
		get_tree().change_scene_to_file("res://scenes/workshop.tscn")
	else:
		EventBus.notify("Failed to load save file", "error")

func _on_new_game_pressed() -> void:
	"""Start a new game"""
	print("Main Menu: Starting new game...")

	# Reset game state to defaults
	GameState.reset_to_new_game()

	# Navigate to workshop (tutorial will auto-start if needed)
	get_tree().change_scene_to_file("res://scenes/workshop.tscn")

func _on_load_game_pressed() -> void:
	"""Open load game screen"""
	print("Main Menu: Opening load game screen...")
	get_tree().change_scene_to_file("res://scenes/load_game.tscn")

func _on_settings_pressed() -> void:
	"""Open settings (placeholder)"""
	EventBus.notify("Settings coming soon", "info")
	print("Main Menu: Settings not implemented yet")

func _on_quit_pressed() -> void:
	"""Quit the game"""
	print("Main Menu: Quitting game...")
	get_tree().quit()

# ============================================================================
# BUTTON HOVER EFFECTS
# ============================================================================

func _on_button_mouse_entered(button_path: NodePath) -> void:
	"""Brighten button on hover"""
	var button = get_node(button_path) as Button
	if button and not button.disabled:
		var tween = create_tween()
		tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2), 0.15)

func _on_button_mouse_exited(button_path: NodePath) -> void:
	"""Reset button brightness on hover exit"""
	var button = get_node(button_path) as Button
	if button:
		var tween = create_tween()
		tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

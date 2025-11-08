extends Control

## Workshop UI - Complete Redesign
## Main hub for ship building and system management
## Matches Penpot mockup design specification

# ============================================================================
# COLOR PALETTE (Penpot Design Spec)
# ============================================================================

const COLOR_BG = Color(0.102, 0.114, 0.180)  # #1a1d2e
const COLOR_BG_PANEL = Color(0.145, 0.157, 0.216)  # #252837
const COLOR_CYAN = Color(0.0, 0.898, 1.0)  # #00e5ff
const COLOR_GREEN = Color(0.0, 1.0, 0.533)  # #00ff88
const COLOR_YELLOW = Color(1.0, 0.733, 0.0)  # #ffbb00
const COLOR_RED = Color(1.0, 0.267, 0.267)  # #ff4444
const COLOR_WHITE = Color(1.0, 1.0, 1.0)
const COLOR_GRAY = Color(0.69, 0.69, 0.69)  # #b0b0b0

# ============================================================================
# SYSTEM ORDER (exact order for grid display)
# ============================================================================

const SYSTEM_ORDER = [
	"hull",
	"propulsion",
	"sensors",
	"weapons",
	"shields",
	"life_support",
	"communications",
	"warp",
	"computer",
	"power"
]

const SYSTEM_DISPLAY_NAMES = {
	"hull": "Hull & Structure",
	"propulsion": "Engines",
	"sensors": "Sensors",
	"weapons": "Weapons",
	"shields": "Shields",
	"life_support": "Life Support",
	"communications": "Communications",
	"warp": "Warp Drive",
	"computer": "Computer Core",
	"power": "Power Core"
}

# ============================================================================
# UI NODE REFERENCES
# ============================================================================

# Header
@onready var title_label: Label = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/TopRow/TitleLabel
@onready var ship_name_label: Label = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/TopRow/ShipNameLabel
@onready var credits_label: Label = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/TopRow/StatsHBox/CreditsLabel
@onready var level_label: Label = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/TopRow/StatsHBox/LevelLabel
@onready var xp_label: Label = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/BottomRow/XPVBox/XPLabel
@onready var xp_bar: ProgressBar = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/BottomRow/XPVBox/XPBar
@onready var skill_points_label: Label = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/BottomRow/SkillPointsBadge/MarginContainer/SkillPointsLabel
@onready var skill_points_badge: PanelContainer = $MainContainer/ContentVBox/HeaderPanel/MarginContainer/VBox/BottomRow/SkillPointsBadge

# Panels (for styling)
@onready var header_panel: PanelContainer = $MainContainer/ContentVBox/HeaderPanel
@onready var schematic_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/SchematicPanel
@onready var power_budget_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel
@onready var systems_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/CenterColumn/SystemsPanel
@onready var inventory_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/RightColumn/InventoryPanel
@onready var upgrades_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/RightColumn/UpgradesPanel
@onready var actions_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/RightColumn/ActionsPanel
@onready var bottom_panel: PanelContainer = $MainContainer/ContentVBox/BottomPanel

# Left Column
@onready var schematic_area: Control = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/SchematicPanel/MarginContainer/VBox/SchematicArea
@onready var power_circle: ProgressBar = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel/MarginContainer/VBox/CenterContainer/PowerMeterContainer/PowerCircle
@onready var power_label: Label = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel/MarginContainer/VBox/CenterContainer/PowerMeterContainer/PowerLabel
@onready var generation_label: Label = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel/MarginContainer/VBox/StatsVBox/GenerationLabel
@onready var consumption_label: Label = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel/MarginContainer/VBox/StatsVBox/ConsumptionLabel
@onready var hull_label: Label = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel/MarginContainer/VBox/StatsVBox/HullLabel
@onready var hull_bar: ProgressBar = $MainContainer/ContentVBox/MainContentHBox/LeftColumn/PowerBudgetPanel/MarginContainer/VBox/StatsVBox/HullBar

# Center Column
@onready var systems_grid: GridContainer = $MainContainer/ContentVBox/MainContentHBox/CenterColumn/SystemsPanel/MarginContainer/VBox/ScrollContainer/SystemsGrid

# Right Column
@onready var inventory_grid: GridContainer = $MainContainer/ContentVBox/MainContentHBox/RightColumn/InventoryPanel/MarginContainer/VBox/InventoryGrid
@onready var upgrades_list: VBoxContainer = $MainContainer/ContentVBox/MainContentHBox/RightColumn/UpgradesPanel/MarginContainer/VBox/UpgradesList
@onready var manage_crew_button: Button = $MainContainer/ContentVBox/MainContentHBox/RightColumn/ActionsPanel/MarginContainer/VBox/ManageCrewButton

# AI Chat Panel
@onready var ai_chat_panel: PanelContainer = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel
@onready var agent_selector: OptionButton = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel/MarginContainer/VBox/HeaderHBox/AgentSelector
@onready var chat_history: ScrollContainer = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel/MarginContainer/VBox/ChatHistory
@onready var messages_vbox: VBoxContainer = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel/MarginContainer/VBox/ChatHistory/MessagesVBox
@onready var message_input: LineEdit = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel/MarginContainer/VBox/InputHBox/MessageInput
@onready var send_button: Button = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel/MarginContainer/VBox/InputHBox/SendButton
@onready var status_label: Label = $MainContainer/ContentVBox/MainContentHBox/ChatColumn/AIChatPanel/MarginContainer/VBox/StatusLabel

# AI Chat State
var current_agent: String = "atlas"
var conversation_id: String = ""
var is_sending: bool = false

# Agent names map
const AGENT_NAMES = ["atlas", "storyteller", "tactical", "companion"]

# Schematic system dots (created dynamically)
var system_dots: Dictionary = {}

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("Workshop UI initialized (new design)")

	# Apply color theme
	_apply_color_theme()

	# Create ship schematic dots
	_create_schematic_dots()

	# Connect to EventBus signals
	_connect_signals()

	# Initialize AI chat
	_initialize_ai_chat()

	# Initial UI update
	_update_all_displays()

func _apply_color_theme() -> void:
	"""Apply color palette and semi-transparent panels"""
	# Header title
	title_label.add_theme_color_override("font_color", COLOR_CYAN)

	# Credits
	credits_label.add_theme_color_override("font_color", COLOR_YELLOW)

	# XP Bar
	var xp_stylebox = StyleBoxFlat.new()
	xp_stylebox.bg_color = COLOR_CYAN
	xp_bar.add_theme_stylebox_override("fill", xp_stylebox)

	# Skill Points Badge (green background when > 0)
	var skill_badge_style = StyleBoxFlat.new()
	skill_badge_style.bg_color = COLOR_GREEN
	skill_badge_style.corner_radius_top_left = 4
	skill_badge_style.corner_radius_top_right = 4
	skill_badge_style.corner_radius_bottom_left = 4
	skill_badge_style.corner_radius_bottom_right = 4
	skill_points_badge.add_theme_stylebox_override("panel", skill_badge_style)

	# Hull Bar
	var hull_stylebox = StyleBoxFlat.new()
	hull_stylebox.bg_color = COLOR_GREEN
	hull_bar.add_theme_stylebox_override("fill", hull_stylebox)

	# Semi-transparent panels with rounded corners and borders
	_apply_panel_style(header_panel, Color(0.1, 0.12, 0.15, 0.75))
	_apply_panel_style(schematic_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(power_budget_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(systems_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(inventory_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(upgrades_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(actions_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(ai_chat_panel, Color(0.08, 0.1, 0.13, 0.7))
	_apply_panel_style(bottom_panel, Color(0.1, 0.12, 0.15, 0.75))

func _apply_panel_style(panel: PanelContainer, bg_color: Color) -> void:
	"""Apply semi-transparent style with border to a panel"""
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = bg_color

	# Rounded corners
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8

	# Subtle border
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.2, 0.3, 0.4, 0.5)  # Subtle cyan tint

	panel.add_theme_stylebox_override("panel", panel_style)

func _connect_signals() -> void:
	"""Connect to EventBus signals for reactive updates"""
	EventBus.credits_changed.connect(_on_credits_changed)
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.level_up.connect(_on_level_up)
	EventBus.skill_allocated.connect(_on_skill_allocated)
	EventBus.system_installed.connect(_on_system_changed)
	EventBus.system_upgraded.connect(_on_system_changed)
	EventBus.system_damaged.connect(_on_system_damaged)
	EventBus.system_repaired.connect(_on_system_repaired)
	EventBus.ship_power_changed.connect(_on_power_changed)
	EventBus.item_added.connect(_on_inventory_changed)
	EventBus.item_removed.connect(_on_inventory_changed)

# ============================================================================
# SHIP SCHEMATIC (Top-down view with system dots)
# ============================================================================

func _create_schematic_dots() -> void:
	"""Create clickable dots for each ship system on schematic"""
	# Simple layout: 10 dots arranged in a grid pattern
	# This is a placeholder - can be replaced with actual ship image later

	var dot_positions = {
		"hull": Vector2(185, 185),  # Center
		"power": Vector2(185, 220),  # Below center
		"propulsion": Vector2(185, 255),  # Bottom
		"warp": Vector2(185, 150),  # Top
		"life_support": Vector2(150, 185),  # Left
		"computer": Vector2(220, 185),  # Right
		"sensors": Vector2(150, 150),  # Top-left
		"shields": Vector2(220, 150),  # Top-right
		"weapons": Vector2(150, 220),  # Bottom-left
		"communications": Vector2(220, 220)  # Bottom-right
	}

	for system_name in dot_positions:
		var dot = Button.new()
		dot.custom_minimum_size = Vector2(16, 16)
		dot.position = dot_positions[system_name] - Vector2(8, 8)  # Center the dot
		dot.tooltip_text = SYSTEM_DISPLAY_NAMES[system_name]

		# Style as colored circle
		var dot_style = StyleBoxFlat.new()
		dot_style.bg_color = COLOR_RED  # Default offline
		dot_style.corner_radius_top_left = 8
		dot_style.corner_radius_top_right = 8
		dot_style.corner_radius_bottom_left = 8
		dot_style.corner_radius_bottom_right = 8
		dot.add_theme_stylebox_override("normal", dot_style)
		dot.add_theme_stylebox_override("hover", dot_style)
		dot.add_theme_stylebox_override("pressed", dot_style)

		# Connect click signal
		dot.pressed.connect(_on_schematic_dot_clicked.bind(system_name))

		schematic_area.add_child(dot)
		system_dots[system_name] = dot

	print("Created %d schematic dots" % system_dots.size())

func _on_schematic_dot_clicked(system_name: String) -> void:
	"""Handle clicking a system dot - scroll to system card"""
	print("Clicked schematic dot: %s" % system_name)
	# TODO: Scroll to and highlight corresponding system card
	# For now, just print message
	EventBus.notify("Selected: %s" % SYSTEM_DISPLAY_NAMES[system_name])

# ============================================================================
# UPDATE FUNCTIONS
# ============================================================================

func _update_all_displays() -> void:
	"""Update all UI elements from GameState"""
	_update_header()
	_update_ship_schematic()
	_update_power_budget()
	_update_systems_grid()
	_update_inventory()
	_update_upgrades()
	_update_action_buttons()

func _update_header() -> void:
	"""Update header stats (credits, level, XP, skill points)"""
	# Ship name and class
	ship_name_label.text = "%s (%s)" % [GameState.ship.name, GameState.ship.ship_class]

	# Credits
	credits_label.text = "%s CR" % _format_number(GameState.player.credits)

	# Level
	level_label.text = "LEVEL %d" % GameState.player.level

	# XP
	var current_xp = GameState.player.xp
	var xp_to_next = GameState.player.xp_to_next_level
	xp_label.text = "%d / %d XP" % [current_xp, xp_to_next]
	xp_bar.max_value = float(xp_to_next)
	xp_bar.value = float(current_xp)

	# Skill Points
	var skill_points = GameState.get_available_skill_points()
	skill_points_label.text = "%d SKILLPOINT%s" % [skill_points, "S" if skill_points != 1 else ""]

	# Glow effect if skill points > 0
	if skill_points > 0:
		skill_points_badge.modulate = Color(1.2, 1.2, 1.0)  # Slight glow
	else:
		skill_points_badge.modulate = Color(1.0, 1.0, 1.0)

func _update_ship_schematic() -> void:
	"""Update system dots on schematic based on system status"""
	for system_name in system_dots:
		var dot = system_dots[system_name]
		var system = GameState.ship.systems[system_name]
		var status = _get_system_status(system)
		var color = _get_status_color(status)

		# Update dot color
		var dot_style = StyleBoxFlat.new()
		dot_style.bg_color = color
		dot_style.corner_radius_top_left = 8
		dot_style.corner_radius_top_right = 8
		dot_style.corner_radius_bottom_left = 8
		dot_style.corner_radius_bottom_right = 8
		dot.add_theme_stylebox_override("normal", dot_style)
		dot.add_theme_stylebox_override("hover", dot_style)
		dot.add_theme_stylebox_override("pressed", dot_style)

func _update_power_budget() -> void:
	"""Update power budget display"""
	var total = GameState.ship.power_total
	var consumption = GameState.ship.power_consumption
	var available = GameState.ship.power_available

	# Power meter
	power_circle.max_value = float(max(total, 1))  # Avoid division by zero
	power_circle.value = float(max(0, total - consumption))

	# Power labels
	power_label.text = "%d / %d" % [available, total]
	generation_label.text = "Generation: +%d PU" % total
	generation_label.add_theme_color_override("font_color", COLOR_GREEN)

	consumption_label.text = "Consumption: -%d PU" % consumption
	consumption_label.add_theme_color_override("font_color", COLOR_YELLOW)

	# Color meter based on available power
	var meter_style = StyleBoxFlat.new()
	if available >= 0:
		meter_style.bg_color = COLOR_GREEN
	else:
		meter_style.bg_color = COLOR_RED
	power_circle.add_theme_stylebox_override("fill", meter_style)

	# Hull HP
	var hull_hp = GameState.ship.hull_hp
	var max_hull_hp = GameState.ship.max_hull_hp
	hull_label.text = "Hull: %d / %d HP" % [hull_hp, max_hull_hp]
	hull_bar.max_value = float(max(max_hull_hp, 1))
	hull_bar.value = float(hull_hp)

	# Color hull bar
	var hull_percent = float(hull_hp) / float(max(max_hull_hp, 1))
	var hull_style = StyleBoxFlat.new()
	if hull_percent > 0.75:
		hull_style.bg_color = COLOR_GREEN
		hull_label.add_theme_color_override("font_color", COLOR_GREEN)
	elif hull_percent > 0.25:
		hull_style.bg_color = COLOR_YELLOW
		hull_label.add_theme_color_override("font_color", COLOR_YELLOW)
	else:
		hull_style.bg_color = COLOR_RED
		hull_label.add_theme_color_override("font_color", COLOR_RED)
	hull_bar.add_theme_stylebox_override("fill", hull_style)

func _update_systems_grid() -> void:
	"""Populate systems grid with all 10 system cards"""
	# Clear existing cards
	for child in systems_grid.get_children():
		child.queue_free()

	# Create card for each system in order
	for system_name in SYSTEM_ORDER:
		var system = GameState.ship.systems[system_name]
		var card = _create_system_card(system_name, system)
		systems_grid.add_child(card)

	print("Updated %d system cards" % SYSTEM_ORDER.size())

func _create_system_card(system_name: String, system: Dictionary) -> PanelContainer:
	"""Create a system card UI element"""
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(330, 100)

	# Card background style with left border
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = COLOR_BG_PANEL
	card_style.border_width_left = 4

	var status = _get_system_status(system)
	card_style.border_color = _get_status_color(status)

	card.add_theme_stylebox_override("panel", card_style)

	# Card content
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)

	# System icon placeholder (colored square)
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.color = _get_status_color(status)
	hbox.add_child(icon)

	# System info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 3)
	hbox.add_child(info_vbox)

	# Name
	var name_label = Label.new()
	name_label.text = SYSTEM_DISPLAY_NAMES[system_name]
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", COLOR_WHITE)
	info_vbox.add_child(name_label)

	# Level display
	var level_hbox = HBoxContainer.new()
	level_hbox.add_theme_constant_override("separation", 5)
	info_vbox.add_child(level_hbox)

	var level_text = Label.new()
	level_text.text = "Level %d" % system.level
	level_text.add_theme_font_size_override("font_size", 14)
	level_text.add_theme_color_override("font_color", COLOR_GRAY)
	level_hbox.add_child(level_text)

	# Level pips (5 squares)
	for i in range(5):
		var pip = ColorRect.new()
		pip.custom_minimum_size = Vector2(12, 12)
		if i < system.level:
			pip.color = COLOR_CYAN
		else:
			pip.color = Color(0.3, 0.3, 0.3)
		level_hbox.add_child(pip)

	# Status label
	var status_label = Label.new()
	status_label.text = status
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", _get_status_color(status))
	info_vbox.add_child(status_label)

	# Health bar if degraded
	if status == "DEGRADED":
		var health_bar = ProgressBar.new()
		health_bar.custom_minimum_size = Vector2(0, 6)
		health_bar.max_value = float(system.max_health)
		health_bar.value = float(system.health)
		health_bar.show_percentage = false
		info_vbox.add_child(health_bar)

	# Power cost badge (top-right)
	if system.level > 0 and system_name != "power":
		var power_cost = _get_system_power_cost(system_name, system.level)
		if power_cost > 0:
			var power_badge = Label.new()
			power_badge.text = "-%d PU" % power_cost
			power_badge.add_theme_font_size_override("font_size", 12)
			power_badge.add_theme_color_override("font_color", COLOR_YELLOW)
			hbox.add_child(power_badge)

	# Upgrade button or MAX label
	var can_upgrade = system.level < 5
	if can_upgrade:
		var upgrade_btn = Button.new()
		upgrade_btn.custom_minimum_size = Vector2(100, 40)
		upgrade_btn.text = "UPGRADE"
		upgrade_btn.add_theme_font_size_override("font_size", 14)
		upgrade_btn.pressed.connect(_on_upgrade_system_pressed.bind(system_name))

		# Check affordability
		if has_node("/root/PartRegistry"):
			var cost_data = PartRegistry.get_upgrade_cost(system_name, system.level + 1, "")
			if not cost_data.is_empty():
				var affordable = cost_data.get("affordable", false)
				var have_part = cost_data.get("have_part", false)
				upgrade_btn.disabled = not (affordable and have_part)

				if not affordable:
					upgrade_btn.modulate = Color(1.0, 0.5, 0.5)  # Red tint
				elif not have_part:
					upgrade_btn.modulate = Color(1.0, 0.8, 0.5)  # Yellow tint

		hbox.add_child(upgrade_btn)
	else:
		var max_label = Label.new()
		max_label.text = "MAX"
		max_label.add_theme_font_size_override("font_size", 14)
		max_label.add_theme_color_override("font_color", COLOR_GRAY)
		hbox.add_child(max_label)

	return card

func _update_inventory() -> void:
	"""Update inventory grid (4x4 preview)"""
	# Clear existing slots
	for child in inventory_grid.get_children():
		child.queue_free()

	# Create 16 slots (4x4)
	var inventory = GameState.inventory
	var part_counts = {}

	# Count parts by part_id
	for item in inventory:
		var part_id = item.get("part_id", "")
		if part_id != "":
			if not part_counts.has(part_id):
				part_counts[part_id] = 0
			part_counts[part_id] += item.get("quantity", 1)

	var unique_parts = part_counts.keys()

	for i in range(16):
		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(64, 64)

		var slot_style = StyleBoxFlat.new()
		if i < unique_parts.size():
			# Filled slot
			slot_style.bg_color = Color(0.2, 0.2, 0.3)
			slot_style.border_width_left = 2
			slot_style.border_width_right = 2
			slot_style.border_width_top = 2
			slot_style.border_width_bottom = 2
			slot_style.border_color = COLOR_CYAN

			# Show part icon placeholder
			var icon = ColorRect.new()
			icon.color = COLOR_WHITE  # White icon for contrast against dark background
			slot.add_child(icon)

			# Quantity badge
			var qty_label = Label.new()
			qty_label.text = "+%d" % part_counts[unique_parts[i]]
			qty_label.add_theme_font_size_override("font_size", 10)
			qty_label.add_theme_color_override("font_color", Color.BLACK)  # Black for contrast on white icon
			qty_label.position = Vector2(40, 2)
			slot.add_child(qty_label)

			# Make clickable
			var btn = Button.new()
			btn.modulate = Color(1, 1, 1, 0)  # Invisible overlay
			btn.pressed.connect(_on_inventory_slot_clicked.bind(unique_parts[i]))
			slot.add_child(btn)
		else:
			# Empty slot
			slot_style.bg_color = Color(0.1, 0.1, 0.15)

		slot.add_theme_stylebox_override("panel", slot_style)
		inventory_grid.add_child(slot)

func _update_upgrades() -> void:
	"""Update available upgrades list"""
	# Clear existing
	for child in upgrades_list.get_children():
		child.queue_free()

	# Find upgradeable systems
	var upgradeable = []
	for system_name in SYSTEM_ORDER:
		var system = GameState.ship.systems[system_name]
		if system.level < 5:
			if has_node("/root/PartRegistry"):
				var cost_data = PartRegistry.get_upgrade_cost(system_name, system.level + 1, "")
				if not cost_data.is_empty() and cost_data.get("have_part", false):
					upgradeable.append({
						"system": system_name,
						"cost": cost_data.get("credits", 0),
						"part": cost_data.get("part_name", ""),
						"affordable": cost_data.get("affordable", false)
					})

	# Show top 3
	var count = min(3, upgradeable.size())
	for i in range(count):
		var upgrade = upgradeable[i]
		var item = Label.new()
		item.text = "%s\n%d CR | %s" % [
			SYSTEM_DISPLAY_NAMES[upgrade.system],
			upgrade.cost,
			upgrade.part
		]
		item.add_theme_font_size_override("font_size", 12)
		if upgrade.affordable:
			item.add_theme_color_override("font_color", COLOR_WHITE)
		else:
			item.add_theme_color_override("font_color", COLOR_GRAY)
		upgrades_list.add_child(item)

	# Show "No upgrades" if empty
	if upgradeable.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No upgrades available"
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", COLOR_GRAY)
		upgrades_list.add_child(empty_label)

func _update_action_buttons() -> void:
	"""Update action button states (e.g., lock Manage Crew)"""
	# Lock crew management if player level < 5
	if GameState.player.level < 5:
		manage_crew_button.disabled = true
		manage_crew_button.tooltip_text = "Requires Level 5"
	else:
		manage_crew_button.disabled = false
		manage_crew_button.tooltip_text = ""

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _get_system_status(system: Dictionary) -> String:
	"""Determine system status string"""
	var level = system.get("level", 0)
	var health = system.get("health", 100)
	var max_health = system.get("max_health", 100)

	if level == 0 or health == 0:
		return "OFFLINE"
	elif health < max_health:
		return "DEGRADED"
	else:
		return "OPERATIONAL"

func _get_status_color(status: String) -> Color:
	"""Get color for system status"""
	match status:
		"OPERATIONAL":
			return COLOR_GREEN
		"DEGRADED":
			return COLOR_YELLOW
		"OFFLINE":
			return COLOR_RED
		_:
			return COLOR_GRAY

func _get_system_power_cost(system_name: String, level: int) -> int:
	"""Get power cost for a system at a given level"""
	const POWER_COSTS = {
		"hull": [0, 0, 0, 0, 10],
		"power": [0, 0, 0, 0, 0],
		"propulsion": [10, 15, 25, 40, 60],
		"warp": [20, 30, 50, 80, 120],
		"life_support": [5, 10, 15, 25, 35],
		"computer": [5, 10, 20, 35, 50],
		"sensors": [5, 10, 20, 35, 50],
		"shields": [15, 25, 40, 60, 85],
		"weapons": [10, 20, 35, 55, 80],
		"communications": [5, 8, 12, 18, 25]
	}

	if not POWER_COSTS.has(system_name):
		return 0

	var costs = POWER_COSTS[system_name]
	var index = level - 1
	if index >= 0 and index < costs.size():
		return costs[index]
	return 0

func _format_number(num: int) -> String:
	"""Format number with commas (e.g., 1250 -> 1,250)"""
	var s = str(num)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count == 3:
			result = "," + result
			count = 0
		result = s[i] + result
		count += 1
	return result

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_upgrade_system_pressed(system_name: String) -> void:
	"""Handle upgrade button click for a system"""
	print("Upgrade requested: %s" % system_name)

	# Get current system data
	var system = GameState.ship.systems[system_name]
	if system.level >= 5:
		print("System already at max level")
		return

	# Get upgrade cost
	if not has_node("/root/PartRegistry"):
		print("PartRegistry not available")
		return

	var cost_data = PartRegistry.get_upgrade_cost(system_name, system.level + 1, "")
	if cost_data.is_empty() or not cost_data.get("success", false):
		print("Failed to get upgrade cost")
		return

	var credits = cost_data.get("credits", 0)
	var part_id = cost_data.get("part_id", "")
	var part_name = cost_data.get("part_name", "")

	# Check affordability
	if not GameState.can_afford(credits):
		EventBus.notify("Insufficient credits: Need %d CR" % credits, "error")
		return

	if not GameState.has_part(part_id):
		EventBus.notify("Missing part: %s" % part_name, "error")
		return

	# Perform upgrade
	if not GameState.spend_credits(credits):
		return

	if not GameState.consume_item(part_id, 1):
		GameState.add_credits(credits)  # Refund
		return

	# Update system
	GameState.install_system(system_name, system.level + 1, part_id)
	EventBus.notify("Upgraded %s to Level %d" % [SYSTEM_DISPLAY_NAMES[system_name], system.level + 1])

	# Save game
	SaveManager.auto_save()

	# Refresh UI
	_update_all_displays()

func _on_inventory_slot_clicked(part_id: String) -> void:
	"""Handle clicking an inventory slot"""
	print("Clicked inventory slot: %s" % part_id)

	# Show part details (stub)
	if has_node("/root/PartRegistry"):
		var part = PartRegistry.get_part(part_id)
		if not part.is_empty():
			var msg = "%s\n%s\nWeight: %.1f kg" % [
				part.get("name", "Unknown"),
				part.get("description", ""),
				part.get("weight", 0.0)
			]
			EventBus.notify(msg, "info", 5.0)

func _on_view_all_inventory_pressed() -> void:
	"""Open full inventory view"""
	print("View All Inventory pressed")
	# TODO: Open inventory popup/scene
	EventBus.notify("Full inventory view - Coming soon!")

func _on_shop_pressed() -> void:
	"""Open shop interface"""
	print("Shop pressed")
	# TODO: Open shop scene
	EventBus.notify("Shop - Coming soon!")

func _on_launch_missions_pressed() -> void:
	"""Launch mission selection"""
	print("Launch Missions pressed")

	# Auto-save before changing scenes
	SaveManager.auto_save()

	# Change to mission selection scene
	get_tree().change_scene_to_file("res://scenes/mission_selection.tscn")

func _on_manage_crew_pressed() -> void:
	"""Open crew management"""
	print("Manage Crew pressed")
	# TODO: Open crew management scene
	EventBus.notify("Crew management - Coming soon!")

func _on_shipyard_pressed() -> void:
	"""Open shipyard view"""
	print("Shipyard pressed")
	# TODO: Open shipyard scene
	EventBus.notify("Shipyard - Coming soon!")

func _on_save_pressed() -> void:
	"""Manual save game"""
	print("Save Game pressed")

	var success = SaveManager.save_game(1)
	if success:
		EventBus.notify("Game saved successfully", "success")
	else:
		EventBus.notify("Failed to save game", "error")

func _on_settings_pressed() -> void:
	"""Open settings"""
	print("Settings pressed")
	# TODO: Open settings menu
	EventBus.notify("Settings - Coming soon!")

func _on_main_menu_pressed() -> void:
	"""Return to main menu"""
	print("Main Menu pressed")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ============================================================================
# EVENT BUS HANDLERS
# ============================================================================

func _on_credits_changed(_new_amount: int) -> void:
	"""Handle credits changed"""
	_update_header()
	_update_systems_grid()  # Refresh upgrade button states
	_update_upgrades()

func _on_xp_gained(_amount: int, _source: String) -> void:
	"""Handle XP gained"""
	_update_header()

func _on_level_up(_new_level: int, _skill_points: int) -> void:
	"""Handle level up"""
	_update_header()
	_update_action_buttons()
	EventBus.notify("Level Up! You are now Level %d" % _new_level, "success", 5.0)

func _on_skill_allocated(_skill_name: String, _new_value: int) -> void:
	"""Handle skill point allocated"""
	_update_header()

func _on_system_changed(_system_name: String, _new_level: int) -> void:
	"""Handle system installed/upgraded"""
	_update_all_displays()

func _on_system_damaged(_system_name: String, _damage: int, _new_health: int) -> void:
	"""Handle system damaged"""
	_update_ship_schematic()
	_update_systems_grid()

func _on_system_repaired(_system_name: String, _repair: int, _new_health: int) -> void:
	"""Handle system repaired"""
	_update_ship_schematic()
	_update_systems_grid()

func _on_power_changed(_available: int, _total: int, _consumption: int) -> void:
	"""Handle ship power changed"""
	_update_power_budget()

func _on_inventory_changed(_item: Dictionary) -> void:
	"""Handle inventory item added/removed"""
	_update_inventory()
	_update_upgrades()
	_update_systems_grid()  # Refresh upgrade availability

# ============================================================================
# AI CHAT SYSTEM
# ============================================================================

func _initialize_ai_chat() -> void:
	"""Initialize AI chat panel"""
	# Generate conversation ID
	conversation_id = "workshop_%d" % Time.get_unix_time_from_system()

	# Set initial agent
	current_agent = "atlas"
	agent_selector.selected = 0

	# Update placeholder text
	_update_chat_placeholder()

	# Add welcome message
	_add_chat_message("System", "AI Assistant ready. Select an agent and start chatting!", COLOR_CYAN)

	print("AI Chat initialized with conversation ID: %s" % conversation_id)

func _update_chat_placeholder() -> void:
	"""Update message input placeholder based on selected agent"""
	match current_agent:
		"atlas":
			message_input.placeholder_text = "Ask ATLAS about ship systems..."
		"storyteller":
			message_input.placeholder_text = "Ask Storyteller about missions..."
		"tactical":
			message_input.placeholder_text = "Ask Tactical for combat advice..."
		"companion":
			message_input.placeholder_text = "Chat with your Companion..."

func _add_chat_message(sender: String, text: String, color: Color = COLOR_WHITE) -> void:
	"""Add a message to the chat history"""
	var message_container = VBoxContainer.new()
	message_container.add_theme_constant_override("separation", 5)

	# Sender label
	var sender_label = Label.new()
	sender_label.text = sender + ":"
	sender_label.add_theme_font_size_override("font_size", 12)
	sender_label.add_theme_color_override("font_color", color)
	message_container.add_child(sender_label)

	# Message label with word wrap
	var message_label = Label.new()
	message_label.text = text
	message_label.add_theme_font_size_override("font_size", 14)
	message_label.add_theme_color_override("font_color", COLOR_WHITE)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_container.add_child(message_label)

	# Add to messages
	messages_vbox.add_child(message_container)

	# Scroll to bottom (wait one frame for layout)
	await get_tree().process_frame
	chat_history.scroll_vertical = int(chat_history.get_v_scroll_bar().max_value)

func _set_chat_status(text: String, color: Color = COLOR_WHITE) -> void:
	"""Update chat status label"""
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)

func _on_agent_selected(index: int) -> void:
	"""Handle agent selection changed"""
	if index >= 0 and index < AGENT_NAMES.size():
		current_agent = AGENT_NAMES[index]
		_update_chat_placeholder()
		print("Selected agent: %s" % current_agent)

func _on_message_input_changed(new_text: String) -> void:
	"""Handle message input text changed"""
	send_button.disabled = new_text.strip_edges().is_empty() or is_sending

func _on_message_submitted(_new_text: String) -> void:
	"""Handle Enter key pressed in message input"""
	if not is_sending and not message_input.text.strip_edges().is_empty():
		_send_chat_message()

func _on_send_message_pressed() -> void:
	"""Handle send button clicked"""
	_send_chat_message()

func _send_chat_message() -> void:
	"""Send message to AI orchestrator"""
	var message = message_input.text.strip_edges()

	if message.is_empty() or is_sending:
		return

	# Clear input
	message_input.text = ""
	send_button.disabled = true
	is_sending = true

	# Add user message to chat
	_add_chat_message("You", message, COLOR_CYAN)
	_set_chat_status("Sending...", COLOR_YELLOW)

	print("Sending message to %s: %s" % [current_agent, message])

	# Send to AI service
	var result = await AIService.chat_with_agent(
		current_agent,
		message,
		conversation_id,
		true  # include_functions
	)

	# Handle response
	is_sending = false

	if result.success and result.data.has("response"):
		var response = result.data.response
		var agent_display = current_agent.capitalize()

		# Add AI response
		_add_chat_message(agent_display, response, COLOR_GREEN)
		_set_chat_status("Ready", COLOR_GREEN)

		# Check for function calls
		if result.data.has("function_call"):
			var func_call = result.data.function_call
			var func_name = func_call.get("name", "unknown")
			_add_chat_message("System", "Executed function: %s" % func_name, COLOR_YELLOW)

		print("Received response from %s (%d chars)" % [current_agent, response.length()])
	else:
		var error = result.get("error", "Unknown error")
		_add_chat_message("Error", error, COLOR_RED)
		_set_chat_status("Error", COLOR_RED)
		print("Error from AI service: %s" % error)

	# Re-enable send button if input has text
	_on_message_input_changed(message_input.text)

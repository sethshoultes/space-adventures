extends Control

## Workshop Scene
## Main hub for ship building and system upgrades
## Player spends most of Phase 1 here

# UI References
@onready var ship_name_label: Label = $MarginContainer/VBoxContainer/Header/ShipName
@onready var power_generation_label: Label = $MarginContainer/VBoxContainer/PowerBudget/MarginContainer/VBoxContainer/PowerGeneration
@onready var power_consumption_label: Label = $MarginContainer/VBoxContainer/PowerBudget/MarginContainer/VBoxContainer/PowerConsumption
@onready var power_available_label: Label = $MarginContainer/VBoxContainer/PowerBudget/MarginContainer/VBoxContainer/PowerAvailable
@onready var hull_hp_label: Label = $MarginContainer/VBoxContainer/PowerBudget/MarginContainer/VBoxContainer/HullHP

# Player Status Panel UI
@onready var credits_label: Label = $MarginContainer/VBoxContainer/PlayerStatusPanel/MarginContainer/HBoxContainer/CreditsContainer/CreditsLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/PlayerStatusPanel/MarginContainer/HBoxContainer/LevelContainer/LevelLabel
@onready var xp_label: Label = $MarginContainer/VBoxContainer/PlayerStatusPanel/MarginContainer/HBoxContainer/XPContainer/XPLabel
@onready var xp_progress_bar: ProgressBar = $MarginContainer/VBoxContainer/PlayerStatusPanel/MarginContainer/HBoxContainer/XPContainer/XPProgressBar
@onready var skill_points_button: Button = $MarginContainer/VBoxContainer/PlayerStatusPanel/MarginContainer/HBoxContainer/SkillPointsButton
@onready var inventory_button: Button = $MarginContainer/VBoxContainer/PlayerStatusPanel/MarginContainer/HBoxContainer/InventoryButton

# Hull System UI
@onready var hull_status: Label = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/Info/Status
@onready var hull_description: Label = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/Info/Description
@onready var hull_cost_label: Label = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/Info/CostLabel
@onready var hull_upgrade_button: Button = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/UpgradeButton

# Power System UI
@onready var power_status: Label = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/Info/Status
@onready var power_description: Label = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/Info/Description
@onready var power_cost_label: Label = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/Info/CostLabel
@onready var power_upgrade_button: Button = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/UpgradeButton

# Propulsion System UI
@onready var propulsion_status: Label = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/Info/Status
@onready var propulsion_description: Label = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/Info/Description
@onready var propulsion_cost_label: Label = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/Info/CostLabel
@onready var propulsion_upgrade_button: Button = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/UpgradeButton

# Inventory Popup UI
@onready var inventory_popup: PopupPanel = $InventoryPopup
@onready var inventory_list: VBoxContainer = $InventoryPopup/MarginContainer/VBoxContainer/ScrollContainer/InventoryList
@onready var inventory_weight_label: Label = $InventoryPopup/MarginContainer/VBoxContainer/Header/WeightLabel

# Skill Allocation Popup UI
@onready var skill_allocation_popup: PopupPanel = $SkillAllocationPopup
@onready var skill_title_label: Label = $SkillAllocationPopup/MarginContainer/VBoxContainer/TitleLabel
@onready var engineering_skill_label: Label = $SkillAllocationPopup/MarginContainer/VBoxContainer/EngineeringRow/SkillLabel
@onready var engineering_allocate_button: Button = $SkillAllocationPopup/MarginContainer/VBoxContainer/EngineeringRow/AllocateButton
@onready var diplomacy_skill_label: Label = $SkillAllocationPopup/MarginContainer/VBoxContainer/DiplomacyRow/SkillLabel
@onready var diplomacy_allocate_button: Button = $SkillAllocationPopup/MarginContainer/VBoxContainer/DiplomacyRow/AllocateButton
@onready var combat_skill_label: Label = $SkillAllocationPopup/MarginContainer/VBoxContainer/CombatRow/SkillLabel
@onready var combat_allocate_button: Button = $SkillAllocationPopup/MarginContainer/VBoxContainer/CombatRow/AllocateButton
@onready var science_skill_label: Label = $SkillAllocationPopup/MarginContainer/VBoxContainer/ScienceRow/SkillLabel
@onready var science_allocate_button: Button = $SkillAllocationPopup/MarginContainer/VBoxContainer/ScienceRow/AllocateButton

# Ship system instances
var hull_system: HullSystem
var power_system: PowerSystem
var propulsion_system: PropulsionSystem

func _ready() -> void:
	print("Workshop initialized")

	# Create ship system instances from GameState
	_load_ship_systems()

	# Connect to EventBus signals - System events
	EventBus.system_upgraded.connect(_on_system_upgraded)
	EventBus.game_saved.connect(_on_game_saved)

	# Connect to EventBus signals - Economy events
	EventBus.credits_changed.connect(_on_credits_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.skill_allocated.connect(_on_skill_allocated)
	EventBus.part_discovered.connect(_on_part_discovered)
	EventBus.inventory_full.connect(_on_inventory_full)

	# Initial UI update
	_update_all_displays()

func _load_ship_systems() -> void:
	"""Load ship systems from GameState"""

	# Create system instances and load from GameState
	hull_system = HullSystem.new()
	hull_system.from_dict(GameState.ship.systems.hull)

	power_system = PowerSystem.new()
	power_system.from_dict(GameState.ship.systems.power)

	propulsion_system = PropulsionSystem.new()
	propulsion_system.from_dict(GameState.ship.systems.propulsion)

	print("Loaded ship systems: Hull L%d, Power L%d, Propulsion L%d" % [
		hull_system.level,
		power_system.level,
		propulsion_system.level
	])

func _update_all_displays() -> void:
	"""Update all UI elements"""
	_update_player_status()
	_update_ship_info()
	_update_power_budget()
	_update_system_display("hull", hull_system, hull_status, hull_description, hull_cost_label, hull_upgrade_button)
	_update_system_display("power", power_system, power_status, power_description, power_cost_label, power_upgrade_button)
	_update_system_display("propulsion", propulsion_system, propulsion_status, propulsion_description, propulsion_cost_label, propulsion_upgrade_button)

func _update_player_status() -> void:
	"""Update player status display (credits, level, XP, skill points)"""
	# Update credits
	credits_label.text = "%d CR" % GameState.player.credits

	# Update level
	level_label.text = str(GameState.player.level)

	# Update XP
	var current_xp = GameState.player.xp
	var xp_to_next = GameState.player.xp_to_next_level
	xp_label.text = "%d / %d XP" % [current_xp, xp_to_next]

	# Update XP progress bar
	xp_progress_bar.max_value = float(xp_to_next)
	xp_progress_bar.value = float(current_xp)

	# Update skill points button
	var skill_points = GameState.get_available_skill_points()
	skill_points_button.text = "Skill Points: %d" % skill_points

	# Highlight button if skill points available
	if skill_points > 0:
		skill_points_button.modulate = Color(1.0, 1.0, 0.5)  # Yellow highlight
	else:
		skill_points_button.modulate = Color(1.0, 1.0, 1.0)  # Normal

func _update_ship_info() -> void:
	"""Update ship name and class"""
	ship_name_label.text = "%s (%s)" % [GameState.ship.name, GameState.ship.ship_class]

func _update_power_budget() -> void:
	"""Update power budget display"""
	power_generation_label.text = "Power Generation: %d PU" % GameState.ship.power_total
	power_consumption_label.text = "Power Consumption: %d PU" % GameState.ship.power_consumption

	var available = GameState.ship.power_available
	var color = "green" if available >= 0 else "red"
	power_available_label.text = "[color=%s]Available Power: %d PU[/color]" % [color, available]
	power_available_label.modulate = Color.GREEN if available >= 0 else Color.RED

	hull_hp_label.text = "Hull Integrity: %d/%d HP" % [GameState.ship.hull_hp, GameState.ship.max_hull_hp]

func _update_system_display(system_name: String, system: ShipSystem, status_label: Label, desc_label: Label, cost_label: Label, button: Button) -> void:
	"""Update a system's UI display"""

	# Update status label
	var level = system.level
	var status_text = "Level %d: %s" % [level, system.get_status()]

	if level > 0:
		var power_cost = system.get_power_cost()
		if power_cost > 0:
			status_text += " (-%d PU)" % power_cost
		elif system_name == "power":
			status_text += " (+%d PU)" % power_system.get_power_output()

	status_label.text = status_text

	# Update description
	desc_label.text = system.get_description()

	# Update cost label and upgrade button
	if system.can_upgrade():
		var next_level = level + 1

		# Check if PartRegistry is available
		if has_node("/root/PartRegistry"):
			# Get upgrade cost from PartRegistry
			var cost_data = PartRegistry.get_upgrade_cost(system_name, next_level, "")

			if not cost_data.is_empty():
				var credits_cost = cost_data.get("credits", 0)
				var part_name = cost_data.get("part_name", "Unknown Part")
				var affordable = cost_data.get("affordable", false)
				var have_part = cost_data.get("have_part", false)

				# Show cost
				cost_label.text = "Cost: %d CR + %s" % [credits_cost, part_name]
				cost_label.visible = true

				# Enable/disable button based on affordability
				button.disabled = not (affordable and have_part)
				button.text = "UPGRADE"

				# Color code button
				if not affordable:
					button.modulate = Color(1.0, 0.5, 0.5)  # Red tint (insufficient credits)
				elif not have_part:
					button.modulate = Color(1.0, 0.8, 0.5)  # Yellow tint (missing part)
				else:
					button.modulate = Color(1.0, 1.0, 1.0)  # Normal (can afford)
			else:
				# Fallback to simple cost
				var cost = _get_upgrade_cost(system_name, next_level)
				cost_label.text = "Cost: %d CR" % cost
				cost_label.visible = true
				button.text = "UPGRADE"
				button.disabled = false
		else:
			# Fallback: no PartRegistry
			var cost = _get_upgrade_cost(system_name, next_level)
			cost_label.text = "Cost: %d CR" % cost
			cost_label.visible = true
			button.text = "UPGRADE"
			button.disabled = false
	else:
		cost_label.visible = false
		button.text = "MAX LEVEL"
		button.disabled = true

func _get_upgrade_cost(system_name: String, target_level: int) -> int:
	"""Calculate upgrade cost for a system level"""
	# Simple cost formula: base cost * level squared
	const BASE_COSTS = {
		"hull": 100,
		"power": 150,
		"propulsion": 100
	}

	var base = BASE_COSTS.get(system_name, 100)
	return base * target_level * target_level

# ============================================================================
# INVENTORY & SKILL POPUP FUNCTIONS
# ============================================================================

func _on_inventory_button_pressed() -> void:
	"""Open inventory popup"""
	inventory_popup.popup_centered()
	_populate_inventory()

func _populate_inventory() -> void:
	"""Populate inventory list with parts"""
	# Clear existing items
	for child in inventory_list.get_children():
		child.queue_free()

	# Get inventory from GameState
	var inventory = GameState.inventory

	if inventory.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventory is empty"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inventory_list.add_child(empty_label)
	else:
		# Group by part_id and sum quantities
		var part_counts = {}
		for item in inventory:
			var part_id = item.get("part_id", "")
			if part_id != "":
				if not part_counts.has(part_id):
					part_counts[part_id] = {"count": 0, "item": item}
				part_counts[part_id].count += item.get("quantity", 1)

		# Display each part type
		for part_id in part_counts:
			var data = part_counts[part_id]
			var part_data = {}

			# Get part name from PartRegistry if available
			if has_node("/root/PartRegistry"):
				part_data = PartRegistry.get_part(part_id)

			var part_name = part_data.get("name", part_id)
			var part_weight = part_data.get("weight", 1.0)
			var part_rarity = part_data.get("rarity", "common")

			var row = HBoxContainer.new()

			var name_label = Label.new()
			name_label.text = part_name
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(name_label)

			var rarity_label = Label.new()
			rarity_label.text = "[%s]" % part_rarity.capitalize()
			rarity_label.add_theme_color_override("font_color", _get_rarity_color(part_rarity))
			row.add_child(rarity_label)

			var qty_label = Label.new()
			qty_label.text = "x%d" % data.count
			row.add_child(qty_label)

			var weight_label = Label.new()
			weight_label.text = "%.1f kg" % (part_weight * data.count)
			row.add_child(weight_label)

			inventory_list.add_child(row)

	# Update weight display
	var current_weight = GameState.get_total_inventory_weight()
	var max_weight = GameState.get_inventory_capacity()
	inventory_weight_label.text = "Weight: %.1f / %.1f kg" % [current_weight, max_weight]

	# Color code weight label
	var weight_percent = current_weight / max_weight if max_weight > 0 else 0.0
	if weight_percent >= 1.0:
		inventory_weight_label.add_theme_color_override("font_color", Color.RED)
	elif weight_percent >= 0.75:
		inventory_weight_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		inventory_weight_label.add_theme_color_override("font_color", Color.GREEN)

func _get_rarity_color(rarity: String) -> Color:
	"""Get color for rarity tier"""
	match rarity:
		"common":
			return Color.GRAY
		"uncommon":
			return Color.GREEN
		"rare":
			return Color.CYAN
		"legendary":
			return Color.GOLD
		_:
			return Color.WHITE

func _on_inventory_close_pressed() -> void:
	"""Close inventory popup"""
	inventory_popup.hide()

func _on_skill_points_button_pressed() -> void:
	"""Open skill allocation popup"""
	skill_allocation_popup.popup_centered()
	_update_skill_allocation_display()

func _update_skill_allocation_display() -> void:
	"""Update skill allocation popup display"""
	var available_points = GameState.get_available_skill_points()
	skill_title_label.text = "Allocate Skill Points (%d available)" % available_points

	# Update skill labels
	engineering_skill_label.text = "Engineering: %d" % GameState.player.skills.engineering
	diplomacy_skill_label.text = "Diplomacy: %d" % GameState.player.skills.diplomacy
	combat_skill_label.text = "Combat: %d" % GameState.player.skills.combat
	science_skill_label.text = "Science: %d" % GameState.player.skills.science

	# Enable/disable buttons
	var can_allocate = available_points > 0
	engineering_allocate_button.disabled = not can_allocate
	diplomacy_allocate_button.disabled = not can_allocate
	combat_allocate_button.disabled = not can_allocate
	science_allocate_button.disabled = not can_allocate

func _on_allocate_skill_pressed(skill_name: String) -> void:
	"""Allocate a skill point to a specific skill"""
	if GameState.allocate_skill_point(skill_name):
		_update_skill_allocation_display()
		_update_player_status()  # Update main UI
		print("Allocated skill point to %s" % skill_name)
	else:
		print("Failed to allocate skill point to %s" % skill_name)

func _on_skill_allocation_close_pressed() -> void:
	"""Close skill allocation popup"""
	skill_allocation_popup.hide()

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_hull_upgrade_pressed() -> void:
	print("Upgrading Hull system")

	if hull_system.upgrade():
		# Update GameState
		GameState.install_system("hull", hull_system.level)

		# Auto-save after upgrade
		SaveManager.auto_save()

		# Update UI
		_update_all_displays()

		print("Hull upgraded to Level %d" % hull_system.level)
	else:
		print("Cannot upgrade Hull system")

func _on_power_upgrade_pressed() -> void:
	print("Upgrading Power Core")

	if power_system.upgrade():
		# Update GameState
		GameState.install_system("power", power_system.level)

		# Auto-save after upgrade
		SaveManager.auto_save()

		# Update UI
		_update_all_displays()

		print("Power Core upgraded to Level %d" % power_system.level)
	else:
		print("Cannot upgrade Power Core")

func _on_propulsion_upgrade_pressed() -> void:
	print("Upgrading Propulsion system")

	if propulsion_system.upgrade():
		# Update GameState
		GameState.install_system("propulsion", propulsion_system.level)

		# Auto-save after upgrade
		SaveManager.auto_save()

		# Update UI
		_update_all_displays()

		print("Propulsion upgraded to Level %d" % propulsion_system.level)
	else:
		print("Cannot upgrade Propulsion system")

func _on_save_pressed() -> void:
	print("Manual save requested")

	var success = SaveManager.save_game(1)

	if success:
		print("Game saved successfully")
		# TODO: Show save confirmation UI
	else:
		print("Save failed")
		# TODO: Show error UI

func _on_missions_pressed() -> void:
	print("Launching tutorial mission")

	# Start the tutorial mission
	var mission_started = MissionManager.start_mission("tutorial_first_salvage")

	if mission_started:
		# Auto-save before starting mission
		SaveManager.auto_save()

		# Load mission scene
		get_tree().change_scene_to_file("res://scenes/mission.tscn")
	else:
		print("Failed to start mission")

func _on_main_menu_pressed() -> void:
	print("Returning to main menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ============================================================================
# EVENT BUS HANDLERS
# ============================================================================

func _on_system_upgraded(system_name: String, new_level: int) -> void:
	print("EventBus: System upgraded: %s to Level %d" % [system_name, new_level])
	_update_all_displays()

func _on_game_saved(slot: int, _timestamp: float) -> void:
	print("EventBus: Game saved to slot %d" % slot)
	# TODO: Show save confirmation

func _on_credits_changed(new_amount: int) -> void:
	"""Handle credits changed event"""
	print("EventBus: Credits changed to %d" % new_amount)
	_update_player_status()
	_update_all_displays()  # Update upgrade button states

func _on_level_up(new_level: int, skill_points_gained: int) -> void:
	"""Handle level up event"""
	print("EventBus: Level up! New level: %d, gained %d skill points" % [new_level, skill_points_gained])
	_update_player_status()

	# Automatically open skill allocation popup if skill points gained
	if skill_points_gained > 0:
		skill_allocation_popup.popup_centered()
		_update_skill_allocation_display()

func _on_xp_gained(amount: int, source: String) -> void:
	"""Handle XP gained event"""
	print("EventBus: XP gained: +%d from %s" % [amount, source])
	_update_player_status()

func _on_skill_allocated(skill_name: String, new_value: int) -> void:
	"""Handle skill allocated event"""
	print("EventBus: Skill allocated: %s = %d" % [skill_name, new_value])
	_update_player_status()

func _on_part_discovered(part_id: String, part_name: String) -> void:
	"""Handle part discovered event"""
	print("EventBus: Part discovered: %s (%s)" % [part_name, part_id])
	# TODO: Show notification

func _on_inventory_full() -> void:
	"""Handle inventory full event"""
	print("EventBus: Inventory is full!")
	# TODO: Show warning notification

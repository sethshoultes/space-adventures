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

# Hull System UI
@onready var hull_status: Label = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/Info/Status
@onready var hull_description: Label = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/Info/Description
@onready var hull_upgrade_button: Button = $MarginContainer/VBoxContainer/SystemsContainer/HullSystem/MarginContainer/HBoxContainer/UpgradeButton

# Power System UI
@onready var power_status: Label = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/Info/Status
@onready var power_description: Label = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/Info/Description
@onready var power_upgrade_button: Button = $MarginContainer/VBoxContainer/SystemsContainer/PowerSystem/MarginContainer/HBoxContainer/UpgradeButton

# Propulsion System UI
@onready var propulsion_status: Label = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/Info/Status
@onready var propulsion_description: Label = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/Info/Description
@onready var propulsion_upgrade_button: Button = $MarginContainer/VBoxContainer/SystemsContainer/PropulsionSystem/MarginContainer/HBoxContainer/UpgradeButton

# Ship system instances
var hull_system: HullSystem
var power_system: PowerSystem
var propulsion_system: PropulsionSystem

func _ready() -> void:
	print("Workshop initialized")

	# Create ship system instances from GameState
	_load_ship_systems()

	# Connect to EventBus signals
	EventBus.system_upgraded.connect(_on_system_upgraded)
	EventBus.game_saved.connect(_on_game_saved)

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
	_update_ship_info()
	_update_power_budget()
	_update_system_display("hull", hull_system, hull_status, hull_description, hull_upgrade_button)
	_update_system_display("power", power_system, power_status, power_description, power_upgrade_button)
	_update_system_display("propulsion", propulsion_system, propulsion_status, propulsion_description, propulsion_upgrade_button)

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

func _update_system_display(system_name: String, system: ShipSystem, status_label: Label, desc_label: Label, button: Button) -> void:
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

	# Update upgrade button
	if system.can_upgrade():
		var next_level = level + 1
		var cost = _get_upgrade_cost(system_name, next_level)
		button.text = "UPGRADE TO L%d\n(Cost: %d credits)" % [next_level, cost]
		button.disabled = false
	else:
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

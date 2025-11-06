extends Control

## Main Menu Scene
## Test scene for Phase 1, Week 3 - Godot Foundation
## Tests all autoload singletons and service connectivity

@onready var service_status_label: Label = $CenterContainer/VBoxContainer/ServiceStatus
@onready var game_state_label: Label = $CenterContainer/VBoxContainer/GameStateInfo
@onready var output_log: RichTextLabel = $Output

var chat_session_id: String = ""

func _ready() -> void:
	log_output("[b]Main Menu Initialized[/b]")
	log_output("Testing autoload singletons...")

	# Test that all singletons are available
	_test_singletons()

	# Update UI
	_update_game_state_display()

	# Check service status
	await get_tree().create_timer(1.0).timeout
	_check_service_status()

	# Connect to EventBus signals
	_connect_event_bus()

func _test_singletons() -> void:
	"""Test that all autoload singletons are accessible"""
	var singletons = ["GameState", "SaveManager", "ServiceManager", "AIService", "EventBus"]

	for singleton_name in singletons:
		if has_node("/root/" + singleton_name):
			log_output("[color=green]✓[/color] %s loaded" % singleton_name)
		else:
			log_output("[color=red]✗[/color] %s FAILED TO LOAD" % singleton_name)

func _connect_event_bus() -> void:
	"""Connect to EventBus signals for testing"""
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.level_up.connect(_on_level_up)
	EventBus.system_installed.connect(_on_system_installed)
	EventBus.game_saved.connect(_on_game_saved)
	EventBus.game_loaded.connect(_on_game_loaded)
	EventBus.chat_message_received.connect(_on_chat_message_received)

	log_output("[color=green]✓[/color] Connected to EventBus signals")

func _check_service_status() -> void:
	"""Check backend service availability"""
	log_output("\n[b]Checking backend services...[/b]")

	var results = await ServiceManager.check_all_services()

	var status_text = ""
	var all_ok = true

	for service_name in results:
		var status = results[service_name]
		if status.available:
			status_text += "%s: [color=green]OK[/color]\n" % service_name.capitalize()
			log_output("[color=green]✓[/color] %s service: AVAILABLE" % service_name.capitalize())
		else:
			status_text += "%s: [color=red]OFFLINE[/color]\n" % service_name.capitalize()
			log_output("[color=red]✗[/color] %s service: UNAVAILABLE - %s" % [service_name.capitalize(), status.error])
			all_ok = false

	service_status_label.text = status_text.strip_edges()

	if all_ok:
		log_output("\n[color=green][b]✓ All services operational![/b][/color]")
	else:
		log_output("\n[color=yellow][b]⚠ Some services offline (check Docker)[/b][/color]")

func _update_game_state_display() -> void:
	"""Update game state display"""
	var player = GameState.player
	var ship = GameState.ship

	game_state_label.text = "Player: %s | Level %d %s | Ship: %s (%s)" % [
		player.name,
		player.level,
		player.rank,
		ship.name,
		ship.ship_class
	]

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_test_service_button_pressed() -> void:
	log_output("\n[b]Testing service connection...[/b]")
	_check_service_status()

func _on_test_chat_button_pressed() -> void:
	log_output("\n[b]Testing AI chat...[/b]")

	if not ServiceManager.is_service_available("ai"):
		log_output("[color=red]✗[/color] AI service not available")
		EventBus.error("Service Unavailable", "AI service is not running. Start Docker services.")
		return

	log_output("Sending chat message to ATLAS...")

	if chat_session_id == "":
		chat_session_id = "test_session_%d" % Time.get_unix_time_from_system()

	var result = await AIService.chat_message(
		"Hello ATLAS, this is a test message. Please respond briefly.",
		"atlas",
		chat_session_id
	)

	if result.success:
		log_output("[color=green]✓[/color] Chat successful!")
		if result.data.has("message"):
			log_output("[color=cyan]ATLAS:[/color] %s" % result.data.message)
		if result.data.has("cached") and result.data.cached:
			log_output("[color=yellow](Cached response)[/color]")
	else:
		log_output("[color=red]✗[/color] Chat failed: %s" % result.error)
		EventBus.error("Chat Failed", result.error)

func _on_test_mission_button_pressed() -> void:
	log_output("\n[b]Testing mission generation...[/b]")

	if not ServiceManager.is_service_available("ai"):
		log_output("[color=red]✗[/color] AI service not available")
		EventBus.error("Service Unavailable", "AI service is not running. Start Docker services.")
		return

	log_output("Generating medium difficulty mission...")

	var result = await AIService.generate_mission("medium", "salvage", "Old Earth Ruins")

	if result.success:
		log_output("[color=green]✓[/color] Mission generation successful!")

		if result.data.has("mission"):
			var mission = result.data.mission
			log_output("\n[b]Generated Mission:[/b]")
			log_output("  Title: %s" % mission.get("title", "Unknown"))
			log_output("  Type: %s" % mission.get("type", "Unknown"))
			log_output("  Difficulty: %s" % mission.get("difficulty", "Unknown"))
			log_output("  Location: %s" % mission.get("location", "Unknown"))

			if mission.has("description"):
				log_output("  Description: %s" % mission.description)

			if mission.has("stages"):
				log_output("  Stages: %d" % mission.stages.size())

		if result.data.has("cached") and result.data.cached:
			log_output("[color=yellow](Cached response)[/color]")

		if result.data.has("generation_time_ms"):
			log_output("  Generation time: %.2fms" % result.data.generation_time_ms)
	else:
		log_output("[color=red]✗[/color] Mission generation failed: %s" % result.error)
		EventBus.error("Mission Generation Failed", result.error)

func _on_test_dialogue_button_pressed() -> void:
	log_output("\n[b]Testing dialogue generation...[/b]")

	if not ServiceManager.is_service_available("ai"):
		log_output("[color=red]✗[/color] AI service not available")
		EventBus.error("Service Unavailable", "AI service is not running. Start Docker services.")
		return

	log_output("Generating NPC dialogue...")

	var result = await AIService.generate_dialogue(
		"Jax Morgan",
		"Salvage Yard Owner",
		"Player arrives at salvage yard looking for ship parts",
		"asks about available hull components"
	)

	if result.success:
		log_output("[color=green]✓[/color] Dialogue generation successful!")

		if result.data.has("dialogue"):
			log_output("\n[b]Generated Dialogue:[/b]")
			log_output("[color=cyan]Jax Morgan:[/color] %s" % result.data.dialogue)

		if result.data.has("cached") and result.data.cached:
			log_output("[color=yellow](Cached response)[/color]")

		if result.data.has("generation_time_ms"):
			log_output("  Generation time: %.2fms" % result.data.generation_time_ms)
	else:
		log_output("[color=red]✗[/color] Dialogue generation failed: %s" % result.error)
		EventBus.error("Dialogue Generation Failed", result.error)

func _on_test_save_button_pressed() -> void:
	log_output("\n[b]Testing save/load system...[/b]")

	# Modify game state
	log_output("Modifying game state...")
	GameState.add_xp(50, "test")
	GameState.increase_skill("engineering", 5)
	GameState.player.name = "Test Captain"
	GameState.ship.name = "USS Test Ship"
	_update_game_state_display()

	# Save game
	log_output("Saving to slot 1...")
	var save_result = SaveManager.save_game(1)
	if save_result:
		log_output("[color=green]✓[/color] Save successful!")
	else:
		log_output("[color=red]✗[/color] Save failed!")
		return

	# Load game
	await get_tree().create_timer(0.5).timeout
	log_output("Loading from slot 1...")
	var load_result = SaveManager.load_game(1)
	if load_result:
		log_output("[color=green]✓[/color] Load successful!")
		_update_game_state_display()
	else:
		log_output("[color=red]✗[/color] Load failed!")

	# Show save info
	var save_info = SaveManager.get_save_info(1)
	if not save_info.is_empty():
		log_output("\nSave file info:")
		log_output("  Player: %s (Level %d %s)" % [save_info.player_name, save_info.player_level, save_info.player_rank])
		log_output("  Ship: %s (%s)" % [save_info.ship_name, save_info.ship_class])
		log_output("  Missions: %d" % save_info.completed_missions)
		log_output("  Playtime: %s" % SaveManager.format_playtime(save_info.playtime_seconds))

func _on_test_hull_system_button_pressed() -> void:
	log_output("\n[b]=== Testing Hull System ===[/b]")

	# Create Hull system instance
	var hull = HullSystem.new()
	log_output("Created Hull system instance")

	# Test Level 0 (no hull)
	log_output("\n[b]Test: Level 0 (No Hull)[/b]")
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])
	log_output("  Status: %s" % hull.get_status())
	log_output("  Active: %s" % ("Yes" if hull.active else "No"))

	# Upgrade to Level 1
	log_output("\n[b]Test: Upgrade to Level 1 (Salvaged Hull)[/b]")
	hull.upgrade()
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])
	log_output("  Status: %s" % hull.get_status())
	log_output("  Active: %s" % ("Yes" if hull.active else "No"))
	log_output("  Kinetic Armor: %.0f%%" % (hull.armor_kinetic * 100))
	log_output("  Power Cost: %d PU" % hull.get_power_cost())
	log_output("  [color=green]✓[/color] Expected: 50 HP, 5% armor, 0 PU")

	# Test damage
	log_output("\n[b]Test: Take 20 kinetic damage[/b]")
	var reduced_damage = hull.take_hull_damage(20, "kinetic")
	log_output("  Damage after armor: %d (reduced from 20)" % reduced_damage)
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])
	log_output("  Expected reduction: ~5% = 19 damage")

	# Test repair
	log_output("\n[b]Test: Repair 10 HP[/b]")
	hull.repair(10)
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])

	# Upgrade to Level 2
	log_output("\n[b]Test: Upgrade to Level 2 (Reinforced Structure)[/b]")
	hull.upgrade()
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])
	log_output("  Kinetic Armor: %.0f%%" % (hull.armor_kinetic * 100))
	log_output("  [color=green]✓[/color] Expected: 100 HP, 15% armor")

	# Upgrade to Level 3
	log_output("\n[b]Test: Upgrade to Level 3 (Composite Armor)[/b]")
	hull.upgrade()
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])
	log_output("  Kinetic Armor: %.0f%%" % (hull.armor_kinetic * 100))
	log_output("  Energy Armor: %.0f%%" % (hull.armor_energy * 100))
	log_output("  Radiation Resist: %.0f%%" % (hull.radiation_resist * 100))
	log_output("  [color=green]✓[/color] Expected: 200 HP, 25% kinetic, 10% energy, 10% radiation")

	# Test energy damage
	log_output("\n[b]Test: Take 30 energy damage[/b]")
	var energy_reduced = hull.take_hull_damage(30, "energy")
	log_output("  Damage after armor: %d (reduced from 30)" % energy_reduced)
	log_output("  HP: %d/%d" % [hull.get_current_hp(), hull.get_max_hp()])
	log_output("  Expected reduction: ~10% = 27 damage")

	# Test GameState integration
	log_output("\n[b]Test: GameState Integration[/b]")
	log_output("  GameState max_hull_hp: %d" % GameState.ship.max_hull_hp)
	log_output("  GameState systems[hull].level: %d" % GameState.ship.systems.hull.level)
	log_output("  [color=green]✓[/color] Expected: 200 HP, Level 3")

	# Test detailed stats
	log_output("\n[b]Hull Stats:[/b]")
	var stats = hull.get_stats_string()
	log_output(stats)

	log_output("\n[color=green][b]✓ Hull System Tests Complete![/b][/color]")

func _on_quit_button_pressed() -> void:
	log_output("\n[b]Quitting...[/b]")
	get_tree().quit()

# ============================================================================
# EVENT BUS HANDLERS
# ============================================================================

func _on_xp_gained(amount: int, source: String) -> void:
	log_output("[color=cyan]Event:[/color] Gained %d XP (from: %s)" % [amount, source if source else "unknown"])

func _on_level_up(new_level: int, old_level: int) -> void:
	log_output("[color=green][b]Event:[/b] LEVEL UP! %d → %d[/color]" % [old_level, new_level])

func _on_system_installed(system_name: String, level: int) -> void:
	log_output("[color=cyan]Event:[/color] System installed: %s (Level %d)" % [system_name, level])

func _on_game_saved(slot: int, timestamp: float) -> void:
	log_output("[color=green]Event:[/color] Game saved to slot %d" % slot)

func _on_game_loaded(slot: int, _game_state: Dictionary) -> void:
	log_output("[color=green]Event:[/color] Game loaded from slot %d" % slot)

func _on_chat_message_received(ai_personality: String, message: String, _metadata: Dictionary) -> void:
	log_output("[color=cyan]Event:[/color] Chat message from %s: %s" % [ai_personality.to_upper(), message])

# ============================================================================
# UTILITY
# ============================================================================

func log_output(text: String) -> void:
	"""Add line to output log"""
	output_log.append_text(text + "\n")

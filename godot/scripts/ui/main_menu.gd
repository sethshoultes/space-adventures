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

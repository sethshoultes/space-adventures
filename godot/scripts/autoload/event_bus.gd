extends Node

## EventBus Singleton
## Decoupled event system for inter-component communication
## Any node can emit or connect to these signals without tight coupling

# ============================================================================
# MISSION EVENTS
# ============================================================================

## Emitted when a mission is completed
signal mission_completed(mission_id: String, rewards: Dictionary)

## Emitted when a mission is started
signal mission_started(mission_id: String, mission_data: Dictionary)

## Emitted when a mission stage advances
signal mission_stage_changed(mission_id: String, stage_id: String)

## Emitted when a mission fails
signal mission_failed(mission_id: String, reason: String)

# ============================================================================
# SHIP SYSTEM EVENTS
# ============================================================================

## Emitted when a ship system is installed or upgraded
signal system_installed(system_name: String, level: int)

## Emitted when a ship system is upgraded to a new level
signal system_upgraded(system_name: String, new_level: int)

## Emitted when a ship system is destroyed (health reaches 0)
signal system_destroyed(system_name: String)

## Emitted when a ship system is damaged
signal system_damaged(system_name: String, damage_amount: int, new_health: int)

## Emitted when a ship system is repaired
signal system_repaired(system_name: String, repair_amount: int, new_health: int)

## Emitted when ship class changes due to system configuration
signal ship_class_changed(old_class: String, new_class: String)

## Emitted when ship power state changes
signal ship_power_changed(available: int, total: int, consumption: int)

# ============================================================================
# PLAYER PROGRESSION EVENTS
# ============================================================================

## Emitted when player gains XP
signal xp_gained(amount: int, source: String)

## Emitted when player levels up
signal level_up(new_level: int, skill_points_gained: int)

## Emitted when player rank changes
signal rank_changed(new_rank: String, old_rank: String)

## Emitted when a skill increases
signal skill_increased(skill_name: String, new_value: int, old_value: int)

## Emitted when a skill point is allocated
signal skill_allocated(skill_name: String, new_value: int)

## Emitted when an achievement is unlocked
signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

# ============================================================================
# ECONOMY EVENTS
# ============================================================================

## Emitted when player's credits change
signal credits_changed(new_amount: int)

## Emitted when a part is discovered (unlocked for use)
signal part_discovered(part_id: String, part_name: String)

# ============================================================================
# INVENTORY EVENTS
# ============================================================================

## Emitted when an item is added to inventory
signal item_added(item: Dictionary)

## Emitted when an item is removed from inventory
signal item_removed(item: Dictionary)

## Emitted when an item is equipped/installed
signal item_equipped(item: Dictionary, slot: String)

## Emitted when an item is unequipped
signal item_unequipped(item: Dictionary, slot: String)

## Emitted when inventory reaches capacity
signal inventory_full()

# ============================================================================
# AI CHAT EVENTS
# ============================================================================

## Emitted when an AI chat message is received
signal chat_message_received(ai_personality: String, message: String, metadata: Dictionary)

## Emitted when player sends a chat message
signal chat_message_sent(message: String, ai_personality: String)

## Emitted when a spontaneous AI event occurs
signal spontaneous_event_triggered(event_data: Dictionary)

# ============================================================================
# GAME STATE EVENTS
# ============================================================================

## Emitted when game is saved
signal game_saved(slot: int, timestamp: float)

## Emitted when game is loaded
signal game_loaded(slot: int, game_state: Dictionary)

## Emitted when save/load fails
signal save_load_error(error_message: String)

## Emitted when game phase changes (e.g., Earth → Space)
signal phase_changed(new_phase: int, old_phase: int)

## Emitted when a major story choice is made
signal major_choice_made(choice_id: String, choice_data: Dictionary)

# ============================================================================
# UI EVENTS
# ============================================================================

## Emitted when a scene transition starts
signal scene_transition_started(from_scene: String, to_scene: String)

## Emitted when a scene transition completes
signal scene_transition_completed(scene_name: String)

## Emitted when a notification should be shown
signal show_notification(message: String, type: String, duration: float)

## Emitted when an error dialog should be shown
signal show_error(title: String, message: String)

## Emitted when a confirmation dialog is needed
signal show_confirmation(title: String, message: String, callback: Callable)

# ============================================================================
# VOICE INPUT EVENTS (Optional - Whisper Service)
# ============================================================================

## Emitted when voice input starts recording
signal voice_input_started()

## Emitted when voice input stops recording
signal voice_input_stopped()

## Emitted when voice transcription is received
signal voice_transcription_received(text: String)

## Emitted when voice input fails
signal voice_input_error(error_message: String)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _ready() -> void:
	print("EventBus initialized - Decoupled event system ready")

## Emit a notification event (convenience function)
func notify(message: String, type: String = "info", duration: float = 3.0) -> void:
	show_notification.emit(message, type, duration)

## Emit an error event (convenience function)
func error(title: String, message: String) -> void:
	push_error("EventBus Error: %s - %s" % [title, message])
	show_error.emit(title, message)

## Debug: List all connected signals for a specific signal name
func debug_connections(signal_name: String) -> void:
	var signal_list = get_signal_connection_list(signal_name)
	print("EventBus: Connections for '%s': %d" % [signal_name, signal_list.size()])
	for connection in signal_list:
		print("  - Target: %s, Method: %s" % [connection["target"], connection["method"]])

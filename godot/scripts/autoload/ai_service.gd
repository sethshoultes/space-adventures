extends Node

## AIService Singleton
## HTTP client for AI content generation via Gateway
## Handles missions, dialogue, chat, and spontaneous events

const GATEWAY_URL: String = "http://localhost:17010"
const AI_SERVICE_URL: String = "http://localhost:17011"
const REQUEST_TIMEOUT: float = 30.0

# HTTP request pool
var _http_requests: Array[HTTPRequest] = []
const MAX_CONCURRENT_REQUESTS: int = 5

func _ready() -> void:
	print("AIService initialized")
	print("Gateway URL: ", GATEWAY_URL)
	print("AI Service URL: ", AI_SERVICE_URL)

	# Pre-create HTTP request nodes
	for i in range(MAX_CONCURRENT_REQUESTS):
		var http = HTTPRequest.new()
		http.timeout = REQUEST_TIMEOUT
		add_child(http)
		_http_requests.append(http)

# ============================================================================
# MISSION GENERATION
# ============================================================================

## Generate a new mission using AI
func generate_mission(difficulty: String, mission_type: String = "", location: String = "") -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/missions/generate"

	var request_body = {
		"difficulty": difficulty,
		"mission_type": mission_type if mission_type != "" else null,
		"location": location if location != "" else null,
		"game_state": _prepare_game_state()
	}

	var result = await _make_post_request(url, request_body)
	return result

# ============================================================================
# CHAT & DIALOGUE
# ============================================================================

## Send chat message to AI personality
func chat_message(
	message: String,
	ai_personality: String = "atlas",
	session_id: String = "",
	conversation_context: Array = []
) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/chat/message"

	# Generate session ID if not provided
	if session_id == "":
		session_id = "session_%d" % Time.get_unix_time_from_system()

	var request_body = {
		"session_id": session_id,
		"message": message,
		"ai_personality": ai_personality,
		"conversation_context": conversation_context,
		"game_state": _prepare_game_state()
	}

	var result = await _make_post_request(url, request_body)

	# Emit event if successful
	if result.success and result.data.has("message"):
		EventBus.chat_message_sent.emit(message, ai_personality)
		EventBus.chat_message_received.emit(
			ai_personality,
			result.data.message,
			result.data
		)

	return result

## Generate NPC dialogue
func generate_dialogue(
	npc_name: String,
	npc_role: String,
	context: String,
	player_action: String = ""
) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/dialogue/generate"

	var request_body = {
		"npc_name": npc_name,
		"npc_role": npc_role,
		"context": context,
		"player_action": player_action if player_action != "" else null,
		"game_state": _prepare_game_state()
	}

	var result = await _make_post_request(url, request_body)
	return result

# ============================================================================
# AI ORCHESTRATOR (Multi-Agent System)
# ============================================================================

## Chat with a specific AI agent
## agent_name: "atlas", "storyteller", "tactical", or "companion"
## conversation_id: Optional conversation ID for persistence (generated if not provided)
func chat_with_agent(
	agent_name: String,
	message: String,
	conversation_id: String = "",
	include_functions: bool = true
) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/chat"

	# Generate conversation ID if not provided
	if conversation_id == "":
		conversation_id = "conv_%s_%d" % [agent_name, Time.get_unix_time_from_system()]

	var request_body = {
		"agent": agent_name,
		"message": message,
		"conversation_id": conversation_id,
		"include_functions": include_functions,
		"game_state": _prepare_game_state()
	}

	var result = await _make_post_request(url, request_body)

	# Emit events if successful
	if result.success and result.data.has("response"):
		EventBus.chat_message_sent.emit(message, agent_name)
		EventBus.chat_message_received.emit(
			agent_name,
			result.data.response,
			result.data
		)

	return result

## Intelligently route a message to the most appropriate agent
## The orchestrator will analyze the message and select the best agent
func route_message(
	message: String,
	conversation_id: String = ""
) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/route"

	# Generate conversation ID if not provided
	if conversation_id == "":
		conversation_id = "conv_routed_%d" % Time.get_unix_time_from_system()

	var request_body = {
		"message": message,
		"conversation_id": conversation_id,
		"game_state": _prepare_game_state()
	}

	var result = await _make_post_request(url, request_body)

	# Emit events if successful
	if result.success and result.data.has("response"):
		var agent = result.data.get("agent", "unknown")
		EventBus.chat_message_sent.emit(message, agent)
		EventBus.chat_message_received.emit(
			agent,
			result.data.response,
			result.data
		)

	return result

## Hand off conversation from one agent to another
## Preserves context during the transfer
func handoff_conversation(
	from_agent: String,
	to_agent: String,
	context: String,
	conversation_id: String = ""
) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/handoff"

	# Generate conversation ID if not provided
	if conversation_id == "":
		conversation_id = "conv_handoff_%d" % Time.get_unix_time_from_system()

	var request_body = {
		"from_agent": from_agent,
		"to_agent": to_agent,
		"context": context,
		"conversation_id": conversation_id
	}

	var result = await _make_post_request(url, request_body)

	# Emit events if successful
	if result.success and result.data.has("response"):
		EventBus.chat_message_received.emit(
			to_agent,
			result.data.response,
			result.data
		)

	return result

## Get list of available AI agents
func list_agents() -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/agents"

	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var error = http.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	return _parse_response(response)

## Get conversation history for a specific agent
func get_conversation_history(agent_name: String) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/history/" + agent_name

	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var error = http.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	return _parse_response(response)

## Clear conversation history (optionally for specific agent)
func clear_conversation_history(agent_name: String = "") -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/history"

	var request_body = {}
	if agent_name != "":
		request_body["agent"] = agent_name

	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(request_body)

	var error = http.request(url, headers, HTTPClient.METHOD_DELETE, json_body)
	if error != OK:
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	return _parse_response(response)

## Get orchestrator health status
func get_orchestrator_health() -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = AI_SERVICE_URL + "/api/orchestrator/health"

	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var error = http.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	return _parse_response(response)

# ============================================================================
# SPONTANEOUS EVENTS
# ============================================================================

## Check for spontaneous events (e.g., AI-driven random encounters)
func check_spontaneous_event() -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	# TODO: This endpoint needs to be implemented in the backend
	var url = AI_SERVICE_URL + "/api/events/spontaneous"

	var request_body = {
		"game_state": _prepare_game_state(),
		"event_probability": 0.3  # 30% chance
	}

	var result = await _make_post_request(url, request_body)

	# Emit event if one was generated
	if result.success and result.data.has("event_triggered") and result.data.event_triggered:
		EventBus.spontaneous_event_triggered.emit(result.data)

	return result

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

## Prepare game state for API requests (simplified for transmission)
func _prepare_game_state() -> Dictionary:
	return {
		"player": {
			"name": GameState.player.name,
			"level": GameState.player.level,
			"rank": GameState.player.rank,
			"skills": GameState.player.skills
		},
		"ship": {
			"name": GameState.ship.name,
			"ship_class": GameState.ship.ship_class,
			"operational_systems": GameState.get_operational_systems()
		},
		"progress": {
			"phase": GameState.progress.phase,
			"completed_missions_count": GameState.get_completed_missions_count()
		}
	}

## Make HTTP POST request
func _make_post_request(url: String, body: Dictionary) -> Dictionary:
	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)

	var error = http.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		return _error_response("Failed to send request: " + str(error))

	# Wait for response
	var response = await http.request_completed
	return _parse_response(response)

## Get an available HTTP request node
func _get_available_http_request() -> HTTPRequest:
	for http in _http_requests:
		if http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			return http
	# All busy, return first one anyway (may cause issues but better than failing)
	push_warning("AIService: All HTTP request slots busy")
	return _http_requests[0]

## Parse HTTP response
func _parse_response(response: Array) -> Dictionary:
	var result = response[0]
	var response_code = response[1]
	var _headers = response[2]
	var body = response[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		return _error_response("HTTP request failed: " + str(result))

	if response_code < 200 or response_code >= 300:
		var error_msg = "HTTP %d" % response_code
		# Try to parse error message from body
		if body.size() > 0:
			var json = JSON.new()
			var parse_result = json.parse(body.get_string_from_utf8())
			if parse_result == OK:
				var data = json.data
				if data is Dictionary and data.has("error"):
					error_msg += ": " + str(data.error)
		return _error_response(error_msg)

	# Parse JSON body
	if body.size() == 0:
		return _error_response("Empty response body")

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		return _error_response("Failed to parse JSON response: " + json.get_error_message())

	var data = json.data
	if not data is Dictionary:
		return _error_response("Response is not a dictionary")

	# Check if response indicates success
	if data.has("success"):
		if data.success:
			return {
				"success": true,
				"data": data,
				"error": ""
			}
		else:
			return _error_response(data.get("error", "Unknown error"))

	# Assume success if no "success" field but got valid JSON
	return {
		"success": true,
		"data": data,
		"error": ""
	}

## Create error response
func _error_response(error_message: String) -> Dictionary:
	push_warning("AIService Error: " + error_message)
	return {
		"success": false,
		"data": {},
		"error": error_message
	}

# ============================================================================
# TESTING & DEBUG
# ============================================================================

## Test connection to AI service
func test_connection() -> bool:
	print("AIService: Testing connection...")

	var status = await ServiceManager.check_service("ai")
	if status.available:
		print("AIService: Connection test PASSED")
		return true
	else:
		push_warning("AIService: Connection test FAILED - " + status.error)
		return false

## Get AI service health info
func get_health_info() -> Dictionary:
	return ServiceManager.get_service_status("ai")

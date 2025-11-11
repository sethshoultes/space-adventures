extends Node

## AIService Singleton
## HTTP client for AI content generation via Gateway
## Handles missions, dialogue, chat, and spontaneous events

const REQUEST_TIMEOUT: float = 30.0

# HTTP request pool
var _http_requests: Array[HTTPRequest] = []
const MAX_CONCURRENT_REQUESTS: int = 5
const MAX_QUEUE_CONCURRENCY: int = 2
const MAX_RETRIES: int = 3
const BACKOFF_BASE: float = 0.5

var _current_requests: int = 0
signal slot_freed

func _ready() -> void:
	print("AIService initialized")
	print("Gateway URL: ", ServiceManager.get_service_url("gateway"))
	print("AI Service URL: ", ServiceManager.get_service_url("ai"))
	randomize()

	# Pre-create HTTP request nodes
	for i in range(MAX_CONCURRENT_REQUESTS):
		var http = HTTPRequest.new()
		http.timeout = REQUEST_TIMEOUT
		add_child(http)
		_http_requests.append(http)

## Resolve AI endpoint base, preferring gateway when available
func _ai_endpoint(path: String) -> String:
	var base: String
	if ServiceManager.is_service_available("gateway"):
		base = ServiceManager.get_service_url("gateway") + "/api/v1/ai"
	else:
		base = ServiceManager.get_service_url("ai") + "/api"
	return base + path

## Build endpoint candidates in priority order
func _endpoint_candidates(path: String) -> Array[String]:
	var candidates: Array[String] = []
	var gateway_available = ServiceManager.is_service_available("gateway")
	var ai_available = ServiceManager.is_service_available("ai")
	var gateway = ServiceManager.get_service_url("gateway")
	var ai = ServiceManager.get_service_url("ai")

	if gateway_available and gateway != "":
		candidates.append(gateway + "/api/v1/ai" + path)
	if ai_available and ai != "":
		candidates.append(ai + "/api" + path)
	# Ensure both are present at least once to try fallback even if availability uncertain
	if not gateway_available and gateway != "":
		candidates.append(gateway + "/api/v1/ai" + path)
	if not ai_available and ai != "":
		candidates.append(ai + "/api" + path)

	return candidates

## Send HTTP request (ephemeral) with short timeout and parse
func _send_request_ephemeral(method: int, url: String, headers: Array = [], body: String = "", timeout: float = 5.0) -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)
	http.timeout = timeout
	var err = http.request(url, headers, method, body)
	if err != OK:
		http.queue_free()
		return _error_response("Failed to send request: " + str(err))
	var response = await http.request_completed
	http.queue_free()
	return _parse_response(response)

## Acquire a request slot (queue control)
func _acquire_slot() -> void:
	while _current_requests >= MAX_QUEUE_CONCURRENCY:
		await slot_freed
	_current_requests += 1

## Release a request slot and notify waiters
func _release_slot() -> void:
	_current_requests = max(0, _current_requests - 1)
	slot_freed.emit()

## Send request with retries/backoff, returns parsed response
func _send_with_backoff(method: int, url: String, headers: Array = [], body: String = "") -> Dictionary:
	await _acquire_slot()
	var attempt = 0
	while attempt < MAX_RETRIES:
		var http = HTTPRequest.new()
		add_child(http)
		http.timeout = REQUEST_TIMEOUT
		var err = http.request(url, headers, method, body)
		if err != OK:
			http.queue_free()
			attempt += 1
			var delay = BACKOFF_BASE * pow(2.0, attempt - 1) + randf() * 0.25
			await get_tree().create_timer(delay).timeout
			continue

		var response = await http.request_completed
		http.queue_free()

		var result_code = response[0]
		var http_code = int(response[1])

		# Retry on network failure or 429/5xx
		if result_code != HTTPRequest.RESULT_SUCCESS or http_code == 429 or http_code >= 500:
			attempt += 1
			var delay2 = BACKOFF_BASE * pow(2.0, attempt - 1) + randf() * 0.25
			await get_tree().create_timer(delay2).timeout
			continue

		var parsed = _parse_response(response)
		_release_slot()
		return parsed

	# All retries failed
	_release_slot()
	return _error_response("Request failed after retries: " + url)

## POST with fallback between gateway and direct AI
func _post_with_fallback(path: String, payload: Dictionary) -> Dictionary:
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(payload)
	for base_url in _endpoint_candidates(path):
		var res = await _send_with_backoff(HTTPClient.METHOD_POST, base_url, headers, body)
		if res.success:
			return res
	return _error_response("All endpoints failed for POST " + path)

## GET with fallback between gateway and direct AI
func _get_with_fallback(path: String) -> Dictionary:
	for base_url in _endpoint_candidates(path):
		var res = await _send_with_backoff(HTTPClient.METHOD_GET, base_url)
		if res.success:
			return res
	return _error_response("All endpoints failed for GET " + path)

## DELETE with fallback between gateway and direct AI
func _delete_with_fallback(path: String, payload: Dictionary) -> Dictionary:
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(payload)
	for base_url in _endpoint_candidates(path):
		var res = await _send_with_backoff(HTTPClient.METHOD_DELETE, base_url, headers, body)
		if res.success:
			return res
	return _error_response("All endpoints failed for DELETE " + path)

# ============================================================================
# MISSION GENERATION
# ============================================================================

## Generate a new mission using AI
func generate_mission(difficulty: String, mission_type: String = "", location: String = "") -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var request_body = {
		"difficulty": difficulty,
		"mission_type": mission_type if mission_type != "" else null,
		"location": location if location != "" else null,
		"game_state": _prepare_game_state()
	}

	var result = await _post_with_fallback("/missions/generate", request_body)
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

	var result = await _post_with_fallback("/chat/message", request_body)

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

	var request_body = {
		"npc_name": npc_name,
		"npc_role": npc_role,
		"context": context,
		"player_action": player_action if player_action != "" else null,
		"game_state": _prepare_game_state()
	}

	var result = await _post_with_fallback("/dialogue/generate", request_body)
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

	var result = await _post_with_fallback("/orchestrator/chat", request_body)

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

	# Generate conversation ID if not provided
	if conversation_id == "":
		conversation_id = "conv_routed_%d" % Time.get_unix_time_from_system()

	var request_body = {
		"message": message,
		"conversation_id": conversation_id,
		"game_state": _prepare_game_state()
	}

	var result = await _post_with_fallback("/orchestrator/route", request_body)

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

	# Generate conversation ID if not provided
	if conversation_id == "":
		conversation_id = "conv_handoff_%d" % Time.get_unix_time_from_system()

	var request_body = {
		"from_agent": from_agent,
		"to_agent": to_agent,
		"context": context,
		"conversation_id": conversation_id
	}

	var result = await _post_with_fallback("/orchestrator/handoff", request_body)

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

	return await _get_with_fallback("/orchestrator/agents")

## Get conversation history for a specific agent
func get_conversation_history(agent_name: String) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	return await _get_with_fallback("/orchestrator/history/" + agent_name)

## Clear conversation history (optionally for specific agent)
func clear_conversation_history(agent_name: String = "") -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var request_body = {}
	if agent_name != "":
		request_body["agent"] = agent_name

	return await _delete_with_fallback("/orchestrator/history", request_body)

## Get orchestrator health status
func get_orchestrator_health() -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	return await _get_with_fallback("/orchestrator/health")

# ============================================================================
# SPONTANEOUS EVENTS
# ============================================================================

## Check for spontaneous events (e.g., AI-driven random encounters)
func check_spontaneous_event() -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	# TODO: This endpoint needs to be implemented in the backend
	var request_body = {
		"game_state": _prepare_game_state(),
		"event_probability": 0.3  # 30% chance
	}

	var result = await _post_with_fallback("/events/spontaneous", request_body)

	# Emit event if one was generated
	if result.success and result.data.has("event_triggered") and result.data.event_triggered:
		EventBus.spontaneous_event_triggered.emit(result.data)

	return result

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

## Prepare game state for API requests (simplified for transmission)
func _prepare_game_state() -> Dictionary:
	var state = {
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

	# Add active mission summary (if any)
	if MissionManager.is_mission_active():
		var mission = MissionManager.get_active_mission()
		var current_stage = MissionManager.get_current_stage()

		state["mission"] = {
			"mission_id": mission.get("mission_id", "unknown"),
			"title": mission.get("title", "Unknown Mission"),
			"type": mission.get("type", "unknown"),
			"location": mission.get("location", "Unknown"),
			"difficulty": mission.get("difficulty", 1),
			"description": mission.get("description", ""),
			"current_stage": MissionManager.current_stage_id,
			"current_stage_title": current_stage.get("title", ""),
			"current_stage_description": current_stage.get("description", "")
		}

	return state

## Make HTTP POST request
func _make_post_request(url: String, body: Dictionary) -> Dictionary:
	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)

	var error = http.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		if http.has_meta("ephemeral"):
			http.queue_free()
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	if http.has_meta("ephemeral"):
		http.queue_free()
	return _parse_response(response)

## Make HTTP GET request
func _make_get_request(url: String) -> Dictionary:
	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var error = http.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		if http.has_meta("ephemeral"):
			http.queue_free()
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	if http.has_meta("ephemeral"):
		http.queue_free()
	return _parse_response(response)

## Make HTTP DELETE request
func _make_delete_request(url: String, body: Dictionary) -> Dictionary:
	var http = _get_available_http_request()
	if http == null:
		return _error_response("No available HTTP request slots")

	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)

	var error = http.request(url, headers, HTTPClient.METHOD_DELETE, json_body)
	if error != OK:
		if http.has_meta("ephemeral"):
			http.queue_free()
		return _error_response("Failed to send request: " + str(error))

	var response = await http.request_completed
	if http.has_meta("ephemeral"):
		http.queue_free()
	return _parse_response(response)

## Get an available HTTP request node
func _get_available_http_request() -> HTTPRequest:
	for http in _http_requests:
		if http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			return http
	# No idle slots, create ephemeral request node
	var temp = HTTPRequest.new()
	add_child(temp)
	temp.timeout = REQUEST_TIMEOUT
	temp.set_meta("ephemeral", true)
	push_warning("AIService: HTTP pool exhausted; using ephemeral request")
	return temp

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

# ============================================================================
# AUTONOMOUS AI AGENT SYSTEM
# ============================================================================

## Check if autonomous agent has anything to say
## agent_name: "atlas", "storyteller", "tactical", or "companion"
## force_check: Optional - bypass throttling (for testing)
func agent_loop_check(agent_name: String, force_check: bool = false) -> Dictionary:
	if not ServiceManager.is_service_available("ai"):
		return _error_response("AI service unavailable")

	var url = ServiceManager.get_service_url("gateway") + "/api/v1/ai/orchestrator/agent_loop"

	var request_body = {
		"agent": agent_name,
		"game_state": _prepare_game_state(),
		"force_check": force_check
	}

	var result = await _make_post_request(url, request_body)
	return result

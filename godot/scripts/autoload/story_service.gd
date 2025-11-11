extends Node

## Story Service - HTTP client for dynamic story engine
##
## Provides methods to interact with story API endpoints for contextual
## narrative generation based on player choices, relationships, and world state.

const BASE_URL_FALLBACK = "http://localhost:17011/api/story"

var _is_available_cached: bool = false
var _last_availability_check: float = 0.0
const AVAILABILITY_CHECK_INTERVAL: float = 30.0  # Check every 30 seconds

const MAX_QUEUE_CONCURRENCY: int = 2
const MAX_RETRIES: int = 3
const BACKOFF_BASE: float = 0.5

var _current_requests: int = 0
signal slot_freed


func _ready() -> void:
	print("[StoryService] Initialized - connecting to %s" % _get_base_url())

	# Check availability asynchronously on startup
	_check_availability_async()
 
	randomize()


## Generate narrative for mission stage
##
## Calls POST /api/story/generate_narrative
## Returns: {success: bool, narrative: String, cached: bool, generation_time_ms: int}


func generate_narrative(request_data: Dictionary) -> Dictionary:
	print("[StoryService] Generating narrative for stage: %s" % request_data.get("stage_id", "unknown"))
	return await _post_request_with_fallback("/generate_narrative", request_data)


## Generate outcome for player choice
##
## Calls POST /api/story/generate_outcome
## Returns: {success: bool, outcome: String, narrative: String, consequences: Dictionary, next_stage: String}
func generate_outcome(request_data: Dictionary) -> Dictionary:
	print("[StoryService] Generating outcome for choice: %s" % request_data.get("choice", {}).get("choice_id", "unknown"))
	return await _post_request_with_fallback("/generate_outcome", request_data)


## Get player memory context
##
## Calls GET /api/story/memory/{player_id}
## Returns: {success: bool, recent_choices: Array, relationships: Dictionary, active_consequences: Array}
func get_memory_context(player_id: String, limit: int = 10) -> Dictionary:
	var endpoint = "/memory/" + player_id + "?limit=" + str(limit)
	print("[StoryService] Fetching memory context for player: %s" % player_id)
	return await _get_request_with_fallback(endpoint)


## Get mission from pool
##
## Calls GET /api/story/mission_pool
## Returns: {success: bool, mission: Dictionary, source: String, queue_count: int}
func get_pool_mission(difficulty: String = "medium") -> Dictionary:
	var endpoint = "/mission_pool?difficulty=" + difficulty
	print("[StoryService] Fetching pool mission (difficulty: %s)" % difficulty)
	return await _get_request_with_fallback(endpoint)


## Get world context
##
## Calls GET /api/story/world_context
## Returns: {success: bool, context: Dictionary}
func get_world_context(sector: String = "", include_events: bool = true) -> Dictionary:
	var endpoint = "/world_context?include_events=" + str(include_events)
	if sector != "":
		endpoint += "&sector=" + sector
	print("[StoryService] Fetching world context")
	return await _get_request_with_fallback(endpoint)


## Invalidate cached narratives
##
## Calls DELETE /api/story/invalidate_cache
## Returns: {success: bool, deleted_count: int}
func invalidate_cache(player_id: String, mission_id: String, player_state: Dictionary) -> Dictionary:
	var request_data = {
		"player_id": player_id,
		"mission_id": mission_id,
		"player_state": player_state
	}
	print("[StoryService] Invalidating cache for mission: %s" % mission_id)
	return await _delete_request_with_fallback("/invalidate_cache", request_data)


## Check if story service is available
##
## Returns: bool (non-blocking, uses cached value)
func is_available() -> bool:
	# Check if ServiceManager exists and AI service is available
	if has_node("/root/ServiceManager"):
		return ServiceManager.is_service_available("ai")

	# Periodically refresh cached availability in background
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_availability_check > AVAILABILITY_CHECK_INTERVAL:
		_check_availability_async()

	# Return cached value (non-blocking)
	return _is_available_cached


func _check_availability_async() -> void:
	"""Check service availability asynchronously (non-blocking)"""
	_last_availability_check = Time.get_ticks_msec() / 1000.0

	var url = ServiceManager.get_service_url("ai") + "/health"
	var test_request = HTTPRequest.new()
	add_child(test_request)
	test_request.timeout = 5.0

	# Make request with short timeout
	test_request.request(url)
	var response = await test_request.request_completed

	var status_code = response[1]
	_is_available_cached = (status_code == 200)

	test_request.queue_free()

	if _is_available_cached:
		print("[StoryService] Service is available")
	else:
		push_warning("[StoryService] Service not available (status: %d)" % status_code)


# HTTP request helpers

func _get_base_url() -> String:
	# Prefer gateway when available; otherwise call AI service directly
	if ServiceManager.is_service_available("gateway"):
		return ServiceManager.get_service_url("gateway") + "/api/v1/ai/story"
	# Direct AI service
	return ServiceManager.get_service_url("ai") + "/api/story"

## Ordered list of base URLs for story endpoints (gateway first, then direct)
func _story_endpoint_candidates() -> Array[String]:
	var candidates: Array[String] = []
	if ServiceManager.get_service_url("gateway") != "":
		candidates.append(ServiceManager.get_service_url("gateway") + "/api/v1/ai/story")
	if ServiceManager.get_service_url("ai") != "":
		candidates.append(ServiceManager.get_service_url("ai") + "/api/story")
	return candidates

## Concurrency control
func _acquire_slot() -> void:
	while _current_requests >= MAX_QUEUE_CONCURRENCY:
		await slot_freed
	_current_requests += 1

func _release_slot() -> void:
	_current_requests = max(0, _current_requests - 1)
	slot_freed.emit()

func _post_request_with_fallback(endpoint: String, data: Dictionary) -> Dictionary:
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	for base in _story_endpoint_candidates():
		var url = base + endpoint

		var parsed = await _send_with_backoff(url, headers, body, HTTPClient.METHOD_POST)
		if parsed.success:
			return parsed
	return {"success": false, "error": "All endpoints failed for POST " + endpoint}

func _get_request_with_fallback(endpoint: String) -> Dictionary:
	for base in _story_endpoint_candidates():
		var url = base + endpoint
		var parsed = await _send_with_backoff(url, [], "", HTTPClient.METHOD_GET)
		if parsed.success:
			return parsed
	return {"success": false, "error": "All endpoints failed for GET " + endpoint}

func _delete_request_with_fallback(endpoint: String, data: Dictionary) -> Dictionary:
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	for base in _story_endpoint_candidates():
		var url = base + endpoint
		var parsed = await _send_with_backoff(url, headers, body, HTTPClient.METHOD_DELETE)
		if parsed.success:
			return parsed
	return {"success": false, "error": "All endpoints failed for DELETE " + endpoint}

## Send with retries/backoff and queue control
func _send_with_backoff(url: String, headers: Array, body: String, method: int) -> Dictionary:
	await _acquire_slot()
	var attempt = 0
	while attempt < MAX_RETRIES:
		var http = HTTPRequest.new()
		add_child(http)
		http.timeout = 10.0
		var err = http.request(url, headers, method, body)
		if err != OK:
			http.queue_free()
			attempt += 1
			var d1 = BACKOFF_BASE * pow(2.0, attempt - 1) + randf() * 0.25
			await get_tree().create_timer(d1).timeout
			continue

		var response = await http.request_completed
		http.queue_free()

		var result_code = response[0]
		var http_code = int(response[1])
		if result_code != HTTPRequest.RESULT_SUCCESS or http_code == 429 or http_code >= 500:
			attempt += 1
			var d2 = BACKOFF_BASE * pow(2.0, attempt - 1) + randf() * 0.25
			await get_tree().create_timer(d2).timeout
			continue

		var parsed = _parse_response(response)
		_release_slot()
		return parsed

	_release_slot()
	return {"success": false, "error": "Request failed after retries: " + url}

func _post_request(endpoint: String, data: Dictionary) -> Dictionary:
	"""Make POST request to story API"""
	var url = _get_base_url() + endpoint
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)

	var http = HTTPRequest.new()
	add_child(http)
	http.timeout = 30.0
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	var response = await http.request_completed
	http.queue_free()

	return _parse_response(response)


func _get_request(url: String) -> Dictionary:
	"""Make GET request to story API"""
	var http = HTTPRequest.new()
	add_child(http)
	http.timeout = 30.0
	http.request(url)
	var response = await http.request_completed
	http.queue_free()
	return _parse_response(response)


func _delete_request(endpoint: String, data: Dictionary) -> Dictionary:
	"""Make DELETE request to story API"""
	var url = _get_base_url() + endpoint
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)

	var http = HTTPRequest.new()
	add_child(http)
	http.timeout = 30.0
	http.request(url, headers, HTTPClient.METHOD_DELETE, body)
	var response = await http.request_completed
	http.queue_free()

	return _parse_response(response)


func _parse_response(response: Array) -> Dictionary:
	"""Parse HTTP response"""
	var result = response[0]
	var response_code = response[1]
	var headers = response[2]
	var body = response[3]

	# Check for HTTP errors
	if response_code != 200:
		push_error("[StoryService] HTTP %d error" % response_code)
		return {
			"success": false,
			"error": "HTTP " + str(response_code)
		}

	# Parse JSON body
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		push_error("[StoryService] JSON parse error: %s" % json.get_error_message())
		return {
			"success": false,
			"error": "JSON parse error: " + json.get_error_message()
		}

	var data = json.data

	# Ensure data is a dictionary
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[StoryService] Expected dictionary response, got: %s" % typeof(data))
		return {
			"success": false,
			"error": "Invalid response format"
		}

	return data


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	"""Request completed callback (for debugging)"""
	if response_code != 200:
		push_warning("[StoryService] Request completed with status: %d" % response_code)


## Build player state for cache key
##
## Extracts relevant player state fields for cache key generation
func build_player_state() -> Dictionary:
	"""Build player state dictionary for API requests"""

	# Check if GameState exists
	if not has_node("/root/GameState"):
		push_warning("[StoryService] GameState not found, using default state")
		return {
			"level": 1,
			"current_mission": "",
			"completed_missions": [],
			"phase": 1
		}

	var game_state = get_node("/root/GameState")

	return {
		"level": game_state.player.get("level", 1),
		"current_mission": game_state.progress.get("current_mission", ""),
		"completed_missions": game_state.progress.get("completed_missions", []),
		"phase": game_state.progress.get("phase", 1)
	}


## Get player ID from GameState
##
## Returns: String player ID
func get_player_id() -> String:
	"""Get player ID from GameState or generate one"""

	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")

		# Check if player has an ID
		if game_state.player.has("id"):
			return game_state.player.id

		# Generate ID from player name + timestamp
		var player_name = game_state.player.get("name", "Player")
		var timestamp = Time.get_unix_time_from_system()
		return "%s_%d" % [player_name.to_lower().replace(" ", "_"), timestamp]

	# Fallback: generate generic ID
	return "player_%d" % Time.get_unix_time_from_system()

extends Node

## Story Service - HTTP client for dynamic story engine
##
## Provides methods to interact with story API endpoints for contextual
## narrative generation based on player choices, relationships, and world state.

const BASE_URL = "http://localhost:17011/api/story"

var _http_request: HTTPRequest


func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

	print("[StoryService] Initialized - connecting to %s" % BASE_URL)


## Generate narrative for mission stage
##
## Calls POST /api/story/generate_narrative
## Returns: {success: bool, narrative: String, cached: bool, generation_time_ms: int}
func generate_narrative(request_data: Dictionary) -> Dictionary:
	print("[StoryService] Generating narrative for stage: %s" % request_data.get("stage_id", "unknown"))
	return await _post_request("/generate_narrative", request_data)


## Generate outcome for player choice
##
## Calls POST /api/story/generate_outcome
## Returns: {success: bool, outcome: String, narrative: String, consequences: Dictionary, next_stage: String}
func generate_outcome(request_data: Dictionary) -> Dictionary:
	print("[StoryService] Generating outcome for choice: %s" % request_data.get("choice", {}).get("choice_id", "unknown"))
	return await _post_request("/generate_outcome", request_data)


## Get player memory context
##
## Calls GET /api/story/memory/{player_id}
## Returns: {success: bool, recent_choices: Array, relationships: Dictionary, active_consequences: Array}
func get_memory_context(player_id: String, limit: int = 10) -> Dictionary:
	var url = BASE_URL + "/memory/" + player_id + "?limit=" + str(limit)
	print("[StoryService] Fetching memory context for player: %s" % player_id)
	return await _get_request(url)


## Get mission from pool
##
## Calls GET /api/story/mission_pool
## Returns: {success: bool, mission: Dictionary, source: String, queue_count: int}
func get_pool_mission(difficulty: String = "medium") -> Dictionary:
	var url = BASE_URL + "/mission_pool?difficulty=" + difficulty
	print("[StoryService] Fetching pool mission (difficulty: %s)" % difficulty)
	return await _get_request(url)


## Get world context
##
## Calls GET /api/story/world_context
## Returns: {success: bool, context: Dictionary}
func get_world_context(sector: String = "", include_events: bool = true) -> Dictionary:
	var url = BASE_URL + "/world_context?include_events=" + str(include_events)
	if sector != "":
		url += "&sector=" + sector
	print("[StoryService] Fetching world context")
	return await _get_request(url)


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
	return await _delete_request("/invalidate_cache", request_data)


## Check if story service is available
##
## Returns: bool
func is_available() -> bool:
	# Check if ServiceManager exists and AI service is available
	if has_node("/root/ServiceManager"):
		return ServiceManager.is_service_available("ai")

	# Fallback: try to ping health endpoint
	var url = "http://localhost:17011/health"
	var test_request = HTTPRequest.new()
	add_child(test_request)
	test_request.request(url)
	var response = await test_request.request_completed
	test_request.queue_free()

	var status_code = response[1]
	return status_code == 200


# HTTP request helpers

func _post_request(endpoint: String, data: Dictionary) -> Dictionary:
	"""Make POST request to story API"""
	var url = BASE_URL + endpoint
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)

	_http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	var response = await _http_request.request_completed

	return _parse_response(response)


func _get_request(url: String) -> Dictionary:
	"""Make GET request to story API"""
	_http_request.request(url)
	var response = await _http_request.request_completed
	return _parse_response(response)


func _delete_request(endpoint: String, data: Dictionary) -> Dictionary:
	"""Make DELETE request to story API"""
	var url = BASE_URL + endpoint
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)

	_http_request.request(url, headers, HTTPClient.METHOD_DELETE, body)
	var response = await _http_request.request_completed

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

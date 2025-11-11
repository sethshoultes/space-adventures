extends Node

## ServiceManager Singleton
## Manages connections to backend microservices
## Provides health checks and service discovery

# Service URL defaults (NCC-1701 Port Registry)
const _DEFAULT_URLS: Dictionary = {
	"gateway": "http://localhost:17010",
	"ai": "http://localhost:17011",
	"whisper": "http://localhost:17012",
}

# Service status cache
var _service_status: Dictionary = {}
var _last_health_check: float = 0.0
const HEALTH_CHECK_INTERVAL: float = 30.0  # seconds

# HTTP Request node for health checks
var _http_request: HTTPRequest

signal service_status_changed(service_name: String, is_available: bool)
signal all_services_checked(results: Dictionary)

func _ready() -> void:
	print("ServiceManager initialized")
	print("Gateway: ", get_service_url("gateway"))
	print("AI Service: ", get_service_url("ai"))

	# Create HTTPRequest node for health checks
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.timeout = 5.0

	# Initialize service status (all unknown until first check)
	for service_name in _DEFAULT_URLS.keys():
		_service_status[service_name] = {
			"available": false,
			"last_check": 0.0,
			"error": ""
		}

	# Perform initial health check
	await get_tree().create_timer(0.5).timeout
	check_all_services()

## Check if a specific service is available
func is_service_available(service_name: String) -> bool:
	if not _service_status.has(service_name):
		push_warning("Unknown service: " + service_name)
		return false

	# Auto-refresh if data is stale
	var status = _service_status[service_name]
	var time_since_check = Time.get_unix_time_from_system() - status.last_check
	if time_since_check > HEALTH_CHECK_INTERVAL:
		# Don't wait for result, just trigger check
		check_service(service_name)

	return status.available

## Get service base URL
func get_service_url(service_name: String) -> String:
	if not _DEFAULT_URLS.has(service_name):
		push_error("Unknown service: " + service_name)
		return ""
	# Allow override via ProjectSettings: application/config/<service>_url
	var key = "application/config/%s_url" % service_name
	var default = _DEFAULT_URLS[service_name]
	var value = default
	if ProjectSettings.has_setting(key):
		value = str(ProjectSettings.get_setting(key))
	return value

## Check health of all services
func check_all_services() -> Dictionary:
	print("ServiceManager: Checking all services...")
	var results: Dictionary = {}

	for service_name in _DEFAULT_URLS.keys():
		var status = await check_service(service_name)
		results[service_name] = status

	all_services_checked.emit(results)
	return results

## Check health of a specific service
func check_service(service_name: String) -> Dictionary:
	if not _DEFAULT_URLS.has(service_name):
		return {"available": false, "error": "Unknown service"}

	var url = get_service_url(service_name) + "/health"
	var result = await _make_health_request(url)

	var status = {
		"available": result.success,
		"last_check": Time.get_unix_time_from_system(),
		"error": result.error if not result.success else "",
		"data": result.data if result.success else {}
	}

	# Update cache
	var was_available = _service_status[service_name].available
	_service_status[service_name] = status

	# Emit signal if status changed
	if was_available != status.available:
		service_status_changed.emit(service_name, status.available)
		if status.available:
			print("ServiceManager: %s is now AVAILABLE" % service_name)
		else:
			push_warning("ServiceManager: %s is now UNAVAILABLE - %s" % [service_name, status.error])

	return status

## Get cached service status (no new request)
func get_service_status(service_name: String) -> Dictionary:
	if not _service_status.has(service_name):
		return {"available": false, "error": "Unknown service", "last_check": 0.0}
	return _service_status[service_name]

## Get all service statuses
func get_all_statuses() -> Dictionary:
	return _service_status.duplicate(true)

## Make HTTP GET request to health endpoint
func _make_health_request(url: String) -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)
	http.timeout = 3.0  # Quick timeout for health checks

	var error = http.request(url)
	if error != OK:
		http.queue_free()
		return {
			"success": false,
			"error": "Failed to send request: " + str(error),
			"data": {}
		}

	# Wait for response
	var response = await http.request_completed
	http.queue_free()

	var result = response[0]
	var response_code = response[1]
	var body = response[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		return {
			"success": false,
			"error": "HTTP request failed: " + str(result),
			"data": {}
		}

	if response_code != 200:
		return {
			"success": false,
			"error": "HTTP " + str(response_code),
			"data": {}
		}

	# Parse JSON response
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		return {
			"success": false,
			"error": "Failed to parse JSON response",
			"data": {}
		}

	return {
		"success": true,
		"error": "",
		"data": json.data
	}

## Periodic health check (called from _process if needed)
func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	if current_time - _last_health_check > HEALTH_CHECK_INTERVAL:
		_last_health_check = current_time
		check_all_services()

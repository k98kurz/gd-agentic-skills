# skills/platform-web/scripts/web_bridge_sync.gd
extends Node

## Web Bridge Sync Expert Pattern
## JavaScriptBridge helpers for browser API integration (fullscreen, persistence, analytics).

class_name WebBridgeSync

# Persistence
static func save_to_local_storage(key: String, data: Dictionary) -> void:
	if not OS.has_feature("web"):
		return
	
	var json_str = JSON.stringify(data)
	# Encode to base64 to avoid character issues in JS string
	var b64_str = Marshalls.utf8_to_base64(json_str)
	
	var storage = JavaScriptBridge.get_interface("localStorage")
	if storage:
		storage.setItem(key, b64_str)

static func load_from_local_storage(key: String) -> Dictionary:
	if not OS.has_feature("web"):
		return {}
	
	var storage = JavaScriptBridge.get_interface("localStorage")
	var b64_str = ""
	if storage:
		b64_str = storage.getItem(key)
	
	if b64_str and b64_str is String:
		var json_str = Marshalls.base64_to_utf8(b64_str)
		var result = JSON.parse_string(json_str)
		if result:
			return result
	
	return {}

# Browser Interaction
static func set_tab_title(title: String) -> void:
	if OS.has_feature("web"):
		var document = JavaScriptBridge.get_interface("document")
		if document:
			document.title = title

# Analytics Hook (e.g. Google Analytics)
static func send_analytics_event(event_name: String, params: Dictionary = {}) -> void:
	if OS.has_feature("web"):
		# Ensure gtag is defined in index.html, safeguard against missing window.gtag
		# Use JSON.stringify to safely encode parameters
		var event_json = JSON.stringify(event_name)
		var params_json = JSON.stringify(params)
		var js = "if(typeof gtag !== 'undefined') { gtag('event', %s, %s); }" % [event_json, params_json]
		JavaScriptBridge.eval(js)

## EXPERT USAGE:
## if OS.has_feature("web"): WebBridgeSync.save_to_local_storage("save1", data)

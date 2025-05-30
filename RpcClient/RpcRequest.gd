extends HTTPRequest
class_name RpcRequest

signal rpc_completed(result, response_code, contents)
signal _finished_processing_a_request()

const STORAGE_SECTION_RPC := "RPC"
const STORAGE_KEY_RPC_HOST := "host"
const STORAGE_KEY_RPC_HOST_DEFAULT := "localhost"
const STORAGE_KEY_RPC_PORT := "port"
const STORAGE_KEY_RPC_PORT_DEFAULT := 52099
const STORAGE_KEY_RPC_PATH := "path"
const STORAGE_KEY_RPC_PATH_DEFAULT := "/rpc/"
const STORAGE_KEY_RPC_USERNAME := "username"
const STORAGE_KEY_RPC_USERNAME_DEFAULT := ""
const STORAGE_KEY_RPC_PASSWORD := "password"
const STORAGE_KEY_RPC_PASSWORD_DEFAULT := ""

const RPC_PATH_INFO = "info"
const RPC_PATH_CHAT = "chat"
const RPC_PATH_STATUS = "status"

var host = null
var port = null

var _processing_a_request := false
var _url: String

func _get_effective_host():
	if host == null:
		return StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_HOST, STORAGE_KEY_RPC_HOST_DEFAULT)
	else:
		return host
		
func _get_effective_port():
	if port == null:
		return StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PORT, STORAGE_KEY_RPC_PORT_DEFAULT)
	else:
		return port


func get_info() -> void:
	_get(RPC_PATH_INFO)
	
func delete_info(account_name: String) -> void:
	_delete_dictionary(RPC_PATH_INFO, {"accountname": account_name})
	
func get_chat(since) -> void:
	if since == null:
		_get(RPC_PATH_CHAT)
	else:
		_get(RPC_PATH_CHAT, {"since": since})
		
func post_chat(chat_message_log_entry: Dictionary) -> void:
	_post_dictionary(RPC_PATH_CHAT, chat_message_log_entry)
	
func get_status() -> void:
	_get(RPC_PATH_STATUS)
	
func _get(relative_path: String, query_params: Dictionary = {}) -> void:
	var base_path = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PATH, STORAGE_KEY_RPC_PATH_DEFAULT)
	var username = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_USERNAME, STORAGE_KEY_RPC_USERNAME_DEFAULT)
	var password = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PASSWORD, STORAGE_KEY_RPC_PASSWORD_DEFAULT)
	var path = str(base_path, relative_path)
	make_request(HTTPClient.METHOD_GET, path, query_params, "", username, password)
	
func _post_dictionary(relative_path: String, body: Dictionary) -> void:
	var base_path = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PATH, STORAGE_KEY_RPC_PATH_DEFAULT)
	var username = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_USERNAME, STORAGE_KEY_RPC_USERNAME_DEFAULT)
	var password = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PASSWORD, STORAGE_KEY_RPC_PASSWORD_DEFAULT)
	var path = str(base_path, relative_path)
	make_request(HTTPClient.METHOD_POST, path, {}, JSON.print(body), username, password)
	
func _delete_dictionary(relative_path: String, query_params: Dictionary) -> void:
	var base_path = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PATH, STORAGE_KEY_RPC_PATH_DEFAULT)
	var username = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_USERNAME, STORAGE_KEY_RPC_USERNAME_DEFAULT)
	var password = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PASSWORD, STORAGE_KEY_RPC_PASSWORD_DEFAULT)
	var path = str(base_path, relative_path)
	make_request(HTTPClient.METHOD_DELETE, path, query_params, "", username, password)

func make_request(method: int, path: String, query_params: Dictionary = {}, body: String = "", username: String = "", password: String = "") -> void:
	var http = HTTPClient.new()
	var query_string = http.query_string_from_dict(query_params)
	_url = "http://%s:%d/%s?%s" % [_get_effective_host(), _get_effective_port(), path.trim_prefix("/"), query_string]
	print("RpcRequest: ", _url) 
	
	var headers: = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	if username.length() > 0 and password.length() > 0:
		headers.append("Authorization: Basic "+Marshalls.utf8_to_base64(username+":"+password))
	
	if _processing_a_request:
		yield(self, "_finished_processing_a_request")
	
	_processing_a_request = true
	var err := request(_url, headers, true, method, body)
	var result: int
	var response_code: int
	var contents
	if err == RESULT_SUCCESS:
		var args = yield(self, "request_completed")
		result = args[0] as int
		response_code = args[1] as int
		var _headers = args[2] as PoolStringArray
		var response_body = args[3] as PoolByteArray
		if result == RESULT_SUCCESS and response_code >= 200 and response_code < 300:
			var response_body_string: String = response_body.get_string_from_utf8()
			var json = JSON.parse(response_body_string)
			if json.error != OK:
				printerr("RpcRequest: failed to parse json ", _url)
				contents = null
			else:
				contents = json.result
		else:
			printerr("RpcRequest: failed to perform http request ", _url, "\n\tError: ", result, "\n\tResponse code: ", response_code)
	else:
		result = RESULT_CANT_CONNECT
		response_code = 0
		contents = null
		printerr("RpcRequest: failed to establish connection ", _url)
	emit_signal("rpc_completed", result, response_code, contents)
	_finish_processing_a_request()

func _finish_processing_a_request() -> void:
	_processing_a_request = false
	call_deferred("emit_signal", "_finished_processing_a_request")

extends Reference

class_name RpcClient

const HTTP_DELAY_MS : int = 20

const STORAGE_SECTION_RPC := "RPC"
const STORAGE_KEY_RPC_HOST := "host"
const STORAGE_KEY_RPC_HOST_DEFAULT := "localhost"
const STORAGE_KEY_RPC_PORT := "port"
const STORAGE_KEY_RPC_PORT_DEFAULT := 52099
const STORAGE_KEY_RPC_PATH := "path"
const STORAGE_KEY_RPC_PATH_DEFAULT := "/rpc/"

const RPC_PATH_INFO = "info"
const RPC_PATH_CHAT = "chat"

func _init():
	pass
	
func _ready():
	# never
	pass

func get_info() -> Array:
	return _get_array(RPC_PATH_INFO)
	
func get_chat(since_iso_date: String = "") -> Array:
	if since_iso_date == "":
		return _get_array(RPC_PATH_CHAT)
	else:
		return _get_array(RPC_PATH_CHAT, {"since": since_iso_date})
		
func post_chat(chat_message_log_entry: Dictionary) -> void:
	_post_dictionary(RPC_PATH_CHAT, chat_message_log_entry)
	
func _get_array(relative_path: String, query_params: Dictionary = {}) -> Array:
	var host = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_HOST, STORAGE_KEY_RPC_HOST_DEFAULT)
	var port = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PORT, STORAGE_KEY_RPC_PORT_DEFAULT)
	var base_path = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PATH, STORAGE_KEY_RPC_PATH_DEFAULT)
	var path = str(base_path, relative_path)
	var res = make_request(HTTPClient.METHOD_GET, host, port, path, query_params)
	if typeof(res) != TYPE_ARRAY:
		print("RpcClient: expected Json Array") 
		# {} = Dictionary 
		# [] = Array
		return Array()
	return res
	
func _post_dictionary(relative_path: String, body: Dictionary) -> void:
	var host = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_HOST, STORAGE_KEY_RPC_HOST_DEFAULT)
	var port = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PORT, STORAGE_KEY_RPC_PORT_DEFAULT)
	var base_path = StorageProvider.get_value(STORAGE_SECTION_RPC, STORAGE_KEY_RPC_PATH, STORAGE_KEY_RPC_PATH_DEFAULT)
	var path = str(base_path, relative_path)
	var res = make_request(HTTPClient.METHOD_POST, host, port, path, {}, JSON.print(body))

func make_request(method: int, host: String, port: int = 80, path: String = '/', query_params: Dictionary = {}, body: String = ""):
	var err = 0
	var http = HTTPClient.new()
	err = http.connect_to_host(host, port)
	
	var query_string = http.query_string_from_dict(query_params)
	print("RpcClient: ", host,":",port, path, "?", query_string) 
		
	if err != OK:
		printerr("RpcClient: failed to establish connection ", host,":",port) 
		return
	
	var try_count = 0
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		#print("status %s" % [http.get_status()])
		http.poll()
		if OS.has_feature("web"):
			yield(Engine.get_main_loop(), "idle_frame")
		else:
			OS.delay_msec(HTTP_DELAY_MS)
		try_count = try_count + 1
		if try_count >= 10:
			printerr("RpcClient: STATUS_CONNECTING try_count >= 10 ", host,":",port,path,"?",query_string) 
			return
			
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		printerr("RpcClient: failed to connect ", host,":",port, path,"?",query_string) 
		return
		
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
	err = http.request(method, str(path,"?",query_string), headers, body)
	if err != OK:
		printerr("RpcClient: request failed ", host,":",port, path,"?",query_string) 
		return
		
	try_count = 0
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		if OS.has_feature("web"):
			yield(Engine.get_main_loop(), "idle_frame")
		else:
			OS.delay_msec(HTTP_DELAY_MS)
		try_count = try_count + 1
		if try_count >= 10:
			printerr("RpcClient: STATUS_REQUESTING try_count >= 10 ", host,":",port, path,"?",query_string) 
			return
			
	if http.get_status() != HTTPClient.STATUS_BODY and http.get_status() != HTTPClient.STATUS_CONNECTED:
		printerr("RpcClient: failed ", host,":",port, path,"?",query_string) 
		return
		
	if !http.has_response():
		printerr("RpcClient: no response ", host,":",port, path,"?",query_string) 
		return

	headers = http.get_response_headers_as_dictionary()
	if http.get_response_code() < 200 or http.get_response_code() >= 300:
		printerr("RpcClient: bad response code ", host,":",port, path,"?",query_string) 
		return
		
	try_count = 0
	var rb = PoolByteArray()
	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		var chunk = http.read_response_body_chunk()
		if chunk.size() == 0:
			if OS.has_feature("web"):
				yield(Engine.get_main_loop(), "idle_frame")
			else:
				OS.delay_usec(HTTP_DELAY_MS)
			try_count = try_count + 1
			if try_count >= 10:
				printerr("RpcClient: STATUS_BODY try_count >= 10 ", host,":",port, path,"?",query_string) 
				return
		else:
			rb = rb + chunk
		
	var response_body : String = rb.get_string_from_utf8()
	if response_body == '':
		return {}
		
	var json = JSON.parse(response_body)
	if json.error != OK:
		printerr("RpcClient: failed to parse json ", host,":",port, path,"?",query_string,"\n\t",response_body) 
		return
	return json.result

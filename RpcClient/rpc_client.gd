extends Node

class_name RpcClient

const HTTP_DELAY_MS : int = 20

func _init():
	pass
	
func _ready():
	pass

func get_info() -> Array:
	var res = make_request("http://localhost", "/rpc/info")
	if typeof(res) != TYPE_ARRAY:
		print("RpcClient: expected Json Array") 
		# {} = Dictionary 
		# [] = Array
		return Array()
	return res
	
func make_request(var host : String, var path : String):
	var err = 0
	var http = HTTPClient.new()
	err = http.connect_to_host(host, 80)
	assert(err == OK)
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		if not OS.has_feature("web"):
			OS.delay_msec(HTTP_DELAY_MS)
		else:
			yield(Engine.get_main_loop(), "idle_frame")
			
	assert(http.get_status() == HTTPClient.STATUS_CONNECTED)
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	err = http.request(HTTPClient.METHOD_GET, path, headers)
	assert(err == OK)
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		if OS.has_feature("web"):
			yield(Engine.get_main_loop(), "idle_frame")
		else:
			OS.delay_msec(HTTP_DELAY_MS)
	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED)
	
	if !http.has_response():
		print("RpcClient: no response") 
		return

	headers = http.get_response_headers_as_dictionary()
	if http.get_response_code() != 200:
		print("RpcClient: bad response code") 
		return

	var rb = PoolByteArray()
	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		var chunk = http.read_response_body_chunk()
		if chunk.size() == 0:
			if not OS.has_feature("web"):
				OS.delay_usec(HTTP_DELAY_MS)
			else:
				yield(Engine.get_main_loop(), "idle_frame")
		else:
			rb = rb + chunk
	var body : String = rb.get_string_from_utf8()
	var json = JSON.parse(body)
	if json.error != OK:
		print("RpcClient: failed to parse json") 
		return
	return json.result

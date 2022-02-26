extends Reference

class_name RpcClient

const HTTP_DELAY_MS : int = 20


func _init():
	pass
	
func _ready():
	# never
	pass

func get_info() -> Array:
	print("RpcClient: get_info") 
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
	
	if err != OK:
		print("RpcClient: failed to establish connection") 
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
			print("RpcClient: STATUS_CONNECTING try_count >= 10") 
			return
			
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		print("RpcClient: failed to connect") 
		return
		
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	err = http.request(HTTPClient.METHOD_GET, path, headers)
	if err != OK:
		print("RpcClient: request failed") 
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
			print("RpcClient: STATUS_REQUESTING try_count >= 10") 
			return
			
	if http.get_status() != HTTPClient.STATUS_BODY and http.get_status() != HTTPClient.STATUS_CONNECTED:
		print("RpcClient: failed") 
		return
		
	if !http.has_response():
		print("RpcClient: no response") 
		return

	headers = http.get_response_headers_as_dictionary()
	if http.get_response_code() != 200:
		print("RpcClient: bad response code") 
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
				print("RpcClient: STATUS_BODY try_count >= 10") 
				return
		else:
			rb = rb + chunk
		
	var body : String = rb.get_string_from_utf8()
	var json = JSON.parse(body)
	if json.error != OK:
		print("RpcClient: failed to parse json") 
		return
	return json.result

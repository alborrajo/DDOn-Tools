extends Node

signal fetched_servers()

var servers: Array = []

func _ready():
	_fetch_servers()

func _on_Timer_timeout():
	_fetch_servers()

func _fetch_servers():
	$RpcRequest.host = null
	$RpcRequest.port = null
	$RpcRequest.get_status()
	var args = yield($RpcRequest, "rpc_completed")
	
	var request_result = args[0]
	if request_result != HTTPRequest.RESULT_SUCCESS:
		printerr("Failed to connect to the server. HTTP Error: ", request_result)
		return
	
	var response_code = args[1]
	if response_code != 200:
		printerr("Failed to obtain server status. Response code: ", response_code)
		return
	
	var servers_fetched = args[2]
	assert(servers_fetched is Array)
	servers = servers_fetched
	emit_signal("fetched_servers")

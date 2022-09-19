extends VBoxContainer
class_name Chat

var _rpc_client := RpcClient.new()

var _last_request_iso_date: String = ""

func _ready():
	_on_RPCTimer_timeout()

func _on_RPCTimer_timeout():
	var since_iso_date := _last_request_iso_date
	_last_request_iso_date = str(Time.get_datetime_string_from_system(true),".",OS.get_system_time_msecs(),"Z") # UTC date
	var chatlog := _rpc_client.get_chat(since_iso_date)
	if chatlog.size() > 0:
		print(chatlog.size(), " new chat messages")
		for logentry in chatlog:
			$ChatLog.add_item("%s %s: %s" % [logentry["FirstName"], logentry["LastName"], logentry["ChatMessage"]["Message"]])

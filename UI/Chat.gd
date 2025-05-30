extends VBoxContainer
class_name Chat

const MAX_ENTRIES := 100 # TODO: Configurable

const _META_LOG_ENTRY = "logentry"

const _CHAT_TYPE_COLORS = {
	"0": Color.white, # Say
	"1": Color.purple, # Shout
	"2": Color.palevioletred, # Tell
	"3": Color.yellow, # System
	"4": Color.aquamarine, # Party
	"5": Color.purple, # ShoutAll, not sure about this one
	"6": Color.lawngreen, # Group
	"7": Color.springgreen, # Clan
	"8": Color.aquamarine, # Entryboard TODO
	"9": Color.yellow, # ManagementGuideC
	"10": Color.yellow, # ManagementGuideN TODO
	"11": Color.crimson, # ManagementAlertC TODO
	"12": Color.crimson, # ManagementAlertN TODO
	"13": Color.springgreen, # ClanNotice TODO
}

var _last_received_chat_unix_time = null

func _ready():
	assert(ServerProvider.connect("fetched_servers", self, "_on_fetched_servers") == OK)
	_on_Chat_visibility_changed()
	$ChatLogPanel/ChatLogScrollContainer.scroll_vertical = 99999
	
func _on_fetched_servers() -> void:
	var old_selected_server = $ServerOptionButton.get_selected_metadata()
	$ServerOptionButton.clear()
	for server in ServerProvider.servers:
		$ServerOptionButton.add_item(server["Name"], server["Id"])
		$ServerOptionButton.set_item_metadata($ServerOptionButton.get_item_index(server["Id"]), server)
	if old_selected_server != null:
		var idx = $ServerOptionButton.get_item_index(old_selected_server["Id"])
		if idx != -1:
			var new_selected_server = $ServerOptionButton.get_item_metadata(idx)
			if old_selected_server["Addr"] == new_selected_server["Addr"] and old_selected_server["RpcPort"] == new_selected_server["RpcPort"]:
				$ServerOptionButton.select(idx)
				return
				
	if ServerProvider.servers.size() > 0:
		$ServerOptionButton.select(0)
		$ServerOptionButton.emit_signal("item_selected", 0)
	
	
func _on_ServerOptionButton_item_selected(index):
	_last_received_chat_unix_time = null
	for child in $ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.get_children():
		child.queue_free()
	var selected_server = $ServerOptionButton.get_selected_metadata()
	$RpcRequest.host = selected_server["Addr"]
	$RpcRequest.port = selected_server["RpcPort"]
	_on_RPCTimer_timeout()
	$ChatLogPanel/ChatLogScrollContainer.scroll_vertical = 99999

func _on_RPCTimer_timeout():
	$RpcRequest.get_chat(_last_received_chat_unix_time)
	var args = yield($RpcRequest, "rpc_completed")
	var result = args[0]
	var response_code = args[1]
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		printerr("Failed to obtain chat messages.\n\tError: ", result, "\n\tResponse code: ", response_code)
		return
		
	var chatlog = args[2]
	var is_at_bottom = $ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().value+$ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().page == $ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().max_value
	if chatlog.size() > 0:
		print(chatlog.size(), " new chat messages")
		for logentry in chatlog:
			_last_received_chat_unix_time = int(logentry["UnixTimeMillis"])
			var datetime_dict := Time.get_datetime_dict_from_datetime_string(logentry["DateTime"], false)
			var label := Label.new()
			label.autowrap = true
			label.text = "[%02d:%02d] %s %s: %s" % [datetime_dict["hour"], datetime_dict["minute"], logentry["FirstName"], logentry["LastName"], logentry["ChatMessage"]["Message"]]
			label.set_meta(_META_LOG_ENTRY, logentry)
			var message_type := String(logentry["ChatMessage"]["Type"])
			if _CHAT_TYPE_COLORS.has(message_type):
				label.modulate = _CHAT_TYPE_COLORS.get(message_type)
			$ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.add_child(label)
			print("\t(Type ", logentry["ChatMessage"]["Type"], ") ", label.text)
	while $ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.get_child_count() > MAX_ENTRIES:
		$ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.remove_child($ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.get_child(0))
	
	if is_at_bottom:
		$ChatLogPanel/ChatLogScrollContainer.scroll_vertical = 99999
		

func _on_MessageLineEdit_text_entered(message: String):
	$ChatBox/MessageLineEdit.editable = false
	var chat_message_log_entry := {
		# DateTime not used
		# TODO: CharacterId
		"FirstName": "DDOn",
		"LastName": "Tools",
		"ChatMessage": {
			"Type": $ChatBox/MsgTypeOptionButton.get_item_id($ChatBox/MsgTypeOptionButton.selected),
			"Message": message,
			"Deliver": true
		}
	}
	$RpcRequest.post_chat(chat_message_log_entry)
	var args = yield($RpcRequest, "rpc_completed")
	
	$ChatBox/MessageLineEdit.clear()
	$ChatBox/MessageLineEdit.editable = true
	
	var result = args[0]
	var response_code = args[1]
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		printerr("Failed to post chat message.\n\tError: ", result, "\n\tResponse code: ", response_code)
		return

	_on_RPCTimer_timeout()
	
func _on_Chat_visibility_changed():
	if visible:
		_on_RPCTimer_timeout()
		$RPCTimer.start()
	else:
		$RPCTimer.stop()

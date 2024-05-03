extends VBoxContainer
class_name Chat

const MAX_ENTRIES := 100 # TODO: Configurable

const _META_LOG_ENTRY = "logentry"

const _CHAT_TYPE_COLORS = {
	"0": Color.white, # Say
	"1": Color.purple, # Shout
	"2": Color.crimson, # Tell
	"3": Color.darkcyan, # System
	"4": Color.aquamarine, # Party
	"5": Color.purple, # ShoutAll, not sure about this one
	"6": Color.lightgreen, # Group
	"7": Color.limegreen, # Clan
	"8": Color.aquamarine, # Entryboard TODO
	"9": Color.darkcyan, # ManagementGuideC TODO
	"10": Color.darkcyan, # ManagementGuideN TODO
	"11": Color.darkcyan, # ManagementAlertC TODO
	"12": Color.darkcyan, # ManagementAlertN TODO
	"13": Color.darkgreen, # ClanNotice TODO
}

var _rpc_client := RpcClient.new()

var _last_received_chat_unix_time = null

func _ready():
	_on_Chat_visibility_changed()
	$ChatLogPanel/ChatLogScrollContainer.scroll_vertical = 99999

func _on_RPCTimer_timeout():
	$RPCTimer.paused = true
	var is_at_bottom = $ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().value+$ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().page == $ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().max_value
	var chatlog := _rpc_client.get_chat(_last_received_chat_unix_time)
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
	$RPCTimer.paused = false
	
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
	_rpc_client.post_chat(chat_message_log_entry)
	$ChatBox/MessageLineEdit.clear()
	$ChatBox/MessageLineEdit.editable = true
	_on_RPCTimer_timeout()

func _on_Chat_visibility_changed():
	if visible:
		_on_RPCTimer_timeout()
		$RPCTimer.start()
	else:
		$RPCTimer.stop()

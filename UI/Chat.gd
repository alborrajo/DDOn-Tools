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

var _last_request_iso_date: String = ""

func _ready():
	_on_Chat_visibility_changed()
	$ChatLogPanel/ChatLogScrollContainer.scroll_vertical = 99999

func _on_RPCTimer_timeout():
	$RPCTimer.paused = true
	var is_at_bottom = $ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().value+$ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().page == $ChatLogPanel/ChatLogScrollContainer.get_v_scrollbar().max_value
	var iso_date := _last_request_iso_date
	_last_request_iso_date = str(Time.get_datetime_string_from_system(true),".",OS.get_system_time_msecs(),"Z") # UTC date
	var chatlog := _rpc_client.get_chat(iso_date)
	if chatlog.size() > 0:
		print(chatlog.size(), " new chat messages")
		for logentry in chatlog:
			if _is_duplicate_msg(logentry):
				printerr("Duplicate message: ",logentry)
			else:
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
		# TODO: FirstName
		# TODO: LastName
		# TODO: CharacterId
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

# Inefficient af but i didnt find a better way
func _is_duplicate_msg(new_msg: Dictionary) -> bool:
	if $ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.get_child_count() > 0:
		for msg_idx in range($ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.get_child_count()-1, -1, -1): # Check in reverse
			var msg: Dictionary = $ChatLogPanel/ChatLogScrollContainer/ChatLogVBoxContainer.get_child(msg_idx).get_meta(_META_LOG_ENTRY)
			if new_msg["CharacterId"] == msg["CharacterId"] and new_msg["FirstName"] == msg["FirstName"] and new_msg["LastName"] == msg["LastName"] and new_msg["DateTime"] == msg["DateTime"] and new_msg["ChatMessage"]["Type"] == msg["ChatMessage"]["Type"] and new_msg["ChatMessage"]["Message"] == msg["ChatMessage"]["Message"] and new_msg["ChatMessage"]["Deliver"] == msg["ChatMessage"]["Deliver"]:
				return true
	return false

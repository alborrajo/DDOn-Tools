extends VBoxContainer
class_name Chat

const MAX_ENTRIES := 100 # TODO: Configurable

var _rpc_client := RpcClient.new()

var _is_at_bottom := false
var _last_request_iso_date: String = ""

func _ready():
	_on_Chat_visibility_changed()
	$ChatLog.get_v_scroll().value = $ChatLog.get_v_scroll().max_value
	$ChatLog.get_v_scroll().connect("changed", self, "_on_chatlog_vscroll_changed")

func _on_RPCTimer_timeout():
	$RPCTimer.paused = true
	_is_at_bottom = $ChatLog.get_v_scroll().value+$ChatLog.get_v_scroll().page == $ChatLog.get_v_scroll().max_value
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
				$ChatLog.add_item("[%02d:%02d] %s %s: %s" % [datetime_dict["hour"], datetime_dict["minute"], logentry["FirstName"], logentry["LastName"], logentry["ChatMessage"]["Message"]])
				$ChatLog.set_item_metadata($ChatLog.get_item_count()-1, logentry)
	while $ChatLog.get_item_count() > MAX_ENTRIES:
		$ChatLog.remove_item(0)
	$RPCTimer.paused = false

func _on_MessageLineEdit_text_entered(message: String):
	$ChatBox/MessageLineEdit.editable = false
	var chat_message_log_entry := {
		# DateTime not used
		# TODO: FirstName
		# TODO: LastName
		# TODO: CharacterId
		"ChatMessage": {
			"Type": $ChatBox/MsgTypeOptionButton.get_item_text($ChatBox/MsgTypeOptionButton.selected),
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

func _on_chatlog_vscroll_changed(value = null):
	# Scroll back to bottom if it already was before updating
	if _is_at_bottom:
		$ChatLog.get_v_scroll().value = $ChatLog.get_v_scroll().max_value

# Inefficient af but i didnt find a better way
func _is_duplicate_msg(new_msg: Dictionary) -> bool:
	if $ChatLog.get_item_count() > 0:
		for msg_idx in range($ChatLog.get_item_count()-1, -1, -1): # Check in reverse
			var msg: Dictionary = $ChatLog.get_item_metadata(msg_idx)
			if new_msg["CharacterId"] == msg["CharacterId"] and new_msg["FirstName"] == msg["FirstName"] and new_msg["LastName"] == msg["LastName"] and new_msg["DateTime"] == msg["DateTime"] and new_msg["ChatMessage"]["Type"] == msg["ChatMessage"]["Type"] and new_msg["ChatMessage"]["Message"] == msg["ChatMessage"]["Message"] and new_msg["ChatMessage"]["Deliver"] == msg["ChatMessage"]["Deliver"]:
				return true
	return false

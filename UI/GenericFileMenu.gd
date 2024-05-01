extends MenuButton
class_name GenericFileMenu

export (NodePath) var file_dialog: NodePath
export (NodePath) var notification_popup: NodePath

var _file_path: String setget _set_file_path

onready var notification_popup_node: NotificationPopup = get_node(notification_popup)
onready var file_dialog_node: FileDialog = get_node(file_dialog)

func _ready():
	get_popup().connect("id_pressed", self, "_on_menu_id_pressed")
	
	# Load last csv file on startup
	var file_path = _get_file_path_from_storage()
	if file_path != null and file_path != "":
		yield(file_dialog_node, "ready")
		load_file(file_path)
		
func _get_file_path_from_storage():
	pass
	
func _set_file_path_in_storage():
	pass
		
func _unhandled_input(event: InputEvent):
	if is_visible_in_tree() and Input.is_key_pressed(KEY_CONTROL) and event.is_pressed() and event is InputEventKey:
		var inputEventKey := event as InputEventKey
		if inputEventKey.scancode == KEY_N:
			new_file()
			get_tree().set_input_as_handled()
		elif inputEventKey.scancode == KEY_S:
			resave()
			get_tree().set_input_as_handled()
		elif inputEventKey.scancode == KEY_L:
			reload()
			get_tree().set_input_as_handled()

func _on_menu_id_pressed(id: int) -> void:
	match id:
		0:
			_on_new()
		1:
			_on_load()
		2:
			_on_save()
			
			
func _on_new():
	new_file()

func new_file() -> bool:
	print_debug("New file. Clearing workspace")
	_do_new_file()
	self._file_path = ""
	return true
	
func _do_new_file():
	pass
	
func _on_load():
	file_dialog_node.mode = FileDialog.MODE_OPEN_FILE
	file_dialog_node.popup()
	yield(file_dialog_node, "file_selected")
	load_file(file_dialog_node.current_path)
	
func load_file(file_path: String):
	print_debug("Loading file ", file_path)
	
	var file := File.new()
	
	if not file.file_exists(file_path):
		var err_message := "File doesn't exist"
		printerr(err_message, file_path)
		notification_popup_node.notify(err_message+": "+file_path)
		return
	
	file.open(file_path, File.READ)
	_do_load_file(file)
	file.close()
	
	self._file_path = file_path
	notification_popup_node.notify("Loaded file "+file_path)
	
func _do_load_file(file: File) -> void:
	pass
	
func reload() -> bool:
	if _file_path != "":
		load_file(_file_path)
		return true
	else:
		var err_message := "No file loaded. Didn't reload."
		print(err_message)
		notification_popup_node.notify(err_message)
		return false
		
	
func _on_save():
	file_dialog_node.mode = FileDialog.MODE_SAVE_FILE
	file_dialog_node.popup()
	var filename = yield(file_dialog_node, "file_selected")
	save_file(filename)
	
func save_file(file_path: String):
	print_debug("Saving file ", file_path)
	var file := File.new()
	
	file.open(file_path, File.WRITE)
	_do_save_file(file)
	file.close()
	
	self._file_path = file_path
	notification_popup_node.notify("Saved file "+file_path)
	
func _do_save_file(file: File) -> void:
	pass
	
func resave() -> bool:
	if _file_path != "":
		save_file(_file_path)
		return true
	else:
		var err_message := "No file loaded. Didn't save."
		print(err_message)
		notification_popup_node.notify(err_message)
		return false
		
		
func _set_file_path(file_path: String) -> void:
	_file_path = file_path
	_set_file_path_in_storage()
	
	# TODO: Move this somewhere else to handle the title via signals
	if file_path == "":
		OS.set_window_title("DDOn Tools")
	else:
		OS.set_window_title("DDOn Tools - "+file_path)
		

func store_csv_line_crlf(file: File, csv_data: Array):
	file.store_csv_line(csv_data)
	file.seek(file.get_position()-1)
	#file.store_string("\r\n")
	file.store_16(0x0A0D)
	return


static func parse_bool(string: String) -> bool:
	return string.strip_edges().to_lower() == "true"

static func find_schema_indices(schema: Array, reference: Array) -> Dictionary:
	var out := {}
	for i in range(schema.size()):
		var index = reference.find(schema[i])
		if index != -1:
			out[schema[i]] = index
	return out

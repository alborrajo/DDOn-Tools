extends MenuButton

export (NodePath) var file_dialog: NodePath
export (NodePath) var enemy_tree: NodePath

var _file_path: String

onready var file_dialog_node: FileDialog = get_node(file_dialog)
onready var enemy_tree_node: EnemyTree = get_node(enemy_tree)

func _unhandled_input(event: InputEvent):
	if Input.is_key_pressed(KEY_CONTROL) and event.is_pressed() and event is InputEventKey:
		var inputEventKey := event as InputEventKey
		if inputEventKey.scancode == KEY_S and _file_path != "":
			_do_save(_file_path)
			get_tree().set_input_as_handled()
		elif inputEventKey.scancode == KEY_L and _file_path != "":
			_do_load(_file_path)
			get_tree().set_input_as_handled()

func _ready():
	get_popup().connect("id_pressed", self, "_on_menu_id_pressed")

func _on_menu_id_pressed(id: int) -> void:
	match id:
		0:
			_on_load()
		1:
			_on_save()
			
func _on_load():
	file_dialog_node.mode = FileDialog.MODE_OPEN_FILE
	file_dialog_node.popup()
	yield(file_dialog_node, "file_selected")
	_do_load(file_dialog_node.current_path)
	
func _do_load(file_path: String):
	print_debug("Loading file ", file_path)
	
	var file := File.new()
	file.open(file_path, File.READ)
	
	# First clean current data
	for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
		if node is EnemySetPlacemark:
			var placemark := node as EnemySetPlacemark
			placemark.clear_enemies()
	
	# Then load it from the file
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 6:
			# Inefficient af, but i can't be assed
			# Storing the CSV data in a hashmap first or similar would be better
			for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
				if node is EnemySetPlacemark:
					var placemark := node as EnemySetPlacemark
					if placemark.stage_id == int(csv_line[0]) and placemark.layer_no == int(csv_line[1]) and placemark.group_id == int(csv_line[2]) and placemark.subgroup_id == int(csv_line[3]):
						placemark.add_enemy(enemy_tree_node.get_enemy_by_id(csv_line[4]))
						break
	file.close()
	
	_file_path = file_path
	OS.set_window_title("DDOn Tools - "+file_path)
	
func _on_save():
	file_dialog_node.mode = FileDialog.MODE_SAVE_FILE
	file_dialog_node.popup()
	yield(file_dialog_node, "file_selected")
	_do_save(file_dialog_node.current_path)
	
func _do_save(file_path: String):
	print_debug("Saving file ", file_path)
	
	var file := File.new()
	file.open(file_path, File.WRITE)
	for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
		if node is EnemySetPlacemark:
			var placemark := node as EnemySetPlacemark
			for enemy in placemark.get_enemies():
				file.store_csv_line([placemark.stage_id, placemark.layer_no, placemark.group_id, placemark.subgroup_id, enemy.id])
	file.close()

	_file_path = file_path
	OS.set_window_title("DDOn Tools - "+file_path)

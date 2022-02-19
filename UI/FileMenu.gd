extends MenuButton

const CSV_HEADER := PoolStringArray([
	"StageId",
	"LayerNo",
	"GroupId",
	"SubGroupId",
	"EnemyId",
	"NamedEnemyParamsId",
	"RaidBossId",
	"Scale",
	"Lv",
	"HmPresetNo",
	"StartThinkTblNo",
	"RepopNum",
	"RepopCount",
	"EnemyTargetTypesId",
	"MontageFixNo",
	"SetType",
	"InfectionType",
	"IsBossGauge",
	"IsBossBGM",
	"IsManualSet",
	"IsAreaBoss",
	"IsBloodEnemy",
	"Unk0"
])

export (NodePath) var file_dialog: NodePath
export (NodePath) var enemy_tree: NodePath
export (NodePath) var notification_popup: NodePath

var _file_path: String

onready var file_dialog_node: FileDialog = get_node(file_dialog)
onready var enemy_tree_node: EnemyTree = get_node(enemy_tree)
onready var notification_popup_node: NotificationPopup = get_node(notification_popup)

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
	
	# Check header
	var header := file.get_csv_line()
	for i in min(header.size(), CSV_HEADER.size()):
		if header[i] != CSV_HEADER[i]:
			var err_message := "Invalid CSV file. Header doesn't have a valid format "
			printerr(err_message, file_path, " ", header)
			notification_popup_node.notify(err_message)
			return
	
	# First clean current data
	for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
		if node is EnemySetPlacemark:
			var placemark := node as EnemySetPlacemark
			placemark.clear_enemies()
	
	# Then load it from the file
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 5:
			# Inefficient af, but i can't be assed
			# Storing the CSV data in a hashmap first or similar would be better
			for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
				if node is EnemySetPlacemark:
					var placemark := node as EnemySetPlacemark
					if placemark.stage_id == int(csv_line[0]) and placemark.layer_no == int(csv_line[1]) and placemark.group_id == int(csv_line[2]) and placemark.subgroup_id == int(csv_line[3]):
						placemark.add_enemy(enemy_tree_node.get_enemy_by_id(csv_line[4].hex_to_int()))
						break
	file.close()
	
	_file_path = file_path
	OS.set_window_title("DDOn Tools - "+file_path)
	
	notification_popup_node.notify("Loaded file "+file_path)
	
func _on_save():
	file_dialog_node.mode = FileDialog.MODE_SAVE_FILE
	file_dialog_node.popup()
	yield(file_dialog_node, "file_selected")
	_do_save(file_dialog_node.current_path)
	
func _do_save(file_path: String):
	print_debug("Saving file ", file_path)
	
	var file := File.new()
	file.open(file_path, File.WRITE)
	file.store_csv_line(CSV_HEADER)
	for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
		if node is EnemySetPlacemark:
			var placemark := node as EnemySetPlacemark
			for enemy in placemark.get_enemies():
				var csv_data := []
				csv_data.append(placemark.stage_id)
				csv_data.append(placemark.layer_no)
				csv_data.append(placemark.group_id)
				csv_data.append(placemark.subgroup_id)
				csv_data.append("0x%X" % enemy.id)
				# TODO: Replace placeholder values
				csv_data.append("0x%X" % 0x8FA)
				csv_data.append(0)
				csv_data.append(100)
				csv_data.append(10)
				csv_data.append(0)
				csv_data.append(0)
				csv_data.append(0)
				csv_data.append(0)
				csv_data.append(1)
				csv_data.append(0)
				csv_data.append(0)
				csv_data.append(0)
				csv_data.append(false)
				csv_data.append(false)
				csv_data.append(false)
				csv_data.append(false)
				csv_data.append(false)
				csv_data.append(false)
				file.store_csv_line(csv_data)
	file.close()

	_file_path = file_path
	OS.set_window_title("DDOn Tools - "+file_path)
	
	notification_popup_node.notify("Saved file "+file_path)

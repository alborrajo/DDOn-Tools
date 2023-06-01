extends MenuButton
class_name FileMenu

const STORAGE_SECTION_FILE_MENU = "FileMenu"
const STORAGE_KEY_FILE_PATH := "file_path"

const COMPAT_CSV_HEADER_STAGEID := "StageId"
const CSV_HEADER := PoolStringArray([
	"#StageId",
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
	"IsHighOrbEnemy"
])

export (NodePath) var file_dialog: NodePath
export (NodePath) var enemy_tree: NodePath
export (NodePath) var notification_popup: NodePath

var _file_path: String setget _set_file_path

onready var file_dialog_node: FileDialog = get_node(file_dialog)
onready var enemy_tree_node: EnemyTree = get_node(enemy_tree)
onready var notification_popup_node: NotificationPopup = get_node(notification_popup)

func _ready():
	get_popup().connect("id_pressed", self, "_on_menu_id_pressed")
	
	# Load last csv file on startup
	var file_path = StorageProvider.get_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH)
	if file_path != null and file_path != "":
		load_file(file_path)

func _unhandled_input(event: InputEvent):
	if Input.is_key_pressed(KEY_CONTROL) and event.is_pressed() and event is InputEventKey:
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
	EnemySetProvider.clear()
	self._file_path = ""
	return true

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
	
	# Check header
	var header := file.get_csv_line()
	for i in min(header.size(), CSV_HEADER.size()):
		if header[i].strip_edges() != CSV_HEADER[i] and (i == 0 and header[i] != COMPAT_CSV_HEADER_STAGEID):
			var err_message := "Invalid CSV file. Header doesn't have a valid format "
			printerr(err_message, file_path, " ", header)
			notification_popup_node.notify(err_message)
			return
	
	# Clear enemy set state
	EnemySetProvider.clear()
		
	# Then load it from the file
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		
		if csv_line.size() < 23:
			print("Ignoring line with incorrect number of columns ", csv_line)
			continue
			
		# Ignore comments
		if csv_line[0] != '' and csv_line[0][0] == '#':
			print("Ignoring comment line ", csv_line)
			continue
		
		# Send read entries to the EnemySetProvider
		var stage_id = int(csv_line[0])
		var layer_no = int(csv_line[1])
		var group_id = int(csv_line[2])
		var subgroup_id = int(csv_line[3])
		
		var enemyType := enemy_tree_node.get_enemy_by_id(csv_line[4].strip_edges().hex_to_int())
		var enemy := Enemy.new(enemyType)
		enemy.named_enemy_params_id = csv_line[5].strip_edges().hex_to_int()
		enemy.raid_boss_id = int(csv_line[6].strip_edges())
		enemy.scale = int(csv_line[7].strip_edges())
		enemy.lv = int(csv_line[8].strip_edges())
		enemy.hm_preset_no = int(csv_line[9].strip_edges())
		enemy.start_think_tbl_no = int(csv_line[10].strip_edges())
		enemy.repop_num = int(csv_line[11].strip_edges())
		enemy.repop_count = int(csv_line[12].strip_edges())
		enemy.enemy_target_types_id = int(csv_line[13].strip_edges())
		enemy.montage_fix_no = int(csv_line[14].strip_edges())
		enemy.set_type = int(csv_line[15].strip_edges())
		enemy.infection_type = int(csv_line[16].strip_edges())
		enemy.is_boss_gauge = parse_bool(csv_line[17].strip_edges())
		enemy.is_boss_bgm = parse_bool(csv_line[18].strip_edges())
		enemy.is_manual_set = parse_bool(csv_line[19].strip_edges())
		enemy.is_area_boss = parse_bool(csv_line[20].strip_edges())
		enemy.is_blood_enemy = parse_bool(csv_line[21].strip_edges())
		enemy.is_highorb_enemy = parse_bool(csv_line[22].strip_edges())
		
		var enemy_set = EnemySetProvider.get_enemy_set(stage_id, layer_no, group_id, subgroup_id)
		enemy_set.add_enemy(enemy)
	
	file.close()
	
	self._file_path = file_path
	
	notification_popup_node.notify("Loaded file "+file_path)
	
func reload() -> bool:
	if _file_path != "":
		load(_file_path)
		return true
	else:
		var err_message := "No CSV file loaded. Didn't reload."
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
	store_csv_line_crlf(file, CSV_HEADER)
	for set in EnemySetProvider.get_all_enemy_sets():
		for enemy in set.get_enemies():
			var csv_data := []
			csv_data.append(set.stage_id)
			csv_data.append(set.layer_no)
			csv_data.append(set.group_id)
			csv_data.append(set.subgroup_id)
			csv_data.append("0x%06X" % enemy.enemy_type.id)
			csv_data.append("0x%X" % enemy.named_enemy_params_id)
			csv_data.append(enemy.raid_boss_id)
			csv_data.append(enemy.scale)
			csv_data.append(enemy.lv)
			csv_data.append(enemy.hm_preset_no)
			csv_data.append(enemy.start_think_tbl_no)
			csv_data.append(enemy.repop_num)
			csv_data.append(enemy.repop_count)
			csv_data.append(enemy.enemy_target_types_id)
			csv_data.append(enemy.montage_fix_no)
			csv_data.append(enemy.set_type)
			csv_data.append(enemy.infection_type)
			csv_data.append(enemy.is_boss_gauge)
			csv_data.append(enemy.is_boss_bgm)
			csv_data.append(enemy.is_manual_set)
			csv_data.append(enemy.is_area_boss)
			csv_data.append(enemy.is_blood_enemy)
			csv_data.append(enemy.is_highorb_enemy)
			store_csv_line_crlf(file, csv_data)
			
	file.close()

	self._file_path = file_path
	
	notification_popup_node.notify("Saved file "+file_path)

func store_csv_line_crlf(file: File, csv_data: Array):
	file.store_csv_line(csv_data)
	file.seek(file.get_position()-1)
	#file.store_string("\r\n")
	file.store_16(0x0A0D)
	return
	
func resave() -> bool:
	if _file_path != "":
		save_file(_file_path)
		return true
	else:
		var err_message := "No CSV file loaded. Didn't save."
		print(err_message)
		notification_popup_node.notify(err_message)
		return false


func _set_file_path(file_path: String) -> void:
	_file_path = file_path
	StorageProvider.set_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH, _file_path)
	
	# TODO: Move this somewhere else to handle the title via signals
	if file_path == "":
		OS.set_window_title("DDOn Tools")
	else:
		OS.set_window_title("DDOn Tools - "+file_path)
	
	
static func parse_bool(string: String) -> bool:
	return string.strip_edges().to_lower() == "true"

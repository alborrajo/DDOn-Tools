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

var _unknown_stage_layout_sets := []

onready var file_dialog_node: FileDialog = get_node(file_dialog)
onready var enemy_tree_node: EnemyTree = get_node(enemy_tree)
onready var notification_popup_node: NotificationPopup = get_node(notification_popup)

func _ready():
	get_popup().connect("id_pressed", self, "_on_menu_id_pressed")
	
func _on_markers_loaded():
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
	_clean()
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
		if header[i] != CSV_HEADER[i] and (i == 0 and header[i] != COMPAT_CSV_HEADER_STAGEID):
			var err_message := "Invalid CSV file. Header doesn't have a valid format "
			printerr(err_message, file_path, " ", header)
			notification_popup_node.notify(err_message)
			return
	
	# First clean current data
	_clean()
	
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
			
		# Inefficient af, but i can't be assed
		# Storing the CSV data in a hashmap first or similar would be better
		var is_unknown_stage_layout := true
		for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
			if node is EnemySetPlacemark:
				var placemark := node as EnemySetPlacemark
				if placemark.stage_id == int(csv_line[0]) and placemark.layer_no == int(csv_line[1]) and placemark.group_id == int(csv_line[2]) and placemark.subgroup_id == int(csv_line[3]):
					var enemyType := enemy_tree_node.get_enemy_by_id(csv_line[4].hex_to_int())
					var enemy := Enemy.new(enemyType)
					enemy.named_enemy_params_id = csv_line[5].hex_to_int()
					enemy.raid_boss_id = int(csv_line[6])
					enemy.scale = int(csv_line[7])
					enemy.lv = int(csv_line[8])
					enemy.hm_preset_no = int(csv_line[9])
					enemy.start_think_tbl_no = int(csv_line[10])
					enemy.repop_num = int(csv_line[11])
					enemy.repop_count = int(csv_line[12])
					enemy.enemy_target_types_id = int(csv_line[13])
					enemy.montage_fix_no = int(csv_line[14])
					enemy.set_type = int(csv_line[15])
					enemy.infection_type = int(csv_line[16])
					enemy.is_boss_gauge = parse_bool(csv_line[17])
					enemy.is_boss_bgm = parse_bool(csv_line[18])
					enemy.is_manual_set = parse_bool(csv_line[19])
					enemy.is_area_boss = parse_bool(csv_line[20])
					enemy.is_blood_enemy = parse_bool(csv_line[21])
					enemy.is_highorb_enemy = parse_bool(csv_line[22])
					placemark.add_enemy(enemy)
					is_unknown_stage_layout = false
					break
					
		# If a EnemySetPlacemark couldn't be found for this row
		# add to the unknown stage layout data list
		# This data will later be saved back to the file to prevent losing
		# data not managed by this program
		if is_unknown_stage_layout:
			print_debug("Enemy %s found in unknown set: %s,%s,%s,%s\n\tIt won't be shown on the map" % [csv_line[4], csv_line[0], csv_line[1], csv_line[2], csv_line[3]])
			_unknown_stage_layout_sets.append(csv_line)
	
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
	yield(file_dialog_node, "file_selected")
	save_file(file_dialog_node.current_path)
	
func save_file(file_path: String):
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
				file.store_csv_line(csv_data)
				
	# Add back data for unknown stage layouts to prevent losing data
	# not managed by this program
	for csv_data in _unknown_stage_layout_sets:
		print_debug("Saving %s in unknown set: %s,%s,%s,%s" % [csv_data[4], csv_data[0], csv_data[1], csv_data[2], csv_data[3]])
		file.store_csv_line(csv_data)
	
	file.close()

	self._file_path = file_path
	
	notification_popup_node.notify("Saved file "+file_path)
	
func resave() -> bool:
	if _file_path != "":
		save_file(_file_path)
		return true
	else:
		var err_message := "No CSV file loaded. Didn't save."
		print(err_message)
		notification_popup_node.notify(err_message)
		return false

func _clean() -> void:
	_unknown_stage_layout_sets = []
	for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
		if node is EnemySetPlacemark:
			var placemark := node as EnemySetPlacemark
			placemark.clear_enemies()


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

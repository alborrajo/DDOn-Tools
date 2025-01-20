extends GenericFileMenu
class_name EnemyFileMenu

const STORAGE_SECTION_FILE_MENU = "FileMenu"
const STORAGE_KEY_FILE_PATH := "file_path"

const LEGACY_CSV_HEADER_STAGEID_COMPAT := "StageId"
const LEGACY_CSV_HEADER := PoolStringArray([
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

const ENEMIES_SCHEMA := PoolStringArray([
	"StageId",
	"LayerNo",
	"GroupId",
	"SubGroupId",
	"PositionIndex",
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
	"BloodOrbs",
	"HighOrbs",
	"Experience",
	"DropsTableId",
	"SpawnTime",
	"PPDrop"
])

const DROPS_TABLE_ITEMS_SCHEMA := PoolStringArray([
	"ItemId",
	"ItemNum",
	"MaxItemNum",
	"Quality",
	"IsHidden",
	"DropChance"
])

const JSON_KEY_SCHEMAS = "schemas"
const JSON_KEY_ENEMIES = "enemies"
const JSON_KEY_DROPS_TABLES = "dropsTables"

const JSON_KEY_ID = "id"
const JSON_KEY_NAME = "name"
const JSON_KEY_MDL_TYPE = "mdlType"
const JSON_KEY_ITEMS = "items"

export (NodePath) var enemy_tree: NodePath
export (NodePath) var item_tree: NodePath

onready var enemy_tree_node: EnemyTree = get_node(enemy_tree)
onready var item_tree_node: ItemTree = get_node(item_tree)
	
func _ready():
	._ready()
	enemy_tree_node.init_enemy_list()
	item_tree_node.init_item_list()
	
func _get_file_path_from_storage() -> String:
	return StorageProvider.get_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH)
	
func _set_file_path_in_storage() -> void:
	StorageProvider.set_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH, _file_path)


func _do_new_file() -> void:
	SetProvider.clear_drops_tables()
	SetProvider.clear_enemy_sets()


func _do_load_file(file: File) -> void:
	if file.get_path().get_extension() == "csv":
		_do_load_file_legacy(file)
		return
	elif file.get_path().get_extension() == "json":
		var result := _do_load_file_json(file)
		if result != OK:
			print("[_do_load_file] Error loading JSON file '" + str(file.get_path()) + "'.")
			print("\tError: ", result)
		
func _do_load_file_json(file: File) -> int:
	# Read file contents
	var json_parse = JSON.parse(file.get_as_text())
	if json_parse.error != OK:
		print("[load_json_file] Error loading JSON file '" + str(file.get_path()) + "'.")
		print("\tError: ", json_parse.error)
		print("\tError Line: ", json_parse.error_line)
		print("\tError String: ", json_parse.error_string)
		return json_parse.error
	
	# Clear set state
	SetProvider.clear_drops_tables()
	SetProvider.clear_enemy_sets()

	# Load loot tables
	var drops_table_schema_idx := find_schema_indices(json_parse.result[JSON_KEY_SCHEMAS][JSON_KEY_DROPS_TABLES+"."+JSON_KEY_ITEMS], DROPS_TABLE_ITEMS_SCHEMA)	
	for data in json_parse.result[JSON_KEY_DROPS_TABLES]:
		var id: int = data[JSON_KEY_ID]
		# Send read entries to the SetProvider
		var drops_table = SetProvider.get_drops_table(id)
		drops_table.name = data[JSON_KEY_NAME]
		drops_table.mdl_type = data[JSON_KEY_MDL_TYPE]

		for data_item in data[JSON_KEY_ITEMS]:
			var item_id: int = data_item[drops_table_schema_idx["ItemId"]]
			var item := item_tree_node.get_item_by_id(item_id)
			if item == null:
				push_error("Found drops table entry with an unrecognized item ID %d" % item_id)
				continue
			var drop_item := GatheringItem.new(item)

			drop_item.num = data_item[drops_table_schema_idx["ItemNum"]]
			drop_item.max_num = data_item[drops_table_schema_idx["MaxItemNum"]]
			drop_item.quality = data_item[drops_table_schema_idx["Quality"]]
			drop_item.is_hidden = data_item[drops_table_schema_idx["IsHidden"]]
			
			# Optional for compatibility with older formats
			if drops_table_schema_idx.has("DropChance"):
				drop_item.drop_chance = data_item[drops_table_schema_idx["DropChance"]]

			drops_table.add_item(drop_item)

	# Load enemy sets
	var enemies_schema_idx := find_schema_indices(json_parse.result[JSON_KEY_SCHEMAS][JSON_KEY_ENEMIES], ENEMIES_SCHEMA)		
	for data in json_parse.result[JSON_KEY_ENEMIES]:
		# Send read entries to the SetProvider
		var stage_id = data[enemies_schema_idx["StageId"]]
		var layer_no = data[enemies_schema_idx["LayerNo"]]
		var group_id = data[enemies_schema_idx["GroupId"]]
		
		var enemy_set = SetProvider.get_enemy_set(stage_id, layer_no, group_id)
		if enemy_set == null:
			printerr("Unknown enemy set: (%d, %d, %d)" % [stage_id, layer_no, group_id])
			continue
			
		var subgroup_id = data[enemies_schema_idx["SubGroupId"]]
		
		var enemy_subgroup: EnemySubgroup = enemy_set.get_subgroup(subgroup_id)
		
		var enemyType := enemy_tree_node.get_enemy_by_id(data[enemies_schema_idx["EnemyId"]].hex_to_int())
		var namedParam := DataProvider.get_named_param_by_id(data[enemies_schema_idx["NamedEnemyParamsId"]])
		var enemy := Enemy.new(enemyType, namedParam)
		enemy.raid_boss_id = data[enemies_schema_idx["RaidBossId"]]
		enemy.scale = data[enemies_schema_idx["Scale"]]
		enemy.lv = data[enemies_schema_idx["Lv"]]
		enemy.hm_preset_no = data[enemies_schema_idx["HmPresetNo"]]
		enemy.start_think_tbl_no = data[enemies_schema_idx["StartThinkTblNo"]]
		enemy.repop_num = data[enemies_schema_idx["RepopNum"]]
		enemy.repop_count = data[enemies_schema_idx["RepopCount"]]
		enemy.enemy_target_types_id = data[enemies_schema_idx["EnemyTargetTypesId"]]
		enemy.montage_fix_no = data[enemies_schema_idx["MontageFixNo"]]
		enemy.set_type = data[enemies_schema_idx["SetType"]]
		enemy.infection_type = data[enemies_schema_idx["InfectionType"]]
		enemy.is_boss_gauge = data[enemies_schema_idx["IsBossGauge"]]
		enemy.is_boss_bgm = data[enemies_schema_idx["IsBossBGM"]]
		enemy.is_manual_set = data[enemies_schema_idx["IsManualSet"]]
		enemy.is_area_boss = data[enemies_schema_idx["IsAreaBoss"]]
		enemy.blood_orbs = data[enemies_schema_idx["BloodOrbs"]]
		enemy.is_blood_enemy = enemy.blood_orbs > 0
		enemy.high_orbs = data[enemies_schema_idx["HighOrbs"]]
		enemy.is_highorb_enemy = enemy.high_orbs > 0
		enemy.experience = data[enemies_schema_idx["Experience"]]
		# The PPDrop field may or may not exist. If it doesn't exist, set to Experience over 7500
		if enemies_schema_idx.has("PPDrop"):
			enemy.play_points = data[enemies_schema_idx["PPDrop"]]
		else:
			enemy.play_points = int(enemy.experience / 7500.0)

		var drops_table_id = data[enemies_schema_idx["DropsTableId"]]
		if drops_table_id == -1:
			enemy.drops_table = null
		else:
			enemy.drops_table = SetProvider.get_drops_table(drops_table_id)	
		
		if enemies_schema_idx.has("SpawnTime"):
			var time_range_str = data[enemies_schema_idx["SpawnTime"]]
			var time_type = 0
			if time_range_str == "00:00,23:59":
				time_type = 0
			elif time_range_str == "07:00,17:59":
				time_type = 1
			elif time_range_str == "18:00,06:59":
				time_type = 2
			else:
				time_type = 3
				enemy.custom_time = time_range_str
			enemy.time_type = time_type
			
		var result: int
		if enemies_schema_idx.has("PositionIndex"):
			var position_index = data[enemies_schema_idx["PositionIndex"]]
			result = enemy_subgroup.add_enemy_at_index(enemy, position_index)
		else:
			result = enemy_subgroup.add_enemy(enemy)
		if result != OK:
				printerr("Enemy outside of the set's possible positions: ", data)

	return OK

func _do_load_file_legacy(file: File) -> void:
	# Check header
	var header := file.get_csv_line()
	for i in min(header.size(), LEGACY_CSV_HEADER.size()):
		if header[i].strip_edges() != LEGACY_CSV_HEADER[i] and (i == 0 and header[i] != LEGACY_CSV_HEADER_STAGEID_COMPAT):
			var err_message := "Invalid CSV file. Header doesn't have a valid format "
			printerr(err_message, file.get_path(), " ", header)
			notification_popup_node.notify(err_message)
			return
	
	# Clear enemy set state
	SetProvider.clear_enemy_sets()
		
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
		
		# Send read entries to the SetProvider
		var stage_id = int(csv_line[0])
		var layer_no = int(csv_line[1])
		var group_id = int(csv_line[2])
		var subgroup_id = int(csv_line[3])
		
		var enemyType := enemy_tree_node.get_enemy_by_id(csv_line[4].strip_edges().hex_to_int())
		var namedParam := DataProvider.get_named_param_by_id(csv_line[5].strip_edges().hex_to_int())
		var enemy := Enemy.new(enemyType, namedParam)
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
		
		var enemy_set = SetProvider.get_enemy_set(stage_id, layer_no, group_id)
		var enemy_subgroup = enemy_set.get_subgroup(subgroup_id)
		enemy_subgroup.add_enemy(enemy)
	
func _do_save_file(file: File) -> void:
	if file.get_path().get_extension() == "csv":
		_do_save_file_legacy(file)
		return

	var json_data = {
		JSON_KEY_SCHEMAS: {
			JSON_KEY_ENEMIES: ENEMIES_SCHEMA,
			JSON_KEY_DROPS_TABLES+"."+JSON_KEY_ITEMS: DROPS_TABLE_ITEMS_SCHEMA
		},
		JSON_KEY_DROPS_TABLES: [],
		JSON_KEY_ENEMIES: []
	}

	for drops_table in SetProvider.get_all_drops_tables():
		var json_data_table := {
			JSON_KEY_ID: drops_table.id,
			JSON_KEY_NAME: drops_table.name,
			JSON_KEY_MDL_TYPE: drops_table.mdl_type,
			JSON_KEY_ITEMS: []
		}
		for drop_item in drops_table.get_items():
			var json_data_table_item := [
				drop_item.item.id,
				drop_item.num,
				drop_item.max_num,
				drop_item.quality,
				drop_item.is_hidden,
				drop_item.drop_chance
			]
			json_data_table[JSON_KEY_ITEMS].append(json_data_table_item)
		json_data[JSON_KEY_DROPS_TABLES].append(json_data_table)

	for set in SetProvider.get_all_enemy_sets():
		for subgroup_id in set.subgroups.size():
			var subgroup: EnemySubgroup = set.subgroups[subgroup_id]
			if subgroup != null:
				for position_index in subgroup.positions.size():
					for enemy in subgroup.positions[position_index].enemies:
						if enemy != null:
							var data = []
							data.append(set.stage_id)
							data.append(set.layer_no)
							data.append(set.group_id)
							data.append(subgroup_id)
							data.append(position_index)
							data.append("0x%06X" % enemy.enemy_type.id)
							data.append(enemy.named_param.id)
							data.append(enemy.raid_boss_id)
							data.append(enemy.scale)
							data.append(enemy.lv)
							data.append(enemy.hm_preset_no)
							data.append(enemy.start_think_tbl_no)
							data.append(enemy.repop_num)
							data.append(enemy.repop_count)
							data.append(enemy.enemy_target_types_id)
							data.append(enemy.montage_fix_no)
							data.append(enemy.set_type)
							data.append(enemy.infection_type)
							data.append(enemy.is_boss_gauge)
							data.append(enemy.is_boss_bgm)
							data.append(enemy.is_manual_set)
							data.append(enemy.is_area_boss)

							if enemy.is_blood_enemy:
								data.append(enemy.blood_orbs)
							else:
								data.append(0)

							if enemy.is_highorb_enemy:
								data.append(enemy.high_orbs)
							else:
								data.append(0)

							data.append(enemy.experience)

							if enemy.drops_table != null:
								data.append(enemy.drops_table.id)
							else:
								data.append(-1)
							
							var selected_index = enemy.time_type
							var selected_string = ""
							if selected_index == 0:
								selected_string = "00:00,23:59"
							if selected_index == 1:
								selected_string = "07:00,17:59"
							if selected_index == 2:
								selected_string = "18:00,06:59"	
							if selected_index == 3:
								selected_string = enemy.custom_time
							data.append(selected_string)

							data.append(enemy.play_points)

							json_data[JSON_KEY_ENEMIES].append(data)

	file.store_string(JSON.print(json_data, "\t"))


func _do_save_file_legacy(file) -> void:
	store_csv_line_crlf(file, LEGACY_CSV_HEADER)
	for set in SetProvider.get_all_enemy_sets():
		for subgroup_id in set.subgroups.size():
			var subgroup: EnemySubgroup = set.subgroups[subgroup_id]
			if subgroup != null:
				for position_index in set.subgroups[subgroup_id].positions.size():
					for enemy in set.subgroups[subgroup_id].positions[position_index].enemies:
						if enemy != null:
							var data := []
							data.append(set.stage_id)
							data.append(set.layer_no)
							data.append(set.group_id)
							data.append(subgroup_id)
							data.append("0x%06X" % enemy.enemy_type.id)
							data.append("0x%X" % enemy.named_param.id)
							data.append(enemy.raid_boss_id)
							data.append(enemy.scale)
							data.append(enemy.lv)
							data.append(enemy.hm_preset_no)
							data.append(enemy.start_think_tbl_no)
							data.append(enemy.repop_num)
							data.append(enemy.repop_count)
							data.append(enemy.enemy_target_types_id)
							data.append(enemy.montage_fix_no)
							data.append(enemy.set_type)
							data.append(enemy.infection_type)
							data.append(enemy.is_boss_gauge)
							data.append(enemy.is_boss_bgm)
							data.append(enemy.is_manual_set)
							data.append(enemy.is_area_boss)
							data.append(enemy.is_blood_enemy)
							data.append(enemy.is_highorb_enemy)
							store_csv_line_crlf(file, data)

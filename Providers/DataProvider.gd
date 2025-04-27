extends Node

export (String, FILE, "*.csv") var enemy_csv := "res://resources/enemies.csv"
export (String, FILE, "*.csv") var items_csv := "res://resources/items.csv"

export (String, FILE, "*.json") var named_param_json := "res://resources/named_param.ndp.json"
export (String, FILE, "*.csv") var map_dimensions_csv := "res://resources/maps/dimensions.csv"
export (String, FILE, "*.json") var stage_custom_json := "res://resources/StageCustom.json"
export (String, FILE, "*.csv") var stage_room_csv := "res://resources/StageRoom.csv"
export (String, FILE, "*.json") var stage_list_json := "res://resources/StageList.json"
export (String, FILE, "*.json") var repo_json := "res://resources/repo.json"
export (String, FILE, "*.json") var gathering_spots_json := "res://resources/gatheringSpots.json"
export (String, FILE, "*.json") var enemy_positions_json := "res://resources/enemyPositions.json"
export (String, FILE, "*.json") var shops_json := "res://resources/shops.json"

var enemy_list: Array
var item_list: Array

var named_params: Array
var map_dimensions: Dictionary
var stage_custom: Dictionary
var stage_room: Dictionary
var stage_list: Array
var repo: Dictionary
var enemy_sets: Dictionary
var gathering_spots: Dictionary
var shops: Dictionary

func _ready():
	enemy_list = []
	var file := File.new()
	assert(file.open(enemy_csv, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 3:
			var enemy := EnemyType.new(csv_line[0].hex_to_int(), int(csv_line[2]), int(csv_line[3]))
			enemy_list.append(enemy)
	file.close()

	item_list = []
	file = File.new()
	assert(file.open(items_csv, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 3:
			var item := Item.new(int(csv_line[0]), int(csv_line[1]), int(csv_line[2]), int(csv_line[3]), int(csv_line[4]))
			item_list.append(item)
	file.close()

	named_params = []
	var loaded_named_param_json: Dictionary = Common.load_json_file(named_param_json)
	for named_param_dict in loaded_named_param_json["namedParamList"]:
		var named_param := NamedParam.new(named_param_dict)
		named_params.append(named_param)
		
	stage_custom = Common.load_json_file(stage_custom_json)
	stage_list = Common.load_json_file(stage_list_json)
	repo = Common.load_json_file(repo_json)
	gathering_spots = Common.load_json_file(gathering_spots_json)
	shops = Common.load_json_file(shops_json)

	enemy_sets = {}
	var enemy_positions: Dictionary = Common.load_json_file(enemy_positions_json)
	for stage_no in enemy_positions:
		for enemy_position in enemy_positions[stage_no]:
			if not stage_no in enemy_sets:
				enemy_sets[stage_no] = []
			var existing_enemy_set = null
			
			# TODO: Optimize this 
			for enemy_set in enemy_sets[stage_no]:
				if enemy_set["GroupNo"] == enemy_position["GroupNo"]:# and enemy_set["SubGroupNo"] == enemy_position["SubGroupNo"]:
					existing_enemy_set = enemy_set
					break

			if existing_enemy_set == null:
				existing_enemy_set = {}
				existing_enemy_set["GroupNo"] = enemy_position["GroupNo"]
				#existing_enemy_set["SubGroupNo"] = enemy_position["SubGroupNo"]
				existing_enemy_set["Positions"] = []
				enemy_sets[stage_no].append(existing_enemy_set)

			existing_enemy_set["Positions"].append(enemy_position["Position"])
	
	stage_room = {}
	file = File.new()
	assert(file.open(stage_room_csv, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 2:
			stage_room[int(csv_line[0])] = RoomMap.new(csv_line[1], Vector2(float(csv_line[2]), float(csv_line[3])))
	file.close()

	map_dimensions = {}
	file = File.new()
	assert(file.open(map_dimensions_csv, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 2:
			map_dimensions[csv_line[0]] = Vector2(int(csv_line[1]), int(csv_line[2]))
	file.close()

func get_enemy_by_id(id: int) -> EnemyType:
	# Also inefficient af
	for enemy_type in DataProvider.enemy_list:
		if enemy_type.id == id:
			return enemy_type
	printerr("Couldn't find enemy with id", id)
	return null

func get_item_by_id(id: int) -> Item:
	# Also inefficient af
	for item in DataProvider.item_list:
		if item.id == id:
			return item
	printerr("Couldn't find item with id", id)
	return null

func stage_no_to_stage_map(stage_no: int) -> Dictionary:
	return stage_custom.get(String(stage_no))

func stage_no_to_stage_room(stage_no: int) -> RoomMap:
	return stage_room.get(stage_no)

func stage_no_to_stage_id(stage_no: int) -> int:
	for stage in stage_list:
		if stage["StageNo"] == stage_no:
			return stage["ID"]
			
	push_warning("No stage found with StageNo %s" % stage_no)
	return -1
	
func stage_id_to_stage_no(stage_id: int) -> int:
	for stage in stage_list:
		if stage["ID"] == stage_id:
			return stage["StageNo"]
			
	push_warning("No stage found with Stage ID %s" % stage_id)
	return -1

## Returns -1 if it doesn't belong to a field
func stage_no_to_belonging_field_id(stage_no: int) -> int:
	for field_area_info in repo["FieldAreaList"]["FieldAreaInfos"]:
		if field_area_info["StageNoList"].has(float(stage_no)):
			return int(field_area_info["FieldAreaId"])
	return -1


func get_named_param_by_id(id: int) -> NamedParam:
	for named_param in named_params:
		if named_param.id == id:
			return named_param
	printerr("Couldn't find named param with id ", id)
	return null

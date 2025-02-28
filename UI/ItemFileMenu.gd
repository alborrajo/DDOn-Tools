extends GenericFileMenu
class_name ItemFileMenu

const STORAGE_SECTION_FILE_MENU = "FileMenu"
const STORAGE_KEY_FILE_PATH := "gathering_spot_file_path"

const LEGACY_SCHEMA_LENGTH := 8
const LEGACY_SCHEMA_INDEXES := {
	"StageId": 0,
	"LayerNo": 1,
	"GroupId": 2,
	"PosId": 3,
	"ItemId": 4,
	"ItemNum": 5,
	"MaxItemNum": 5,
	"Quality": 6,
	"IsHidden": 7
}

const SCHEMA := PoolStringArray([
	"StageId",
	"LayerNo",
	"GroupId",
	"PosId",
	"ItemId",
	"ItemNum",
	"MaxItemNum",
	"Quality",
	"IsHidden",
	"DropChance"
])

export (NodePath) var item_tree: NodePath

onready var item_tree_node: ItemTree = get_node(item_tree)

func _ready():
	._ready()
	item_tree_node.init_item_list()

func _get_file_path_from_storage() -> String:
	return StorageProvider.get_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH)
	
func _set_file_path_in_storage() -> void:
	StorageProvider.set_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH, _file_path)

func _do_new_file() -> void:
	SetProvider.clear_gathering_spots()
	
func _do_load_file(file: File) -> void:
	# Check header
	var header := file.get_csv_line()
	var schema_indices: Dictionary
	if header.size() == LEGACY_SCHEMA_LENGTH:
		schema_indices = LEGACY_SCHEMA_INDEXES
	else:
		header[0] = header[0].trim_prefix("#")
		schema_indices = find_schema_indices(header, SCHEMA)
		
	# Clear enemy set state
	SetProvider.clear_gathering_spots()
		
	# Then load it from the file
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
			
		# Ignore comments
		if csv_line.size() == 0 or len(csv_line[0]) == 0 or csv_line[0][0] == '#':
			print("Ignoring comment line ", csv_line)
			continue
		
		# Send read entries to the SetProvider
		var stage_id = int(csv_line[schema_indices["StageId"]])
		var _layer_no = int(csv_line[schema_indices["LayerNo"]]) # TODO: Figure out LayerNo
		var group_id = int(csv_line[schema_indices["GroupId"]])
		var subgroup_id = int(csv_line[schema_indices["PosId"]])
		
		var item := item_tree_node.get_item_by_id(int(csv_line[schema_indices["ItemId"]].strip_edges()))
		if item == null:
			push_error("Found gathering spot entry with an unrecognized item "+ String(csv_line))
			continue
			
		var gathering_item := GatheringItem.new(item)
		gathering_item.num = int(csv_line[schema_indices["ItemNum"]].strip_edges())
		gathering_item.max_num = int(csv_line[schema_indices["MaxItemNum"]].strip_edges())
		gathering_item.quality = int(csv_line[schema_indices["Quality"]].strip_edges())
		gathering_item.is_hidden = parse_bool(csv_line[schema_indices["IsHidden"]].strip_edges())
		
		# Optional for compatibility with older formats
		if schema_indices.has("DropChance"):
			gathering_item.drop_chance = float(csv_line[schema_indices["DropChance"]].strip_edges()) * 100
		
		var gathering_spot = SetProvider.get_gathering_spot(stage_id, group_id, subgroup_id)
		gathering_spot.add_item(gathering_item)
	
	
func _do_save_file(file: File) -> void:
	# Store header
	file.store_string("#")
	store_csv_line_crlf(file, SCHEMA)
	
	# Store contents
	for spot in SetProvider.get_all_gathering_spots():
		for gathering_item in spot.get_gathering_items():
			var csv_data := []
			csv_data.append(spot.stage_id)
			csv_data.append(0)
			csv_data.append(spot.group_id)
			csv_data.append(spot.subgroup_id)
			csv_data.append(gathering_item.item.id)
			csv_data.append(gathering_item.num)
			csv_data.append(gathering_item.max_num)
			csv_data.append(gathering_item.quality)
			csv_data.append(gathering_item.is_hidden)
			csv_data.append(gathering_item.drop_chance / 100)
			store_csv_line_crlf(file, csv_data)

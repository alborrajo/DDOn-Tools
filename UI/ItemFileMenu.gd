extends GenericFileMenu
class_name ItemFileMenu

const STORAGE_SECTION_FILE_MENU = "FileMenu"
const STORAGE_KEY_FILE_PATH := "gathering_spot_file_path"

const CSV_HEADER := PoolStringArray([
	"#StageId",
	"LayerNo",
	"GroupId",
	"PosId",
	"ItemId",
	"ItemNum",
	"Unk3",
	"Unk4"
])

export (NodePath) var item_tree: NodePath

onready var item_tree_node: ItemTree = get_node(item_tree)
	
func _get_file_path_from_storage() -> String:
	return StorageProvider.get_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH)
	
func _set_file_path_in_storage() -> void:
	StorageProvider.set_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH, _file_path)

func _do_new_file() -> void:
	SetProvider.clear_gathering_spots()
	
func _do_load_file(file: File) -> void:
	# Check header
	var header := file.get_csv_line()
	for i in min(header.size(), CSV_HEADER.size()):
		if header[i].strip_edges() != CSV_HEADER[i]:
			var err_message := "Invalid CSV file. Header doesn't have a valid format "
			printerr(err_message, file.get_path(), " ", header)
			notification_popup_node.notify(err_message)
			return
	
	# Clear enemy set state
	SetProvider.clear_gathering_spots()
		
	# Then load it from the file
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		
		if csv_line.size() < CSV_HEADER.size():
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
		
		var item := item_tree_node.get_item_by_id(int(csv_line[4].strip_edges()))
		if item == null:
			push_error("Found gathering spot entry with an unrecognized item "+ String(csv_line))
			continue
			
		var gathering_item := GatheringItem.new(item)
		gathering_item.num = int(csv_line[5].strip_edges())
		gathering_item.quality = int(csv_line[6].strip_edges())
		gathering_item.is_hidden = parse_bool(csv_line[7].strip_edges())
		
		var gathering_spot = SetProvider.get_gathering_spot(stage_id, group_id, subgroup_id)
		gathering_spot.add_item(gathering_item)
	
	
func _do_save_file(file: File) -> void:
	store_csv_line_crlf(file, CSV_HEADER)
	for spot in SetProvider.get_all_gathering_spots():
		for gathering_item in spot.get_gathering_items():
			var csv_data := []
			csv_data.append(spot.stage_id)
			csv_data.append(0)
			csv_data.append(spot.group_id)
			csv_data.append(spot.subgroup_id)
			csv_data.append(gathering_item.item.id)
			csv_data.append(gathering_item.num)
			csv_data.append(gathering_item.quality)
			csv_data.append(gathering_item.is_hidden)
			store_csv_line_crlf(file, csv_data)

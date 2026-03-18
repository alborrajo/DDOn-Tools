extends Control
class_name Main

const MAX_LAYERS = 10

const EnemyPlacemarkScene = preload("res://UI/Marker/ToggleableEnemySubgroupPlacemark.tscn")
const GatheringPlacemarkScene = preload("res://UI/Marker/ToggleableGatheringSpotPlacemark.tscn")
const ShopPlacemarkScene = preload("res://UI/Marker/ToggleableShopPlacemark.tscn")

@onready var camera: Camera2D = $camera
@onready var map_layers: Node2D = $MapCoordinateSpace/MapLayers
@onready var enemy_sets_node: Control = $MapCoordinateSpace/EnemySetMarkers
@onready var gathering_spots_node: Control = $MapCoordinateSpace/GatheringSpotMarkers
@onready var shops_node: Control = $MapCoordinateSpace/ShopMarkers
@onready var players_node: Control = $MapCoordinateSpace/PlayerMarkers
@onready var ui_node = $ui

@onready var tab_and_map_nodes = [
	[],
	[enemy_sets_node],
	[gathering_spots_node, shops_node],
	[players_node],
	[]
]


var camera_tween: Tween
var _pending_map_loads := []

# Variables para la adición escalonada de marcadores
var _pending_marker_queue := []
var _pending_marker_subgroup_id = null

func _ready():
	camera_tween = get_tree().create_tween()
	
	# Select Lestania by default, simulating a click on its selector
	# TODO: In a less hacky way, using a Provider. Decoupling map selection logic from the selector/ui node itself
	$ui/left/tab/Stages/StageItemTree.get_root().get_child(0).select(0)
	
	# Select Layer 0 by default, also a hacky way
	$ui/status_view/container/LayerOptionButton.select(0)
	$ui/status_view/container/LayerOptionButton.emit_signal("item_selected", 0)
	
	_on_ui_settings_updated()

func _process(_delta):
	if _pending_marker_queue != null and _pending_marker_queue.size() > 0:
		var markers_per_frame = 10
		var added = 0
		while _pending_marker_queue.size() > 0 and added < markers_per_frame:
			var entry = _pending_marker_queue.pop_front()
			var t = entry.type
			var d = entry.data
			if t == "enemy":
				var enemy_subgroup_placemark = EnemyPlacemarkScene.instantiate()
				assert(enemy_subgroup_placemark.connect("enemy_subgroup_mouse_entered", Callable(ui_node, "_on_enemy_subgroup_placemark_mouse_entered").bind(_pending_marker_subgroup_id, enemy_subgroup_placemark)) == OK)
				assert(enemy_subgroup_placemark.connect("enemy_subgroup_mouse_exited", Callable(ui_node, "_on_enemy_subgroup_placemark_mouse_exited").bind(_pending_marker_subgroup_id, enemy_subgroup_placemark)) == OK)
				enemy_subgroup_placemark.enemy_set = d.enemy_set
				enemy_subgroup_placemark.enemy_subgroup = d.enemy_subgroup
				enemy_sets_node.add_child(enemy_subgroup_placemark)
			elif t == "gathering":
				var gathering_placemark = GatheringPlacemarkScene.instantiate()
				assert(gathering_placemark.connect("subgroup_mouse_entered", Callable(ui_node, "_on_gathering_subgroup_placemark_mouse_entered").bind(gathering_placemark)) == OK)
				assert(gathering_placemark.connect("subgroup_mouse_exited", Callable(ui_node, "_on_gathering_subgroup_placemark_mouse_exited").bind(gathering_placemark)) == OK)
				gathering_placemark.gathering_spot = d.entity
				gathering_spots_node.add_child(gathering_placemark)
			elif t == "shop":
				var shop_placemark = ShopPlacemarkScene.instantiate()
				assert(shop_placemark.connect("subgroup_mouse_entered", Callable(ui_node, "_on_shop_placemark_mouse_entered").bind(shop_placemark)) == OK)
				assert(shop_placemark.connect("subgroup_mouse_exited", Callable(ui_node, "_on_shop_placemark_mouse_exited").bind(shop_placemark)) == OK)
				shop_placemark.stage_id = d.stage_id
				shop_placemark.npc_id = d.npc_id
				shop_placemark.institution_function_id = d.institution_function_id
				shop_placemark.coordinates = d.pos
				shop_placemark.shop = d.shop_entity
				shops_node.add_child(shop_placemark)
			added += 1
			
		if _pending_marker_queue.size() == 0:
			_focus_camera_on_center()

	if _pending_map_loads.size() > 0:
		var finished = []
		for i in range(_pending_map_loads.size()):
			var entry = _pending_map_loads[i]
			var status = ResourceLoader.load_threaded_get_status(entry.path)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				var result = ResourceLoader.load_threaded_get(entry.path)
				if result is Texture2D:
					var map_sprite := Sprite2D.new()
					map_sprite.texture = result
					map_sprite.centered = false
					map_sprite.global_position = entry.offset * MapControl.MAP_SCALE
					map_sprite.scale = Vector2.ONE * MapControl.MAP_SCALE
					var layer := map_layers.get_child(entry.layer_index)
					layer.add_child(map_sprite)
					print("Loaded map ", entry.path)
				else:
					printerr("Error loading map in background: ", entry.path)
				finished.append(i)
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				printerr("Error loading map in background: ", entry.path)
				finished.append(i)
		# Remove the processed files in reverse order to avoid breaking indexes
		for j in range(finished.size() - 1, -1, -1):
			_pending_map_loads.remove_at(finished[j])

func _on_ui_stage_selected(stage_no):
	_clear_map()
	_load_stage_map(stage_no)
	_clear_markers()
	_load_stage_markers(stage_no, $ui.current_subgroup_id)
	_update_layer_selector()
	_focus_camera_on_center()
	
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	if stage_id == -1:
		print("Selected stage ??? (ID: ???, Stage No. %s)" % [stage_no])
	else:
		print("Selected stage %s (ID: %s, Stage No. %s)" % [tr(str("STAGE_NAME_",stage_id)), stage_id, stage_no])


func _load_stage_map(stage_no: String) -> void:
	var stage_no_as_int := int(stage_no)
	
	if _add_field_maps(stage_no_as_int):
		return

	if _add_room_maps(stage_no_as_int):
		return

	if _add_parts_dungeon_maps(stage_no_as_int):
		return

	printerr("Couldn't find a map of any kind for this stage (Stage No. %s)" % [stage_no])

func _add_field_maps(stage_no: int) -> bool:
	var field_id = DataProvider.stage_no_to_belonging_field_id(stage_no)
	if field_id == -1:
		print("Couldn't use a field map for this stage (Stage No. %s doesn't belong to a field)" % [stage_no])
		return false

	var map_name := "field00"+str(field_id-1) # why is it off by one? maybe it needs an additional conversion?
	if not _do_add_field_maps(map_name, 0, 0):
		# Since Mergoda Ruins uses m01_l01 instead of m00_l00 like the rest
		return _do_add_field_maps(map_name, 1, 1)
	return true

func _do_add_field_maps(map_name: String, m: int, l: int) -> bool:
	var stage_map_resource := "res://resources/maps/"+map_name+"_m0"+str(m)+"_l"+str(l)+".png"
	if not _map_resource_exists(stage_map_resource):
		print("Couldn't find a field map for this field (%s)" % [map_name])
		return false
	else:
		_load_and_add_map_to(stage_map_resource, l)
		return true

func _add_room_maps(stage_no: int) -> bool:
	var stage_room := DataProvider.stage_no_to_stage_room(stage_no)
	var found_map := false
	if stage_room != null:
		for layer_index in range(MAX_LAYERS):
			var _layer := map_layers.get_child(layer_index)
			var stage_map_resource := "res://resources/maps/"+stage_room.map_name+"_l"+str(layer_index)+".png"
			if not _map_resource_exists(stage_map_resource):
				print("Couldn't find the map ", stage_map_resource)
			else:
				found_map = true
				_load_and_add_map_to(stage_map_resource, layer_index, stage_room.offset)
	else:
		print("Couldn't find an associated lobby (lb) or room (rm) map for this stage (Stage No. %s)" % [stage_no])
	return found_map

func _add_parts_dungeon_maps(stage_no: int) -> bool:
	var stage_map := DataProvider.stage_no_to_stage_map(stage_no)
	var found_map := false
	if !stage_map.is_empty():
		var offset := Vector2(0,-512) # 512 (map tile height in px)
		if stage_map != null:
			var parts_path: String = stage_map["PartsPath"].substr(7, 5)
			for area in stage_map["ArrayArea"]:
				var map_name := parts_path+"_m"+str(int(area)).pad_zeros(2)
				for layer_index in range(MAX_LAYERS):
					var stage_map_resource := "res://resources/maps/"+map_name+"_l"+str(layer_index)+".png"
					if not _map_resource_exists(stage_map_resource):
						print("Couldn't find the map ", stage_map_resource)
					else:
						found_map = true
						_load_and_add_map_to(stage_map_resource, layer_index, offset)
				if map_name in DataProvider.map_dimensions:
					offset.y = offset.y - DataProvider.map_dimensions[map_name].y
				else:
					printerr("Failed to get dimensions of map "+map_name+". The next parts of this map will show up with a wrong offset.")
		else:
			print("Couldn't assemble a parts dungeon (pd) map (Stage No. %s)" % [stage_no])
	return found_map
	
func _load_and_add_map_to(map_resource_path: String, layer_index: int, offset: Vector2 = Vector2.ZERO) -> void:
	ResourceLoader.load_threaded_request(map_resource_path)
	_pending_map_loads.append({
		"path": map_resource_path,
		"layer_index": layer_index,
		"offset": offset
	})


func _load_stage_markers(stage_no, subgroup_id):
	_pending_marker_queue.clear()
	_pending_marker_subgroup_id = subgroup_id
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	
	for enemy_set in SetProvider.get_all_enemy_sets():
		if enemy_set.stage_id == stage_id:
			var enemy_subgroup = enemy_set.get_subgroup(subgroup_id)
			if enemy_subgroup.positions.size() > 0:
				_pending_marker_queue.append({"type": "enemy", "data": {"enemy_set": enemy_set, "enemy_subgroup": enemy_subgroup}})

	if String(stage_no) in DataProvider.gathering_spots:
		for gathering_spot in DataProvider.gathering_spots[String(stage_no)]:
			var type = int(gathering_spot.get("GatheringType", 0))
			if type != 30 and type != 36:
				var group_no = int(gathering_spot["GroupNo"])
				var pos_id = int(gathering_spot["PosId"])
				var pos = Vector3(gathering_spot["Position"]["x"], gathering_spot["Position"]["y"], gathering_spot["Position"]["z"])
				var unit_id = int(gathering_spot["UnitId"])
				var gathering_spot_entity = SetProvider.get_gathering_spot(stage_id, group_no, pos_id)
				gathering_spot_entity.type = type
				gathering_spot_entity.unit_id = unit_id
				gathering_spot_entity.coordinates = pos
				_pending_marker_queue.append({"type": "gathering", "data": {"entity": gathering_spot_entity}})

	if String(stage_no) in DataProvider.shops:
		for shop in DataProvider.shops[String(stage_no)]:
			var npc_id = int(shop["NpcId"])
			var institution_function_id = int(shop["InstitutionFunctionId"])
			var shop_id = int(shop["ShopId"])
			var pos = Vector3(shop["Position"]["x"], shop["Position"]["y"], shop["Position"]["z"])
			var shop_entity = SetProvider.get_shop(shop_id)
			_pending_marker_queue.append({"type": "shop", "data": {
				"stage_id": stage_id,
				"npc_id": npc_id,
				"institution_function_id": institution_function_id,
				"shop_entity": shop_entity,
				"pos": pos
			}})


func _map_resource_exists(resource_path: String) -> bool:
	return image_array_jorobate_flanders.has(resource_path)

func _clear_map():
	for layer in map_layers.get_children():
		for map in layer.get_children():
			layer.remove_child(map)

func _clear_markers() -> void:
	# Clear previous selected stage markers
	for child in enemy_sets_node.get_children():
		enemy_sets_node.remove_child(child)
		
	for child in gathering_spots_node.get_children():
		gathering_spots_node.remove_child(child)
		
	for child in shops_node.get_children():
		shops_node.remove_child(child)


func _on_ui_player_activated(player: PlayerMapEntity):
	$ui/left/tab/Stages/HBoxContainer/StagesLineEdit.text = ""
	$ui/left/tab/Stages/HBoxContainer/StagesLineEdit.emit_signal("text_changed", "")
	for stage_element in $ui/left/tab/Stages/StageItemTree.get_root().get_children():
		if stage_element.get_metadata(0) == str(player.StageNo):
			# TODO: Decouple, same as _ready
			stage_element.select(0)
			if camera_tween:
				camera_tween.kill()
			var player_node = players_node.get_player_node(player)
			if player_node != null:
				_move_camera_to(player_node.global_position)
				return
	printerr("Couldnt focus map on %s %s (StageNo: %s)" % [player.FirstName, player.LastName, player.StageNo])


func _update_layer_selector() -> void:
	# TODO: Decouple
	var layer_to_select := -1
	for layer_index in range(map_layers.get_child_count()):
		var layer_is_empty := map_layers.get_child(layer_index).get_child_count() == 0
		$ui/status_view/container/LayerOptionButton.set_item_disabled(layer_index, layer_is_empty)
		if not layer_is_empty:
			layer_to_select = layer_index

	if layer_to_select != -1:
		# TODO: Fix this mess, same as with _ready
		$ui/status_view/container/LayerOptionButton.select(layer_to_select)
		$ui/status_view/container/LayerOptionButton.emit_signal("item_selected", layer_to_select)

func _focus_camera_on_center() -> void:
	var new_position = null
	if enemy_sets_node.get_child_count() > 0:
		new_position = _get_enemy_groups_center()
	elif map_layers.get_child(0).get_child_count() > 0:
		new_position = _get_map_center()
	
	if new_position != null:
		_move_camera_to(new_position)


func _move_camera_to(new_position: Vector2) -> void:
	if camera_tween.finished:
		camera_tween.kill()
		camera_tween = get_tree().create_tween()
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(camera, "position", new_position, 0.5)
	return


func _on_layer_selected(selected_layer_index):
	for layer_index in range(map_layers.get_child_count()):
		var layer := map_layers.get_child(layer_index) as Node2D
		layer.modulate.a = clamp(float(layer_index+1) / float(selected_layer_index+1), 0, 1)
		layer.visible = layer_index <= selected_layer_index

func _on_ui_subgroup_changed(subgroup_id):
	_clear_markers()
	_load_stage_markers($ui.current_stage_no, subgroup_id)

func _get_enemy_groups_center() -> Vector2:
	var min_x: int = 9223372036854775807
	var max_x: int = -9223372036854775807
	var min_y: int = 9223372036854775807
	var max_y: int = -9223372036854775807
	
	for enemy_group in enemy_sets_node.get_children():
		for enemy_position in enemy_group.get_position_placemarks():
			var map_position: Vector2 = enemy_position.get_global_rect().get_center()
			min_x = int(min(min_x, map_position.x))
			max_x = int(max(max_x, map_position.x))
			min_y = int(min(min_y, map_position.y))
			max_y = int(max(max_y, map_position.y))
		
	return Rect2(min_x, min_y, max_x-min_x, max_y-min_y).get_center()

func _get_map_center() -> Vector2:
	var min_x: int = 9223372036854775807
	var max_x: int = -9223372036854775807
	var min_y: int = 9223372036854775807
	var max_y: int = -9223372036854775807
	
	for map_layer in map_layers.get_children():
		for map in map_layer.get_children():
			var map_position: Vector2 = map.to_global(map.get_rect().get_center())
			min_x = int(min(min_x, map_position.x))
			max_x = int(max(max_x, map_position.x))
			min_y = int(min(min_y, map_position.y))
			max_y = int(max(max_y, map_position.y))
		
	return Rect2(min_x, min_y, max_x-min_x, max_y-min_y).get_center()

func _on_tab_changed(tab):
	for i in range(tab_and_map_nodes.size()):
		for node in tab_and_map_nodes[i]:
			node.visible = tab == i
	
	if StorageProvider.get_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS_DEFAULT):
		players_node.visible = true

func _on_ui_settings_updated():
	players_node.visible = tab_and_map_nodes[ui_node.current_tab].has(players_node) or StorageProvider.get_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS_DEFAULT)

# i have to do this bs otherwise godot refuses to export the files
const image_array_jorobate_flanders := [
	"res://resources/maps/field000_m00_l0.png",
	"res://resources/maps/field001_m00_l0.png",
	"res://resources/maps/field002_m01_l1.png",
	"res://resources/maps/field003_m00_l0.png",
	"res://resources/maps/field004_m00_l0.png",
	"res://resources/maps/field005_m00_l0.png",
	"res://resources/maps/field007_m00_l0.png",
	"res://resources/maps/lb000_m00_l0.png",
	"res://resources/maps/lb001_m00_l0.png",
	"res://resources/maps/lb002_m00_l0.png",
	"res://resources/maps/lb003_m00_l0.png",
	"res://resources/maps/lb003_m00_l1.png",
	"res://resources/maps/lb003_m00_l2.png",
	"res://resources/maps/lb010_m00_l0.png",
	"res://resources/maps/lb010_m00_l1.png",
	"res://resources/maps/lb010_m00_l2.png",
	"res://resources/maps/lb011_m00_l0.png",
	"res://resources/maps/lb011_m01_l0.png",
	"res://resources/maps/lb011_m02_l0.png",
	"res://resources/maps/pd000_m00_l0.png",
	"res://resources/maps/pd000_m01_l0.png",
	"res://resources/maps/pd000_m02_l0.png",
	"res://resources/maps/pd000_m03_l0.png",
	"res://resources/maps/pd000_m04_l0.png",
	"res://resources/maps/pd000_m04_l1.png",
	"res://resources/maps/pd000_m05_l0.png",
	"res://resources/maps/pd000_m06_l0.png",
	"res://resources/maps/pd000_m07_l0.png",
	"res://resources/maps/pd000_m08_l0.png",
	"res://resources/maps/pd000_m09_l0.png",
	"res://resources/maps/pd000_m10_l0.png",
	"res://resources/maps/pd000_m11_l0.png",
	"res://resources/maps/pd000_m12_l0.png",
	"res://resources/maps/pd000_m13_l0.png",
	"res://resources/maps/pd000_m14_l0.png",
	"res://resources/maps/pd000_m15_l0.png",
	"res://resources/maps/pd000_m16_l0.png",
	"res://resources/maps/pd000_m17_l0.png",
	"res://resources/maps/pd000_m18_l0.png",
	"res://resources/maps/pd000_m21_l0.png",
	"res://resources/maps/pd000_m22_l0.png",
	"res://resources/maps/pd000_m23_l0.png",
	"res://resources/maps/pd001_m00_l0.png",
	"res://resources/maps/pd001_m01_l0.png",
	"res://resources/maps/pd001_m02_l0.png",
	"res://resources/maps/pd001_m03_l0.png",
	"res://resources/maps/pd001_m04_l0.png",
	"res://resources/maps/pd001_m05_l0.png",
	"res://resources/maps/pd001_m06_l0.png",
	"res://resources/maps/pd001_m06_l1.png",
	"res://resources/maps/pd001_m07_l0.png",
	"res://resources/maps/pd001_m08_l0.png",
	"res://resources/maps/pd001_m09_l0.png",
	"res://resources/maps/pd001_m10_l0.png",
	"res://resources/maps/pd001_m11_l0.png",
	"res://resources/maps/pd001_m12_l0.png",
	"res://resources/maps/pd001_m12_l1.png",
	"res://resources/maps/pd001_m13_l0.png",
	"res://resources/maps/pd001_m14_l0.png",
	"res://resources/maps/pd001_m15_l0.png",
	"res://resources/maps/pd001_m16_l0.png",
	"res://resources/maps/pd001_m17_l0.png",
	"res://resources/maps/pd001_m18_l0.png",
	"res://resources/maps/pd001_m19_l0.png",
	"res://resources/maps/pd001_m20_l0.png",
	"res://resources/maps/pd001_m21_l0.png",
	"res://resources/maps/pd001_m22_l0.png",
	"res://resources/maps/pd001_m23_l0.png",
	"res://resources/maps/pd001_m24_l0.png",
	"res://resources/maps/pd001_m25_l0.png",
	"res://resources/maps/pd001_m26_l0.png",
	"res://resources/maps/pd001_m27_l0.png",
	"res://resources/maps/pd001_m28_l0.png",
	"res://resources/maps/pd001_m29_l0.png",
	"res://resources/maps/pd001_m30_l0.png",
	"res://resources/maps/pd001_m31_l0.png",
	"res://resources/maps/pd001_m32_l0.png",
	"res://resources/maps/pd001_m33_l0.png",
	"res://resources/maps/pd001_m34_l0.png",
	"res://resources/maps/pd001_m35_l0.png",
	"res://resources/maps/pd001_m36_l0.png",
	"res://resources/maps/pd001_m41_l0.png",
	"res://resources/maps/pd002_m00_l0.png",
	"res://resources/maps/pd002_m01_l0.png",
	"res://resources/maps/pd002_m02_l0.png",
	"res://resources/maps/pd002_m03_l0.png",
	"res://resources/maps/pd002_m04_l0.png",
	"res://resources/maps/pd002_m05_l0.png",
	"res://resources/maps/pd002_m05_l1.png",
	"res://resources/maps/pd002_m06_l0.png",
	"res://resources/maps/pd002_m06_l1.png",
	"res://resources/maps/pd002_m07_l0.png",
	"res://resources/maps/pd002_m07_l1.png",
	"res://resources/maps/pd002_m08_l0.png",
	"res://resources/maps/pd002_m09_l0.png",
	"res://resources/maps/pd002_m09_l1.png",
	"res://resources/maps/pd002_m10_l0.png",
	"res://resources/maps/pd003_m00_l0.png",
	"res://resources/maps/pd003_m01_l0.png",
	"res://resources/maps/pd003_m02_l0.png",
	"res://resources/maps/pd003_m03_l0.png",
	"res://resources/maps/pd003_m04_l0.png",
	"res://resources/maps/pd003_m05_l0.png",
	"res://resources/maps/pd003_m06_l0.png",
	"res://resources/maps/pd003_m07_l0.png",
	"res://resources/maps/pd003_m08_l0.png",
	"res://resources/maps/pd003_m09_l0.png",
	"res://resources/maps/pd003_m10_l0.png",
	"res://resources/maps/pd003_m11_l0.png",
	"res://resources/maps/pd003_m12_l0.png",
	"res://resources/maps/pd003_m13_l0.png",
	"res://resources/maps/pd003_m14_l0.png",
	"res://resources/maps/pd003_m15_l0.png",
	"res://resources/maps/pd003_m16_l0.png",
	"res://resources/maps/pd003_m17_l0.png",
	"res://resources/maps/pd003_m18_l0.png",
	"res://resources/maps/pd003_m19_l0.png",
	"res://resources/maps/pd003_m20_l0.png",
	"res://resources/maps/pd003_m21_l0.png",
	"res://resources/maps/pd003_m22_l0.png",
	"res://resources/maps/pd003_m23_l0.png",
	"res://resources/maps/pd003_m23_l1.png",
	"res://resources/maps/pd003_m24_l0.png",
	"res://resources/maps/pd003_m25_l0.png",
	"res://resources/maps/pd003_m26_l0.png",
	"res://resources/maps/pd003_m27_l0.png",
	"res://resources/maps/pd003_m28_l0.png",
	"res://resources/maps/pd003_m29_l0.png",
	"res://resources/maps/pd003_m30_l0.png",
	"res://resources/maps/pd003_m33_l0.png",
	"res://resources/maps/pd003_m34_l0.png",
	"res://resources/maps/pd004_m00_l0.png",
	"res://resources/maps/pd004_m01_l0.png",
	"res://resources/maps/pd004_m02_l0.png",
	"res://resources/maps/pd004_m03_l0.png",
	"res://resources/maps/pd004_m04_l0.png",
	"res://resources/maps/pd004_m04_l1.png",
	"res://resources/maps/pd004_m05_l0.png",
	"res://resources/maps/pd004_m05_l1.png",
	"res://resources/maps/pd004_m06_l0.png",
	"res://resources/maps/pd004_m07_l0.png",
	"res://resources/maps/pd004_m08_l0.png",
	"res://resources/maps/pd004_m09_l0.png",
	"res://resources/maps/pd004_m10_l0.png",
	"res://resources/maps/pd004_m11_l0.png",
	"res://resources/maps/pd005_m00_l0.png",
	"res://resources/maps/pd005_m01_l0.png",
	"res://resources/maps/pd005_m02_l0.png",
	"res://resources/maps/pd005_m03_l0.png",
	"res://resources/maps/pd005_m04_l0.png",
	"res://resources/maps/pd005_m05_l0.png",
	"res://resources/maps/pd005_m06_l0.png",
	"res://resources/maps/pd006_m00_l0.png",
	"res://resources/maps/pd006_m01_l0.png",
	"res://resources/maps/pd006_m02_l0.png",
	"res://resources/maps/pd006_m03_l0.png",
	"res://resources/maps/pd006_m04_l0.png",
	"res://resources/maps/pd006_m05_l0.png",
	"res://resources/maps/pd006_m05_l1.png",
	"res://resources/maps/pd006_m06_l0.png",
	"res://resources/maps/pd006_m06_l1.png",
	"res://resources/maps/pd006_m07_l0.png",
	"res://resources/maps/pd006_m07_l1.png",
	"res://resources/maps/pd006_m08_l0.png",
	"res://resources/maps/pd006_m09_l0.png",
	"res://resources/maps/pd007_m00_l0.png",
	"res://resources/maps/pd007_m01_l0.png",
	"res://resources/maps/pd007_m01_l1.png",
	"res://resources/maps/pd007_m02_l0.png",
	"res://resources/maps/pd007_m02_l1.png",
	"res://resources/maps/pd007_m03_l0.png",
	"res://resources/maps/pd007_m03_l1.png",
	"res://resources/maps/pd007_m04_l0.png",
	"res://resources/maps/pd007_m05_l0.png",
	"res://resources/maps/pd007_m06_l0.png",
	"res://resources/maps/pd007_m07_l0.png",
	"res://resources/maps/pd007_m08_l0.png",
	"res://resources/maps/pd007_m08_l1.png",
	"res://resources/maps/pd007_m09_l0.png",
	"res://resources/maps/pd007_m10_l0.png",
	"res://resources/maps/pd007_m11_l0.png",
	"res://resources/maps/pd007_m12_l0.png",
	"res://resources/maps/pd007_m15_l0.png",
	"res://resources/maps/pd007_m15_l1.png",
	"res://resources/maps/pd010_m00_l0.png",
	"res://resources/maps/pd010_m01_l0.png",
	"res://resources/maps/pd010_m02_l0.png",
	"res://resources/maps/pd010_m02_l1.png",
	"res://resources/maps/pd010_m04_l0.png",
	"res://resources/maps/pd010_m05_l0.png",
	"res://resources/maps/pd010_m05_l1.png",
	"res://resources/maps/pd010_m07_l0.png",
	"res://resources/maps/pd010_m07_l1.png",
	"res://resources/maps/pd010_m08_l0.png",
	"res://resources/maps/pd010_m08_l1.png",
	"res://resources/maps/pd010_m09_l0.png",
	"res://resources/maps/pd010_m10_l0.png",
	"res://resources/maps/pd010_m11_l0.png",
	"res://resources/maps/pd010_m12_l0.png",
	"res://resources/maps/pd010_m13_l0.png",
	"res://resources/maps/pd011_m00_l0.png",
	"res://resources/maps/pd011_m01_l0.png",
	"res://resources/maps/pd011_m02_l0.png",
	"res://resources/maps/pd011_m03_l0.png",
	"res://resources/maps/pd011_m04_l0.png",
	"res://resources/maps/pd011_m05_l0.png",
	"res://resources/maps/pd011_m06_l0.png",
	"res://resources/maps/pd011_m07_l0.png",
	"res://resources/maps/pd011_m08_l0.png",
	"res://resources/maps/pd011_m09_l0.png",
	"res://resources/maps/pd011_m10_l0.png",
	"res://resources/maps/pd011_m11_l0.png",
	"res://resources/maps/pd011_m12_l0.png",
	"res://resources/maps/pd011_m13_l0.png",
	"res://resources/maps/pd011_m14_l0.png",
	"res://resources/maps/pd011_m15_l0.png",
	"res://resources/maps/pd011_m16_l0.png",
	"res://resources/maps/pd011_m17_l0.png",
	"res://resources/maps/pd011_m18_l0.png",
	"res://resources/maps/pd011_m19_l0.png",
	"res://resources/maps/pd011_m20_l0.png",
	"res://resources/maps/pd011_m20_l1.png",
	"res://resources/maps/pd011_m20_l2.png",
	"res://resources/maps/pd011_m21_l0.png",
	"res://resources/maps/pd011_m21_l1.png",
	"res://resources/maps/pd011_m21_l2.png",
	"res://resources/maps/rm000_m00_l0.png",
	"res://resources/maps/rm000_m00_l1.png",
	"res://resources/maps/rm000_m01_l0.png",
	"res://resources/maps/rm000_m01_l1.png",
	"res://resources/maps/rm000_m02_l0.png",
	"res://resources/maps/rm000_m03_l0.png",
	"res://resources/maps/rm001_m00_l0.png",
	"res://resources/maps/rm001_m01_l0.png",
	"res://resources/maps/rm001_m02_l0.png",
	"res://resources/maps/rm001_m02_l1.png",
	"res://resources/maps/rm002_m00_l0.png",
	"res://resources/maps/rm002_m01_l0.png",
	"res://resources/maps/rm002_m01_l1.png",
	"res://resources/maps/rm002_m02_l0.png",
	"res://resources/maps/rm002_m02_l1.png",
	"res://resources/maps/rm002_m22_l0.png",
	"res://resources/maps/rm002_m22_l1.png",
	"res://resources/maps/rm004_m00_l0.png",
	"res://resources/maps/rm004_m01_l0.png",
	"res://resources/maps/rm004_m02_l0.png",
	"res://resources/maps/rm010_m00_l0.png",
	"res://resources/maps/rm010_m00_l1.png",
	"res://resources/maps/rm010_m00_l2.png",
	"res://resources/maps/rm010_m01_l0.png",
	"res://resources/maps/rm010_m01_l1.png",
	"res://resources/maps/rm010_m01_l2.png",
	"res://resources/maps/rm010_m02_l0.png",
	"res://resources/maps/rm010_m02_l1.png",
	"res://resources/maps/rm010_m02_l2.png",
	"res://resources/maps/rm010_m03_l0.png",
	"res://resources/maps/rm011_m00_l0.png",
	"res://resources/maps/rm011_m00_l1.png",
	"res://resources/maps/rm011_m00_l2.png",
	"res://resources/maps/rm011_m00_l3.png",
	"res://resources/maps/rm011_m00_l4.png",
	"res://resources/maps/rm011_m00_l5.png",
	"res://resources/maps/rm011_m00_l6.png",
	"res://resources/maps/rm012_m00_l0.png",
	"res://resources/maps/rm012_m00_l1.png",
	"res://resources/maps/rm101_m00_l0.png",
	"res://resources/maps/rm101_m00_l1.png",
	"res://resources/maps/rm101_m00_l2.png",
	"res://resources/maps/rm102_m00_l0.png",
	"res://resources/maps/rm102_m00_l1.png",
	"res://resources/maps/rm103_m00_l0.png",
	"res://resources/maps/rm103_m00_l1.png",
	"res://resources/maps/rm103_m00_l2.png",
	"res://resources/maps/rm103_m00_l3.png",
	"res://resources/maps/rm103_m01_l0.png",
	"res://resources/maps/rm103_m01_l1.png",
	"res://resources/maps/rm103_m01_l2.png",
	"res://resources/maps/rm104_m00_l0.png",
	"res://resources/maps/rm105_m00_l0.png",
	"res://resources/maps/rm105_m00_l1.png",
	"res://resources/maps/rm106_m00_l0.png",
	"res://resources/maps/rm106_m00_l1.png",
	"res://resources/maps/rm106_m00_l2.png",
	"res://resources/maps/rm107_m00_l0.png",
	"res://resources/maps/rm108_m00_l0.png",
	"res://resources/maps/rm108_m00_l1.png",
	"res://resources/maps/rm108_m00_l2.png",
	"res://resources/maps/rm108_m01_l0.png",
	"res://resources/maps/rm109_m00_l0.png",
	"res://resources/maps/rm110_m00_l0.png",
	"res://resources/maps/rm110_m01_l0.png",
	"res://resources/maps/rm110_m01_l1.png",
	"res://resources/maps/rm111_m00_l0.png",
	"res://resources/maps/rm111_m00_l1.png",
	"res://resources/maps/rm111_m00_l2.png",
	"res://resources/maps/rm112_m00_l0.png",
	"res://resources/maps/rm112_m00_l1.png",
	"res://resources/maps/rm112_m00_l2.png",
	"res://resources/maps/rm112_m00_l3.png",
	"res://resources/maps/rm112_m00_l4.png",
	"res://resources/maps/rm112_m00_l5.png",
	"res://resources/maps/rm113_m00_l0.png",
	"res://resources/maps/rm114_m00_l0.png",
	"res://resources/maps/rm120_m00_l0.png",
	"res://resources/maps/rm121_m00_l0.png",
	"res://resources/maps/rm121_m00_l1.png",
	"res://resources/maps/rm121_m00_l2.png",
	"res://resources/maps/rm121_m02_l0.png",
	"res://resources/maps/rm122_m00_l0.png",
	"res://resources/maps/rm130_m00_l0.png",
	"res://resources/maps/rm130_m00_l1.png",
	"res://resources/maps/rm130_m00_l2.png",
	"res://resources/maps/rm130_m01_l0.png",
	"res://resources/maps/rm130_m01_l1.png",
	"res://resources/maps/rm130_m01_l2.png",
	"res://resources/maps/rm130_m01_l3.png",
	"res://resources/maps/rm130_m02_l0.png",
	"res://resources/maps/rm130_m02_l1.png",
	"res://resources/maps/rm130_m02_l2.png",
	"res://resources/maps/rm130_m02_l3.png",
	"res://resources/maps/rm130_m10_l0.png",
	"res://resources/maps/rm130_m10_l1.png",
	"res://resources/maps/rm130_m10_l2.png",
	"res://resources/maps/rm130_m10_l3.png",
	"res://resources/maps/rm130_m10_l4.png",
	"res://resources/maps/rm131_m00_l0.png",
	"res://resources/maps/rm131_m01_l0.png",
	"res://resources/maps/rm131_m01_l1.png",
	"res://resources/maps/rm131_m01_l2.png",
	"res://resources/maps/rm131_m02_l0.png",
	"res://resources/maps/rm131_m02_l1.png",
	"res://resources/maps/rm131_m03_l0.png",
	"res://resources/maps/rm133_m00_l0.png",
	"res://resources/maps/rm133_m00_l1.png",
	"res://resources/maps/rm133_m00_l2.png",
	"res://resources/maps/rm133_m00_l3.png",
	"res://resources/maps/rm133_m00_l4.png",
	"res://resources/maps/rm133_m00_l5.png",
	"res://resources/maps/rm133_m00_l6.png",
	"res://resources/maps/rm133_m00_l7.png",
	"res://resources/maps/rm133_m00_l8.png",
	"res://resources/maps/rm133_m00_l9.png",
	"res://resources/maps/rm133_m04_l0.png",
	"res://resources/maps/rm133_m50_l0.png",
	"res://resources/maps/rm133_m50_l1.png",
	"res://resources/maps/rm133_m50_l2.png",
	"res://resources/maps/rm133_m50_l3.png",
	"res://resources/maps/rm133_m51_l0.png",
	"res://resources/maps/rm133_m52_l0.png",
	"res://resources/maps/rm134_m50_l0.png",
	"res://resources/maps/rm310_m00_l0.png",
	"res://resources/maps/rm340_m00_l0.png",
	"res://resources/maps/rm900_m00_l0.png",
	"res://resources/maps/rm900_m00_l1.png",
	"res://resources/maps/rm900_m00_l2.png",
	"res://resources/maps/rm900_m00_l3.png",
	"res://resources/maps/rm901_m00_l0.png",
	"res://resources/maps/rm901_m00_l1.png",
	"res://resources/maps/rm901_m00_l2.png",
	"res://resources/maps/rm902_m00_l0.png",
	"res://resources/maps/rm902_m00_l1.png",
	"res://resources/maps/rm902_m00_l2.png",
	"res://resources/maps/rm902_m00_l3.png",
	"res://resources/maps/rm903_m00_l0.png",
	"res://resources/maps/rm904_m00_l0.png",
	"res://resources/maps/rm910_m00_l0.png",
	"res://resources/maps/rm910_m00_l1.png",
	"res://resources/maps/rm910_m00_l2.png",
	"res://resources/maps/rm910_m00_l3.png",
	"res://resources/maps/rm911_m00_l0.png",
	"res://resources/maps/rm911_m00_l1.png",
	"res://resources/maps/rm911_m00_l2.png",
	"res://resources/maps/rm911_m00_l3.png",
	"res://resources/maps/rm912_m00_l0.png",
	"res://resources/maps/rm913_m00_l0.png",
	"res://resources/maps/sfd002_m05_l0.png",
	"res://resources/maps/sfd002_m05_l1.png",
	"res://resources/maps/sfd002_m06_l0.png",
	"res://resources/maps/sfield000_m00_l0.png",
	"res://resources/maps/sfield003_m00_l0.png",
	"res://resources/maps/sfield004_m00_l0.png",
	"res://resources/maps/sfield005_m00_l0.png",
	"res://resources/maps/sfield007_m00_l0.png"
]

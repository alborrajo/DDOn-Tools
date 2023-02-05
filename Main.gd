extends Control

const EnemySetPlacemarkScene = preload("res://UI/Marker/EnemySetPlacemark.tscn")
const MapMarkerScene = preload("res://UI/Marker/MapMarker.tscn")

onready var camera: Camera2D = $camera
onready var map_sprites: Node2D = $MapCoordinateSpace/MapSprites
onready var markers_node: Node2D = $MapCoordinateSpace/EnemySetMarkers
onready var players_node: Node2D = $MapCoordinateSpace/PlayerMarkers
	
func _ready():
	# Select Lestania by default, simulating a click on its selector
	# TODO: In a less hacky way, using a Provider. Decoupling map selection logic from the selector/ui node itself
	$ui/left/tab/Stages.select(0)
	$ui/left/tab/Stages.emit_signal("item_selected", 0)

func _on_ui_stage_selected(stage_no):
	_clear_map()
	_load_stage_map(stage_no)
	_clear_markers()
	_load_stage_markers(stage_no)
	_focus_camera_on_center()
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	print("Selected stage %s (ID: %s, Stage No. %s) with %s markers" % [tr(str("STAGE_NAME_",stage_id)), stage_id, stage_no, markers_node.get_child_count()])


func _load_stage_map(stage_no) -> void:
	var stage_no_as_int := int(stage_no)
	var field_id := DataProvider.stage_no_to_belonging_field_id(stage_no_as_int)
	if field_id == -1:
		_add_stage_maps(stage_no_as_int)
	else:
		_add_field_maps(field_id-1) # why is it off by one? maybe it needs an additional conversion?

func _add_field_maps(field_id: int) -> void:
	# Since Mergoda Ruins uses m01_l01 instead of m00_l00 like the rest
	if not _do_add_field_maps(field_id, 0, 0):
		_do_add_field_maps(field_id, 1, 1)
		
func _do_add_field_maps(field_id: int, m: int, l: int) -> bool:
	var stage_map_resource := "res://resources/maps/field00"+String(field_id)+"_m0"+String(m)+"_l"+String(l)+".png"
	var resource := _load_map_resource(stage_map_resource)
	if resource == null:
		printerr("Couldn't find a map for this field (Field ID %s)" % [field_id])
		return false
	else:
		var map_sprite := Sprite.new()
		map_sprite.texture = load(stage_map_resource)
		map_sprite.centered = false
		map_sprites.add_child(map_sprite)
		print("Loaded map ", stage_map_resource)
		return true
		
		
func _add_stage_maps(stage_no: int) -> void:
	var stage_map := DataProvider.stage_no_to_stage_map(stage_no)
	if "ParamList" in stage_map:
		var origin := Vector2(0,-512) # 512 (map tile height in px)
		for param in stage_map["ParamList"]:
			# TODO: Load all layers and have a control to switch between them
			var stage_map_resource := "res://resources/maps/"+String(param["ModelName"])+"_l0.png"
			var resource := _load_map_resource(stage_map_resource)
			if resource == null:
				printerr("Couldn't find the map ", stage_map_resource)
			else:
				var map_sprite := Sprite.new()
				map_sprite.texture = load(stage_map_resource)
				map_sprite.centered = false
				map_sprite.global_position = origin + Vector2(param["ConnectPos"]["x"], param["ConnectPos"]["z"])*0.028 # Eyeballed it, close enough
				map_sprite.global_position = origin + Vector2(param["ConnectPos"]["x"], param["ConnectPos"]["z"])*0.028 # Eyeballed it, close enough
				map_sprites.add_child(map_sprite)
				print("Loaded map ", stage_map_resource)
	else:
		printerr("Couldn't find a map for this stage (Stage No. %s)" % [stage_no])

func _load_stage_markers(stage_no):
	# Build new stage markers
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	if stage_no in DataProvider.repo["StageEctMarkers"] and DataProvider.repo["StageEctMarkers"][stage_no] != null:
		for ect_marker in DataProvider.repo["StageEctMarkers"][stage_no]["MarkerInfos"]:
			var marker : Marker = Marker.new(ect_marker, int(stage_no))
			var enemy_set_placemark: EnemySetPlacemark = EnemySetPlacemarkScene.instance()
			enemy_set_placemark.enemy_set = EnemySetProvider.get_enemy_set(stage_id, 0, marker.GroupNo, 0)
			enemy_set_placemark.rect_position = marker.get_map_position()
			markers_node.add_child(enemy_set_placemark)


func _load_map_resource(resource_path: String) -> Resource:
	var directory = Directory.new();
	if Directory.new().file_exists(resource_path):
		return load(resource_path)
	else:
		return null


func _clear_map():
	for child in map_sprites.get_children():
		map_sprites.remove_child(child)

func _clear_markers() -> void:
	# Clear previous selected stage markers
	for child in markers_node.get_children():
		markers_node.remove_child(child)


func _on_ui_player_activated(player: Player):
	for stage_index in $ui/left/tab/Stages.get_item_count():
		if $ui/left/tab/Stages.get_item_metadata(stage_index) == String(player.StageNo):
			$ui/left/tab/Stages.select(stage_index)
			$ui/left/tab/Stages.emit_signal("item_activated", stage_index)
			camera.position = player.get_map_position()
			return
		
	printerr("Couldnt focus map on %s %s (StageNo: %s)" % [player.FirstName, player.LastName, player.StageNo])


func _focus_camera_on_center() -> void:
	if map_sprites.get_child_count() > 0:
		camera.position = _get_center(map_sprites)
	elif markers_node.get_child_count() > 0:
		camera.position = _get_center(markers_node)


static func _get_center(parent: Node2D) -> Vector2:
	var min_x: int = 9223372036854775807
	var max_x: int = -9223372036854775808
	var min_y: int = 9223372036854775807
	var max_y: int = -9223372036854775808
	
	for child in parent.get_children():
		var position: Vector2 = child.get_rect().get_center()
		min_x = min(min_x, position.x)
		max_x = max(max_x, position.x)
		min_y = min(min_y, position.y)
		max_y = max(max_y, position.y)
		
	return parent.transform.xform(Rect2(min_x, min_y, max_x-min_x, max_y-min_y)).get_center()

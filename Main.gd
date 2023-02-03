extends Control

const EnemySetPlacemarkScene = preload("res://UI/Marker/EnemySetPlacemark.tscn")
const MapMarkerScene = preload("res://UI/Marker/MapMarker.tscn")

onready var camera: Camera2D = $camera
onready var map_sprites: Node2D = $MapCoordinateSpace/MapSprites
onready var markers_node: Node2D = $MapCoordinateSpace/EnemySetMarkers
onready var players_node: Node2D = $MapCoordinateSpace/PlayerMarkers
	
func _ready():
	# Load Lestania map by default
	_on_ui_stage_selected("100")

func _on_ui_stage_selected(stage_no):
	_clear_map()
	_load_stage_map(stage_no)
	_clear_markers()
	_load_stage_markers(stage_no)
	_focus_camera_on_center()
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	print("Selected stage %s (ID: %s, Stage No. %s) with %s markers" % [tr(str("STAGE_NAME_",stage_id)), stage_id, stage_no, markers_node.get_child_count()])

func _load_stage_map(stage_no):
	var stage_map := DataProvider.stage_no_to_stage_map(int(stage_no))
	if "ParamList" in stage_map:
		var origin := Vector2(0,-512) # 512 (map tile height in px)
		for param in stage_map["ParamList"]:
			# TODO: Load all layers and have a control to switch between them
			var stage_map_resource: String = "res://resources/maps/"+param["ModelName"]+"_l0.png"
			var directory = Directory.new();
			if Directory.new().file_exists(stage_map_resource):
				var map_sprite := Sprite.new()
				map_sprite.texture = load(stage_map_resource)
				map_sprite.centered = false
				map_sprite.global_position = origin + Vector2(param["ConnectPos"]["x"], param["ConnectPos"]["z"])*0.028 # Eyeballed it, close enough
				map_sprites.add_child(map_sprite)
				print("Loaded map ", stage_map_resource)
			else:
				printerr("Couldn't find the map ", stage_map_resource)
	else:
		printerr("Couldn't find a map for this stage (Stage No. %s)" % [stage_no])
			
func _load_stage_markers(stage_no):
	# Build new stage markers
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	if stage_no in DataProvider.repo["StageEctMarkers"] and DataProvider.repo["StageEctMarkers"][stage_no] != null:
		for ect_marker in DataProvider.repo["StageEctMarkers"][stage_no]["MarkerInfos"]:
			var marker : Marker = Marker.new(ect_marker, int(stage_no), "-1")
			var enemy_set_placemark: EnemySetPlacemark = EnemySetPlacemarkScene.instance()
			enemy_set_placemark.enemy_set = EnemySetProvider.get_enemy_set(stage_id, 0, marker.GroupNo, 0)
			enemy_set_placemark.rect_position = marker.get_map_position()
			markers_node.add_child(enemy_set_placemark)


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
			camera.global_position = player.get_map_position()
			return
		
	printerr("Couldnt focus map on %s %s (StageNo: %s)" % [player.FirstName, player.LastName, player.StageNo])


func _focus_camera_on_center() -> void:
	if markers_node.get_child_count() > 0:
		camera.global_position = _get_center(markers_node.get_children())
	elif map_sprites.get_child_count() > 0:
		camera.global_position = _get_center(map_sprites.get_children())


static func _get_center(nodes: Array) -> Vector2:
	var position: Vector2
	if nodes[0] is Node2D:
		position = nodes[0].global_position
	elif nodes[0] is Control:
		position = nodes[0].rect_position
	
	var min_x: int = position.x
	var max_x: int = position.x
	var min_y: int = position.y
	var max_y: int = position.y
	for obj in nodes:
		if obj is Node2D:
			position = obj.global_position
		elif obj is Control:
			position = obj.rect_position
		min_x = min(min_x, position.x)
		max_x = max(max_x, position.x)
		min_y = min(min_y, position.y)
		max_y = max(max_y, position.y)
		
	var min_bound := Vector2(min_x, min_y)
	var max_bound := Vector2(max_x, max_y)
	var direction := min_bound.direction_to(max_bound)
	return min_bound + direction/2

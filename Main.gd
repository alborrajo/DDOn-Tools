extends Control

const EnemySetPlacemarkScene = preload("res://UI/Marker/EnemySetPlacemark.tscn")
const MapMarkerScene = preload("res://UI/Marker/MapMarker.tscn")

onready var camera: Camera2D = $camera
onready var map_sprite: Sprite = $map
onready var markers_node: Node2D = $EnemySetMarkers
onready var players_node: Node2D = $PlayerMarkers
onready var coordinates_label: Label = $ui/status_view/container/coordinates

onready var field_id_to_texture := {
	"1": "res://resources/maps/field000_m00.png",
	"2": "res://resources/maps/field001_m00.png",
	"3": "res://resources/maps/field002_m01.png",
	"4": "res://resources/maps/field003_m00.png",
	"5": "res://resources/maps/field004_m00.png",
	"6": "res://resources/maps/field005_m00.png"
}
	
func _ready():
	# Load Lestania map by default
	_on_ui_map_selected(1)


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos : Vector2 = get_local_mouse_position();
		coordinates_label.text = String(mouse_pos.round())


func _on_ui_map_selected(field_id):
	# Show texture for the selected map
	var map_texture = field_id_to_texture.get(String(field_id))
	if map_texture != null:
		map_sprite.texture = load(map_texture)
	else:
		printerr("Couldn't find map texture for field ID ", field_id)
	
	_clear_markers()
	_load_field_markers(field_id)
	
	print("Selected field %s (ID: %s) with %s markers" % [tr(str("FIELD_AREA_INFO_",field_id)), field_id, markers_node.get_child_count()])

func _load_field_markers(field_id):
	# Terribly optimized
	for stage_no in DataProvider.repo["StageEctMarkers"].keys():
		var belonging_field_id = DataProvider.stage_no_to_belonging_field_id(int(stage_no))
		if field_id == belonging_field_id and stage_no in DataProvider.repo["StageEctMarkers"] and DataProvider.repo["StageEctMarkers"][stage_no] != null:
			for ect_marker in DataProvider.repo["StageEctMarkers"][stage_no]["MarkerInfos"]:
				var marker : Marker = Marker.new(ect_marker, int(stage_no), String(field_id))
				var stage_id = DataProvider.stage_no_to_stage_id(marker.StageNo)
				var enemy_set_placemark: EnemySetPlacemark = EnemySetPlacemarkScene.instance()
				enemy_set_placemark.enemy_set = EnemySetProvider.get_enemy_set(stage_id, 0, marker.GroupNo, 0)
				enemy_set_placemark.rect_position = marker.get_map_position()
				markers_node.add_child(enemy_set_placemark)


func _on_ui_stage_selected(stage_no):
	# Hide map texture
	map_sprite.texture = null
	
	_clear_markers()
	_load_stage_markers(stage_no)
	
	var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
	print("Selected stage %s (ID: %s, Stage No. %s) with %s markers" % [tr(str("STAGE_NAME_",stage_id)), stage_id, stage_no, markers_node.get_child_count()])

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


func _clear_markers() -> void:
	# Clear previous selected stage markers
	for child in markers_node.get_children():
		markers_node.remove_child(child)


func _on_ui_player_activated(player: Player):
	var field_index = $ui/status_view/container/MapOptionButton.get_item_index(int(player.field_id))
	if field_index == -1:
		# Terrible 
		for stage_index in $ui/left/tab/Stages.get_item_count():
			if $ui/left/tab/Stages.get_item_metadata(stage_index) == String(player.StageNo):
				$ui/left/tab/Stages.select(stage_index)
				$ui/left/tab/Stages.emit_signal("item_activated", stage_index)
				camera.global_position = player.get_map_position()
				return
	else:
		$ui/status_view/container/MapOptionButton.select(field_index)
		$ui/status_view/container/MapOptionButton.emit_signal("item_selected", field_index)
		camera.global_position = player.get_map_position()
		return
		
	printerr("Couldnt focus map on %s %s (StageNo: %s)" % [player.FirstName, player.LastName, player.StageNo])

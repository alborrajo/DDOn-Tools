extends Control

const EnemySetPlacemarkScene = preload("res://UI/Marker/EnemySetPlacemark.tscn")
const MapMarkerScene = preload("res://UI/Marker/MapMarker.tscn")

onready var camera: Camera2D = $camera
onready var map_sprite: Sprite = $map
onready var markers_node: Node2D = $Markers
onready var players_node: Node2D = $Players
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

func _on_rpc_timer_timeout():
	update_info()

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
	
	var item = false
	if players_on_ui.get_root():
		item = players_on_ui.get_root().get_children()
	while (item):
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if item.get_metadata(0).player.CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on ui, that have no info
			var tmp = item
			item = item.get_next()
			players_on_ui_root.remove_child(tmp)
			tmp.free()
			continue
		item = item.get_next()
			
	for info in infos:
		var player: Player
		var field_id = stage_no_to_belonging_field_id(info["StageNo"])
		if field_id == null:
			player = Player.new(info)
		else: 
			player = Player.new(info, String(field_id))
		
		# on map
		var player_marker : PlayerMarker
		for n in players_on_map.get_children():
			if n.player.CharacterId == player.CharacterId:
				player_marker = n
		if player_marker:
			# update existing player
			player_marker.set_player(player)
			player_marker._on_ui_map_selected($ui.get_selected_map())
		else:
			# create new player
			player_marker = PlayerMarkerScene.instance()
			$ui.connect("map_selected", player_marker, "_on_ui_map_selected")
			player_marker.set_player(player)
			player_marker._on_ui_map_selected($ui.get_selected_map())
			players_on_map.add_child(player_marker)
			
		# on ui
		var stage_id := DataProvider.stage_no_to_stage_id(player.StageNo)
		var text := "%s %s @ %s %s" % [player.FirstName, player.LastName, tr(str("STAGE_NAME_",stage_id)), player.get_map_position().round()]
		
		var existing_ui : TreeItem
		item = false
		if players_on_ui.get_root():
			item = players_on_ui.get_root().get_children()
		while (item):
			if item.get_metadata(0).player.CharacterId == player.CharacterId:
				existing_ui = item
			item = item.get_next()
		if existing_ui:
			# update existing player
			existing_ui.set_text(0, text)
		else:
			# create new player
			create_tree_entry(player_marker)
			

func create_tree_entry(var player_marker : PlayerMarker):
	var stage_id := DataProvider.stage_no_to_stage_id(player_marker.player.StageNo)
	var text := "%s %s @ %s %s" % [player_marker.player.FirstName, player_marker.player.LastName, tr(str("STAGE_NAME_",stage_id)), player_marker.player.get_map_position().round()]
	var item = players_on_ui.create_item(players_on_ui_root)
	item.set_text(0, text)
	item.set_metadata(0, player_marker)


func _clear_markers() -> void:
	# Clear previous selected stage markers
	for child in markers_node.get_children():
		markers_node.remove_child(child)


func _on_Players_item_activated():
	# Act only if there's a map for the area the player is in
	var selected_player_marker: PlayerMarker = players_on_ui.get_selected().get_metadata(0)
	if field_id_to_node.has(selected_player_marker.player.field_id):
		var idx = $ui/status_view/container/MapOptionButton.get_item_index(int(selected_player_marker.player.field_id))
		$ui/status_view/container/MapOptionButton.select(idx)
		$ui/status_view/container/MapOptionButton.emit_signal("item_selected", idx)
		camera.global_position = selected_player_marker.player.get_map_position()

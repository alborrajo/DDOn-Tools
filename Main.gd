extends Control

signal markers_loaded()

const EnemySetPlacemarkScene = preload("res://UI/Marker/EnemySetPlacemark.tscn")
const PlayerMarkerScene = preload("res://UI/Marker/PlayerMarker.tscn")
const MapMarkerScene = preload("res://UI/Marker/MapMarker.tscn")

var rpc_client := RpcClient.new()
onready var camera: Camera2D = $camera
onready var players_on_map: Node2D = $PlayersOnMap
onready var coordinates_label: Label = $ui/status_view/container/coordinates
onready var marker_label: Label = $ui/status_view/container/marker
onready var players_on_ui: Tree = $ui/left/tab/Players
onready var players_on_ui_root: TreeItem = players_on_ui.create_item()

onready var field_id_to_node := {
	"1": $Lestania,
	"2": $MergodaRuins,
	"3": $MergodaPalace,
	"4": $BloodbaneIsland,
	"5": $Phindym,
	"6": $AcreSelund
}

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
	
	load_npc_markers()
	emit_signal("markers_loaded")
	
	# Request RPC immediately
	_on_rpc_timer_timeout()
	
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos : Vector2 = get_local_mouse_position();
		coordinates_label.text = String(mouse_pos.round())

func _on_rpc_timer_timeout():
	update_info()

func load_npc_markers():
	# Terribly optimized
	for stage_no in DataProvider.repo["Data"]["Stages"].keys():
		var field_id = stage_no_to_belonging_field_id(int(stage_no))
		if field_id == null:
			printerr("No field found for stage_no ", stage_no)
			continue
			
		var field_node = field_id_to_node.get(String(field_id))
		if field_node == null:
			printerr("No node found for field_id ", field_id)
			continue
			
		for ect_marker in DataProvider.repo["Data"]["Stages"][stage_no]["EctMarker"]:
			var marker : Marker = Marker.new(ect_marker, String(field_id))
			var enemy_set_placemark: EnemySetPlacemark = EnemySetPlacemarkScene.instance()
			enemy_set_placemark.group_id = marker.GroupNo
			enemy_set_placemark.stage_id = DataProvider.stage_no_to_stage_id(marker.StageNo)
			enemy_set_placemark.rect_position = marker.get_map_position()
			field_node.add_child(enemy_set_placemark)
			
func stage_no_to_belonging_field_id(stage_no: int):
	for field_area_info in DataProvider.repo["FieldAreaList"]["FieldAreaInfos"]:
		if field_area_info["StageNoList"].has(float(stage_no)):
			return int(field_area_info["FieldAreaId"])
		
func update_info():
	var infos : Array = rpc_client.get_info()
	for n in players_on_map.get_children():
		# check if player is still in the server
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if n.player.CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on map, that have no info
			players_on_map.remove_child(n)
			n.queue_free()
	
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


func _on_ui_map_selected(field_id):
	# Hide all maps
	for map in field_id_to_node.values():
		map.visible = false
	
	# Show only the selected one
	var map_node = field_id_to_node.get(String(field_id))
	if map_node != null:
		map_node.visible = true
	else:
		printerr("Couldn't find node for field ID ",field_id)
		
	# Show texture for the selected map
	var map_texture = field_id_to_texture.get(String(field_id))
	if map_texture != null:
		$map.texture = load(map_texture)
	else:
		printerr("Couldn't find map texture for field ID ", field_id)


func _on_Players_item_activated():
	# Act only if there's a map for the area the player is in
	var selected_player_marker: PlayerMarker = players_on_ui.get_selected().get_metadata(0)
	if field_id_to_node.has(String(selected_player_marker.player.field_id)):
		_on_ui_map_selected(selected_player_marker.player.field_id)
		camera.global_position = selected_player_marker.player.get_map_position()

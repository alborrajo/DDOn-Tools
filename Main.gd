extends Node2D

signal markers_loaded()

const EnemySetPlacemarkScene = preload("res://UI/Marker/EnemySetPlacemark.tscn")
const PlayerMarkerScene = preload("res://UI/Marker/PlayerMarker.tscn")
const MapMarkerScene = preload("res://UI/Marker/MapMarker.tscn")

var rpc_client : RpcClient
var coordinates_label : Label
var marker_label : Label
var players_on_map : Node2D
var players_on_ui : Tree
var players_on_ui_root : TreeItem

onready var land_id_to_node := {
	"1": $Lestania,
	"2": $"Bloodbane Island",
	"3": $Phindym,
	"4": $"Acre Selund"
}
	
func _init():
	rpc_client = RpcClient.new()
	
func _ready():
	coordinates_label = get_node("ui/status_view/container/coordinates")
	players_on_ui = get_node("ui/left/tab/player")
	marker_label = get_node("ui/status_view/container/marker")
	players_on_map = Node2D.new()
	add_child(players_on_map)
	players_on_ui_root= players_on_ui.create_item();
	players_on_ui.hide_root = true
	load_npc_markers()
	emit_signal("markers_loaded")
	
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos : Vector2 = get_local_mouse_position();
		coordinates_label.text = "X:%s Y:%s" % [mouse_pos.x, mouse_pos.y]

func _on_rpc_timer_timeout():
	update_info()

func load_npc_markers():
	# Oh no
	for land_id in DataProvider.repo["Data"]["Lands"].keys():
		var land_node: Node = land_id_to_node.get(land_id)
		if land_node == null:
			printerr("No node found for land id ",land_id)
		else:
			for area_id in DataProvider.repo["Data"]["Lands"][land_id]["Areas"].keys():
				for stage_id in DataProvider.repo["Data"]["Lands"][land_id]["Areas"][area_id]["Stages"].keys():
					for ect_marker in DataProvider.repo["Data"]["Lands"][land_id]["Areas"][area_id]["Stages"][stage_id]["EctMarker"]:
						var marker : Marker = Marker.new(ect_marker, land_id)
						var enemy_set_placemark: EnemySetPlacemark = EnemySetPlacemarkScene.instance()
						enemy_set_placemark.group_id = marker.GroupNo
						enemy_set_placemark.stage_id = DataProvider.stage_no_to_stage_id(marker.StageNo)
						enemy_set_placemark.rect_position = marker.get_map_position()
						land_node.add_child(enemy_set_placemark)
		
func _on_hover_marker(var map_marker : MapMarker):
	var marker : Marker = map_marker.marker
	marker_label.text = "Marker:(Type:%s Id:%s StageNo:%s GroupNo:%s )" % [marker.Type, marker.UniqueId, marker.StageNo, marker.GroupNo]
		
func update_info():
	var infos : Array = rpc_client.get_info()
	for n in players_on_map.get_children():
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
			if item.get_metadata(0).CharacterId == CharacterId:
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
		var p : Player = Player.new(info, "1") # TODO: Obtain in which land is the Player
		
		# on map
		var existing : PlayerMarker
		for n in players_on_map.get_children():
			if n.player.CharacterId == p.CharacterId:
				existing = n
		if existing:
			# update existing player
			existing.set_player(p)
		else:
			# create new player
			var player : PlayerMarker = PlayerMarkerScene.instance()
			player.set_player(p)
			players_on_map.add_child(player)
			
		# on ui
		var text : String = "%s %s %s" % [p.FirstName, p.LastName, p.get_map_position()]
		var existing_ui : TreeItem
		item = false
		if players_on_ui.get_root():
			item = players_on_ui.get_root().get_children()
		while (item):
			if item.get_metadata(0).CharacterId == p.CharacterId:
				existing_ui = item
			item = item.get_next()
		if existing_ui:
			# update existing player
			existing_ui.set_text(0, text)
		else:
			# create new player
			create_tree_entry(p)
			

func create_tree_entry(var player : Player):
	var item = players_on_ui.create_item(players_on_ui_root)
	var text : String = "%s %s %s" % [player.FirstName, player.LastName, player.get_map_position()]
	item.set_text(0, text)
	item.set_metadata(0, player)


func _on_ui_map_selected(map_name):
	$Lestania.visible = false
	$"Bloodbane Island".visible = false
	$Phindym.visible = false
	$"Acre Selund".visible = false
	
	var map_node := get_node_or_null(map_name)
	if map_node != null:
		map_node.visible = true
	else:
		printerr("Couldn't find node for map ",map_name)

extends Node2D

const PlayerMarkerScene = preload("res://UI/Marker/PlayerMarker.tscn")

var rpc_client : RpcClient
var map_sprite : Sprite
var coordinates_label : Label
var players_on_map : Node2D
var players_on_ui : Tree
var players_on_ui_root : TreeItem
	
func _init():
	rpc_client = RpcClient.new()
	
func _ready():
	map_sprite = get_node("map")
	coordinates_label = get_node("ui/status_view/container/coordinates")
	players_on_ui = get_node("ui/left/tab/player")
	players_on_map = Node2D.new()
	map_sprite.add_child(players_on_map)
	players_on_ui_root= players_on_ui.create_item();
	players_on_ui.hide_root = true
	
func _input(event):
	if event is InputEventMouseMotion:
		var map_sprite_pos : Vector2 = map_sprite.get_local_mouse_position();
		if map_sprite.get_rect().has_point(map_sprite_pos):
			coordinates_label.text = "X:%s Y:%s" % [map_sprite_pos.x, map_sprite_pos.y]

func _on_rpc_timer_timeout():
	update_info()

func update_info():
	var remove : Array
	var add : Array
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
		var p : Player = Player.new(info)
		
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
		var text : String = "%s (X:%s Y:%s)" % [p.FirstName, p.X, p.Y]
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
	var text : String = "%s (X:%s Y:%s)" % [player.FirstName, player.X, player.Y]
	item.set_text(0, text)
	item.set_metadata(0, player)

	

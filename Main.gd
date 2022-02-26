extends Node2D

const PlayerMarkerScene = preload("res://UI/Marker/PlayerMarker.tscn")

var rpc_client : RpcClient
var map_sprite : Sprite
var coordinates_label : Label
var players_node : Node2D
	
func _init():
	rpc_client = RpcClient.new()
	
func _ready():
	map_sprite = get_node("map")
	coordinates_label = get_node("ui/status_view/container/coordinates")
	players_node = Node2D.new()
	map_sprite.add_child(players_node)
	
func _input(event):
	if event is InputEventMouseMotion:
		var map_sprite_pos : Vector2 = map_sprite.get_local_mouse_position();
		if map_sprite.get_rect().has_point(map_sprite_pos):
			coordinates_label.text = "X:%s Y:%s" % [map_sprite_pos.x, map_sprite_pos.y]

func _on_rpc_timer_timeout():
	var remove : Array
	var add : Array
	var infos : Array = rpc_client.get_info()
	
	for n in players_node.get_children():
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if n.CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on map, that have no info
			players_node.remove_child(n)
			n.queue_free()
			
	for info in infos:
		var CharacterId : int = info["CharacterId"]
		var existing : PlayerMarker
		for n in players_node.get_children():
			if n.CharacterId == CharacterId:
				existing = n
		if existing:
			# update existing player
			existing.set_player(info)
		else:
			# create new player
			var player : PlayerMarker = PlayerMarkerScene.instance()
			player.set_player(info)
			players_node.add_child(player)

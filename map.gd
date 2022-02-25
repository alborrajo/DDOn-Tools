extends Node2D

const PlayerMarker = preload("res://UI/Marker/PlayerMarker.tscn")

var rpc_client : RpcClient
var map : Sprite
var players : Node2D
	
func _init():
	rpc_client = RpcClient.new()
	
func _ready():
	map = get_node("Map")
	players = Node2D.new()
	map.add_child(players)

func _on_rpc_timer_timeout():
	var infos : Array = rpc_client.get_info()
	for n in players.get_children():
		players.remove_child(n)
		n.queue_free()
	for info in infos:
		var player : PlayerMarker = PlayerMarker.instance()
		player.set_player(info)
		players.add_child(player)

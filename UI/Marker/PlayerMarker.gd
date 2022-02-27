extends Node2D

class_name PlayerMarker

var player : Player

func set_player_json(var json : Dictionary):
	player = Player.new(json)
	set_player(player)

func set_player(var p_player : Player):
	player = p_player
	set_pos_vec(player.get_map_position())

func set_pos_vec(var vec: Vector2):
	set_pos(vec.x, vec.y)

func set_pos(var x, var z):
	position.x = x
	position.y = z

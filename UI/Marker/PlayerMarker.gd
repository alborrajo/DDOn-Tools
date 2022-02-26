extends Node2D

class_name PlayerMarker

export var xDiv = 1 
export var zDiv = 1 
export var pause : bool = false 


var player : Player

func set_player_json(var json : Dictionary):
	player = Player.new(json)
	set_pos(player.X, player.Z)

func set_player(var p_player : Player):
	player = p_player
	set_pos(player.X, player.Z)

func set_pos(var x, var z):
	if pause:
		return
	var x1 = x / xDiv
	var z1 = z / zDiv
	position.x = x1
	position.y = z1


# 0,0 center
#-190115 X LEFT-/RIGHT+
#-207145 Z UP-/DOWN+

# 0,0 TOP,LEFT
#1366 X LEFT-/RIGHT+
#1724 Y UP-/DOWN+

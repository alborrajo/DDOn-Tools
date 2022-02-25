extends Node2D

class_name PlayerMarker

var X : int
var Y : int
var Z : int
var FirstName : String
var LastName : String



func set_player(var player):
	X = player["X"]
	Y = player["Y"]
	Z = player["Z"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]
	set_pos(X, Z)

func set_pos(var x, var z):
	#var x1 = x / 200
	#var z1 = z / 190
	
	position.x = x
	position.y = z


# 0,0 center
#-190115 X LEFT-/RIGHT+
#-207145 Z UP-/DOWN+

# 0,0 TOP,LEFT
#1366 X LEFT-/RIGHT+
#1724 Y UP-/DOWN+

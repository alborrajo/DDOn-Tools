extends Node2D

class_name PlayerMarker

export var xDiv = 1 
export var zDiv = 1 
export var pause : bool = false 

var X : int
var Y : int
var Z : int
var CharacterId : int
var FirstName : String
var LastName : String

func set_player(var player):
	X = player["X"]
	Y = player["Y"]
	Z = player["Z"]
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]
	set_pos(X, Z)

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

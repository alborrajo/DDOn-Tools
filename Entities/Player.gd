extends Resource
class_name Player

var X : int
var Y : int
var Z : int
var CharacterId : int
var FirstName : String
var LastName : String

func _init(var player : Dictionary):
	X = player["X"]
	Y = player["Y"]
	Z = player["Z"]
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]

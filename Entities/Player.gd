extends Resource
class_name Player

const MAP_POSITION_SCALE = 215.0/238162.0
const MAP_POSITION_OFFSET = Vector2(298.0+9906*MAP_POSITION_SCALE, 45+348034*MAP_POSITION_SCALE)

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
	print_debug("[%d] %s %s @ (X: %d, Y: %d, Z: %d)" % [CharacterId, FirstName, LastName, X, Y, Z])

func get_map_position() -> Vector2:
	return Vector2(X, Z) * MAP_POSITION_SCALE + MAP_POSITION_OFFSET

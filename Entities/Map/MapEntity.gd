extends Resource

class_name MapEntity

const MAP_POSITION_SCALE = 215.0/238162.0
const MAP_POSITION_OFFSET = Vector2(298.0+9906*MAP_POSITION_SCALE, 45+348034*MAP_POSITION_SCALE)

var X : int
var Y : int
var Z : int

func _init(var entity : Dictionary):
	X = entity["X"]
	Y = entity["Y"]
	Z = entity["Z"]

func get_map_position() -> Vector2:
	return Vector2(X, Z) * MAP_POSITION_SCALE + MAP_POSITION_OFFSET

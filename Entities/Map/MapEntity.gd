extends Resource
class_name MapEntity

const DEFAULT_TRANSFORM := Transform2D(Vector2(215.0/238162.0, 0), Vector2(0, 215.0/238162.0), Vector2(298.0+9906*215.0/238162.0, 45+348034*215.0/238162.0))

var pos: Vector3
var transform: Transform2D

func _init(var p_pos: Vector3, var p_transform: Transform2D = DEFAULT_TRANSFORM):
	self.pos = p_pos
	self.transform = p_transform

func get_map_position() -> Vector2:
	return self.transform.xform(Vector2(self.pos.x, self.pos.z))

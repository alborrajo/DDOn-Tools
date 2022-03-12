extends Resource
class_name MapEntity

var field_transforms := {
	"1": Transform2D(Vector2(215.0/238162.0, 0), Vector2(0, 215.0/238162.0), Vector2(298.0+9906*215.0/238162.0, 45+348034*215.0/238162.0)),
	"3": Transform2D(Vector2(70.0/77601.0, 0), Vector2(0, 50.0/55621.0), Vector2(227.0+42361.0*70.0/77601.0, 338.0+13829.0*50.0/55621.0))
}

var pos: Vector3
var field_id: String

func _init(var pos: Vector3, var field_id: String):
	self.pos = pos
	self.field_id = field_id

func get_map_position() -> Vector2:
	return field_transforms.get(self.field_id, Transform2D.IDENTITY).xform(Vector2(pos.x, pos.z))

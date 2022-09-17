extends Resource
class_name MapEntity

const DEFAULT_TRANSFORM := Transform2D(Vector2(215.0/238162.0, 0), Vector2(0, 215.0/238162.0), Vector2(298.0+9906*215.0/238162.0, 45+348034*215.0/238162.0))

var field_transforms := {
	"1": Transform2D(Vector2(215.0/238162.0, 0), Vector2(0, 215.0/238162.0), Vector2(298.0+9906*215.0/238162.0, 45+348034*215.0/238162.0)), # Lestania
	"2": Transform2D(Vector2(57.0/20086.0, 0), Vector2(0, 161.0/56877.0), Vector2(37.0+280440.0/20086.0, 49.0+8817165.0/56877.0)), # Mergoda Lower
	"3": Transform2D(Vector2(36.0/15014.0, 0), Vector2(0, 21.0/7296.0), Vector2(106.0+511812.0/15014.0, 94.0+437178.0/7296.0)), # Mergoda Palace
	"4": Transform2D(Vector2(23.0/25952.0, 0), Vector2(0, 31.0/35000.0), Vector2(52.0-82869.0/25952.0, 110.0-247535.0/35000.0)), # Bloodbane
	"5": Transform2D(Vector2(70.0/77601.0, 0), Vector2(0, 50.0/55621.0), Vector2(227.0+42361.0*70.0/77601.0, 338.0+13829.0*50.0/55621.0)), # Phindym
	"6": Transform2D(Vector2(36.0/40756.0, 0), Vector2(0, 290.0/323633.0), Vector2(352.0+254916.0/40756.0, 822.0+15585760.0/323633.0)), # Acre Selund
	# TODO: Acre Selund (Past)
	# TODO: Bitterblack Maze
}

var pos: Vector3
var field_id: String

func _init(var pos: Vector3, var field_id: String = "0"):
	self.pos = pos
	self.field_id = field_id

func get_map_position() -> Vector2:
	return field_transforms.get(self.field_id, DEFAULT_TRANSFORM).xform(Vector2(pos.x, pos.z))

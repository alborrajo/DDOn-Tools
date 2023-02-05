extends MapEntity
class_name Marker

const STAGE_TRANSFORM := Transform2D(Vector2(62.0/22181.0, 0), Vector2(0, 56.0/19420.0), Vector2(28 + 505052.0/22181.0, -32 + 651448.0/19420.0))
const FIELD_TRANSFORMS := {
	1: Transform2D(Vector2(215.0/238162.0, 0), Vector2(0, 215.0/238162.0), Vector2(298.0+9906*215.0/238162.0, 45+348034*215.0/238162.0)), # Lestania
	2: Transform2D(Vector2(57.0/20086.0, 0), Vector2(0, 161.0/56877.0), Vector2(37.0+280440.0/20086.0, 49.0+8817165.0/56877.0)), # Mergoda Lower
	3: Transform2D(Vector2(36.0/15014.0, 0), Vector2(0, 21.0/7296.0), Vector2(106.0+511812.0/15014.0, 94.0+437178.0/7296.0)), # Mergoda Palace
	4: Transform2D(Vector2(23.0/25952.0, 0), Vector2(0, 31.0/35000.0), Vector2(52.0-82869.0/25952.0, 110.0-247535.0/35000.0)), # Bloodbane
	5: Transform2D(Vector2(70.0/77601.0, 0), Vector2(0, 50.0/55621.0), Vector2(227.0+42361.0*70.0/77601.0, 338.0+13829.0*50.0/55621.0)), # Phindym
	6: Transform2D(Vector2(36.0/40756.0, 0), Vector2(0, 290.0/323633.0), Vector2(352.0+254916.0/40756.0, 822.0+15585760.0/323633.0)), # Acre Selund
	# TODO: Acre Selund (Past)
	# TODO: Bitterblack Maze
}

var UniqueId : int
var GroupNo : int
var StageNo : int setget _set_stage_no

func _init(marker : Dictionary, stage_no: int).(Vector3(marker["Pos"]["X"],marker["Pos"]["Y"],marker["Pos"]["Z"]), _get_transform_for_stage_no(stage_no)):
	UniqueId = marker["UniqueId"]
	GroupNo = marker["GroupNo"]
	StageNo = stage_no

func _set_stage_no(p_stage_no: int):
	StageNo = p_stage_no
	transform = _get_transform_for_stage_no(p_stage_no)

static func _get_transform_for_stage_no(stage_no: int) -> Transform2D:
	 return FIELD_TRANSFORMS.get(DataProvider.stage_no_to_belonging_field_id(stage_no), STAGE_TRANSFORM)

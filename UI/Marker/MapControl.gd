extends Control
class_name MapControl

const STAGE_MAP_SCALE := 0.002806
const FIELD_MAP_SCALE := 0.0008862

const STAGE_TRANSFORM := Transform2D(Vector2(STAGE_MAP_SCALE, 0), Vector2(0, STAGE_MAP_SCALE), Vector2(51.2, 0))
const FIELD_TRANSFORMS := {
	1: Transform2D(Vector2(0.00089847958, 0), Vector2(0, 0.00089847958), Vector2(306.9730202877747, 358.4207094086002)), # Lestania
	2: Transform2D(Vector2(STAGE_MAP_SCALE, 0), Vector2(0, STAGE_MAP_SCALE), Vector2(51.2, 204.8)), # Mergoda Lower
	3: Transform2D(Vector2(STAGE_MAP_SCALE, 0), Vector2(0, STAGE_MAP_SCALE), Vector2(153.6, 153.6)), # Mergoda Palace
	4: Transform2D(Vector2(FIELD_MAP_SCALE, 0), Vector2(0, FIELD_MAP_SCALE), Vector2(49.2, 103.7)), # Bloodbane
	5: Transform2D(Vector2(FIELD_MAP_SCALE, 0), Vector2(0, FIELD_MAP_SCALE), Vector2(265.5, 351.3)), # Phindym
	6: Transform2D(Vector2(FIELD_MAP_SCALE, 0), Vector2(0, FIELD_MAP_SCALE), Vector2(358.4, 870.4)), # Acre Selund
	# TODO: Acre Selund (Past)
	# TODO: Bitterblack Maze
}

const MAP_SCALE = 100


@onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
@onready var _original_scale: Vector2 = scale

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	var zoom: float = max(camera_zoom, _original_zoom)
	scale = MAP_SCALE * _original_scale / (zoom / _original_zoom)
	
func set_ddon_world_position(stage_no: int, pos: Vector3):
	position = get_control_position(stage_no, pos)

static func get_control_position(stage_no: int, pos: Vector3) -> Vector2:
	return get_map_position(stage_no, pos)*MAP_SCALE

static func get_map_position(stage_no: int, pos: Vector3) -> Vector2:
	return _get_transform_for_stage_no(stage_no) * (Vector2(pos.x, pos.z))

static func _get_transform_for_stage_no(stage_no: int) -> Transform2D:
	return FIELD_TRANSFORMS.get(DataProvider.stage_no_to_belonging_field_id(stage_no), STAGE_TRANSFORM)

extends Node2D
class_name GenericMarker

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
onready var _original_scale := scale/_original_zoom

func set_pos_vec(var vec: Vector2):
	position = vec * Main.MAP_SCALE

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	scale = _original_scale * clamp(camera_zoom, 0, _original_zoom) * Main.MAP_SCALE

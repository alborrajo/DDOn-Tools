extends PanelContainer
class_name GenericSetPlacemark

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
onready var _original_scale := rect_scale

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	rect_scale = _original_scale * clamp(camera_zoom, 0, _original_zoom)

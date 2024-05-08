extends PanelContainer
class_name GenericSetPlacemark

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
onready var _original_scale := rect_scale
onready var selected_indices = []

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	rect_scale = _original_scale * clamp(camera_zoom, 0, _original_zoom)

func _ready():
	SelectedListManager.connect("selection_cleared", self, "_cleared_delete_list")

func _cleared_delete_list():
	selected_indices.clear()
	
func _on_placemark_selected(index):
	selected_indices.append(index)
	
func _on_placemark_deselected(index):
	selected_indices.erase(index)

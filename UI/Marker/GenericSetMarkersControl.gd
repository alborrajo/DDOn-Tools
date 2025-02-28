extends Control
class_name GenericSetMarkersControl

var dragging := false
var drag_start_global_position: Vector2

func _input(event):
	if visible:
		if event is InputEventMouseButton:
			var iemb := event as InputEventMouseButton
			if iemb.button_index == BUTTON_LEFT:
				if iemb.control and iemb.pressed:
					dragging = true
					drag_start_global_position = get_global_mouse_position()
					get_tree().set_input_as_handled()
				elif dragging:
					dragging = false
					_select_recursively(_get_selection_rect().abs(), self)
					update()
					get_tree().set_input_as_handled()
		elif dragging and event is InputEventMouseMotion:
			update()
			get_tree().set_input_as_handled()

func _draw():
	if dragging:
		var rect := _get_selection_rect()
		draw_rect(rect, Color(0.27451, 0.509804,0.705882, 0.25), true)
		VisualServer.canvas_item_set_custom_rect(get_canvas_item(), true, rect)
	else:
		VisualServer.canvas_item_set_custom_rect(get_canvas_item(), false)
		
func _select_recursively(selection_rect: Rect2, node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			var control := child as Control
			var control_rect := control.get_global_rect()
			if selection_rect.intersects(control_rect):
				pass # TODO: Call select method or something
		_select_recursively(selection_rect, child)

func _get_selection_rect() -> Rect2:
	var drag_end_global_position := get_global_mouse_position()
	var rect_size := drag_end_global_position - drag_start_global_position
	return Rect2(drag_start_global_position, rect_size)

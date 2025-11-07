extends Node2D
class_name MapCoordinateSpace

var dragging := false
var drag_start_global_position: Vector2

func _input(event):
	if visible:
		if event is InputEventMouseMotion:
			var iemm := event as InputEventMouseMotion
			# Godot 4 migration
			# if iemm.control and iemm.button_mask == MOUSE_BUTTON_LEFT:
			if Input.is_key_pressed(KEY_CTRL) and iemm.button_mask == MOUSE_BUTTON_LEFT:
				if not dragging:
					dragging = true
					drag_start_global_position = get_global_mouse_position()
				# Godot 4 migration
				# update() was renamed to queue_redraw()
				# update()
				queue_redraw()
				get_viewport().set_input_as_handled()
			elif dragging:
				dragging = false
				# Godot 4 migration
				# if not iemm.shift:
				if not Input.is_key_pressed(KEY_SHIFT):	
					SelectedListManager.clear_list()
				var selection_entities := []
				for child in get_children():
					if child.visible:
						# Select recursively only on the visible marker nodes
						var child_selection_entities := _select_recursively(_get_selection_rect().abs(), child)
						for child_selection_entity in child_selection_entities:
							selection_entities.append(child_selection_entity)
				SelectedListManager.add_multiple_to_selection(selection_entities)
				# Godot 4 migration
				# update() was renamed to queue_redraw()
				# update()
				queue_redraw()
				get_viewport().set_input_as_handled()

func _draw():
	if dragging:
		var rect := _get_selection_rect()
		draw_rect(rect, Color(0.27451, 0.509804,0.705882, 0.25), true)
		RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, rect)
	else:
		RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), false)
		
func _select_recursively(selection_rect: Rect2, node: Node) -> Array:
	var selection_entities := []
	for child in node.get_children():
		if child is Control:
			var control := child as Control
			if selection_rect.intersects(control.get_global_rect()) and control.has_method("get_selection_entity"):
				var selection_entity = control.get_selection_entity()
				assert(selection_entity != null)
				selection_entities.append(selection_entity)

		var child_selection_entities := _select_recursively(selection_rect, child)
		for entity in child_selection_entities:
			selection_entities.append(entity)
	return selection_entities

func _get_selection_rect() -> Rect2:
	var drag_end_global_position := get_global_mouse_position()
	var size := drag_end_global_position - drag_start_global_position
	return Rect2(drag_start_global_position, size)

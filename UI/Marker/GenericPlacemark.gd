extends Button
class_name GenericPlacemark

signal placemark_removed()

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		emit_signal("placemark_removed")
		SelectedListManager._clear_list()
		queue_free()

func selection_function(type):
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager._toggle_selection(self, type)  # Pass EnemyPlacemark instance and enemy data
	else:
		SelectedListManager._clear_list()
		SelectedListManager._toggle_selection(self, type)

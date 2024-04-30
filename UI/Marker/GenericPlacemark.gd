extends Button
class_name GenericPlacemark

signal placemark_removed()

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		emit_signal("placemark_removed")
		SelectedListManager._clear_list()
		queue_free()

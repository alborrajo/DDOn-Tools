extends Button
class_name GenericPlacemark

signal placemark_removed()

func ready():
	SelectedListManager.connect("selection_changed", self, "_on_selection_changed")

func _on_selection_changed():
	var is_self_selected := false
	for entry in SelectedListManager.selected_list:
		if self == entry["placemark"]:
			is_self_selected = true
	$SelectionPanel.visible = is_self_selected

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		SelectedListManager.delete_selected()
		delete_self()

func _selection_function(type):
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager.toggle_selection(self, type)  # Pass EnemyPlacemark instance and enemy data
	else:
		SelectedListManager.clear_list()
		SelectedListManager.toggle_selection(self, type)
		emit_signal("placemark_selected")

func delete_self():
	emit_signal("placemark_removed")
	queue_free()

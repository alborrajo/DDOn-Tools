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
		SelectedListManager.add_to_selection(self, null)
		SelectedListManager.delete_selected()

func _selection_function(type):
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager.toggle_selection(self, type)  # Pass Enemy or Gathering Placemark instance and its data
	else:
		SelectedListManager.clear_list()
		SelectedListManager.toggle_selection(self, type)

func delete_self():
	emit_signal("placemark_removed")
	queue_free()

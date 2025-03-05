extends Button
class_name GenericPlacemark

signal placemark_removed()

var _is_dragging := false

func ready():
	assert(SelectedListManager.connect("selection_changed", self, "_on_selection_changed") == OK)

func _on_selection_changed(added, removed):
	for entry in added:
		if self == entry["placemark"]:
			$SelectionPanel.visible = true
			return
	for entry in removed:
		if self == entry["placemark"]:
			$SelectionPanel.visible = false
			return

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
		
func select_placemark():
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _is_dragging:
		_is_dragging = false
		if get_viewport().gui_is_drag_successful():
			delete_self()

func get_drag_data(_position):
	_is_dragging = true
	return null

func delete_self():
	emit_signal("placemark_removed")
	queue_free()

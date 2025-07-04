extends Button
class_name GenericPlacemark

signal placemark_removed()

var _is_dragging := false

func ready():
	assert(SelectedListManager.connect("selection_changed", self, "_on_selection_changed") == OK)
	assert(SelectedListManager.connect("selection_deleted", self, "_on_selection_deleted") == OK)

func _on_selection_changed(added: Array, removed: Array):
	if added.has(get_selection_entity()):
		$SelectionPanel.visible = true
		return
	if removed.has(get_selection_entity()):
		$SelectionPanel.visible = false
		return
		
func _on_selection_deleted(deleted: Array):
	if deleted.has(get_selection_entity()):
		emit_signal("placemark_removed")

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		select_placemark()
		SelectedListManager.delete_selected()

func _selection_function():
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager.toggle_selection(get_selection_entity())
	else:
		SelectedListManager.clear_list()
		SelectedListManager.toggle_selection(get_selection_entity())

func select_placemark():
	SelectedListManager.add_to_selection(get_selection_entity())
	
func deselect_placemark():
	SelectedListManager.remove_from_selection(get_selection_entity())

func get_selection_entity():
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _is_dragging:
		_is_dragging = false
		if get_viewport().gui_is_drag_successful():
			emit_signal("placemark_removed")

func get_drag_data(_position):
	_is_dragging = true
	return null

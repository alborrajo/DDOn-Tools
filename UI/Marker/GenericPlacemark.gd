extends Button
class_name GenericPlacemark

signal placemark_removed()
signal placemark_selected
signal placemark_deselected
var selectionpanel = null
var fake_data = 1

func ready():
	SelectedListManager.connect("selection_cleared", self, "_clear_all")
	selectionpanel = get_node("SelectionPanel")

func _clear_all():
	selectionpanel.visible = false

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		if selectionpanel.visible == false:
			emit_signal("placemark_selected")
			SelectedListManager.unselected_removal(self, fake_data) # Allows the deletion of nodes that aren't selected.
			SelectedListManager.delete_selected()
		else:
			SelectedListManager.delete_selected()

func _selection_function(type):
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager.toggle_selection(self, type)  # Pass EnemyPlacemark instance and enemy data
		if selectionpanel:
			selectionpanel.visible = !selectionpanel.visible
			if selectionpanel.visible:
				emit_signal("placemark_selected")
			else:
				emit_signal("placemark_deselected")
	else:
		SelectedListManager.clear_list()
		SelectedListManager.toggle_selection(self, type)
		selectionpanel.visible = true
		emit_signal("placemark_selected")

func delete_self():
	emit_signal("placemark_removed")
	queue_free()

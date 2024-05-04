extends Button
class_name GenericPlacemark

signal placemark_removed()
var selectionpanel = null

func ready():
	SelectedListManager.connect("selection_cleared", self, "_clear_all")
	selectionpanel = get_node("SelectionPanel")

func _clear_all():
	selectionpanel.visible = false

# TODO, Figure out how to add support for the old behaviour of right clicking to delete without needing something selected.
# TODO, Fix crash when you continue to shift-select after deleting nodes

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		SelectedListManager.delete_selected()
			
func receive_selection_panel(selectionpanel):
	self.selectionpanel = selectionpanel
	

func selection_function(type):
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager._toggle_selection(self, type)  # Pass EnemyPlacemark instance and enemy data
		if selectionpanel:
			selectionpanel.visible = !selectionpanel.visible
	else:
		SelectedListManager._clear_list()
		SelectedListManager._toggle_selection(self, type)
		selectionpanel.visible = true

func delete_self():
	emit_signal("placemark_removed")
	queue_free()

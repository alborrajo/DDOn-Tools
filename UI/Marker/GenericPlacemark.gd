extends Button
class_name GenericPlacemark

signal placemark_removed()
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
			SelectedListManager._unselected_removal(self, fake_data) # Allows the deletion of nodes that aren't selected.
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
	print("WE'VE BEEN CALLED, COUTN ME!!!")

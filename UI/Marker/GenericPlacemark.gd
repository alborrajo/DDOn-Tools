extends Button
class_name GenericPlacemark

signal placemark_removed()
var selectionpanel = null

func ready():
	SelectedListManager.connect("selection_cleared", self, "_clear_all")
	selectionpanel = get_node("SelectionPanel")

func _clear_all():
	remove_highlight(selectionpanel)

func _gui_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
		emit_signal("placemark_removed")
		SelectedListManager._clear_list()
		queue_free()

func receive_selection_panel(selectionpanel):
	self.selectionpanel = selectionpanel
	

func selection_function(type):
	if Input.is_key_pressed(KEY_SHIFT):
		SelectedListManager._toggle_selection(self, type)  # Pass EnemyPlacemark instance and enemy data
		if selectionpanel.visible:
			remove_highlight(selectionpanel)
		else:
			add_highlight(selectionpanel)
	else:
		SelectedListManager._clear_list()
		SelectedListManager._toggle_selection(self, type)
		add_highlight(selectionpanel)

func remove_highlight(selectionpanel):
	if selectionpanel:
		selectionpanel.visible = false

func add_highlight(selectionpanel):
	if selectionpanel:
		selectionpanel.visible = true

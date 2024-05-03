extends Button
class_name GenericPlacemark

signal placemark_removed()
var selectionpanel = null

func ready():
	connect("selection_panel", self, "receive_selection_panel")
	
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

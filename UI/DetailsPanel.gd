extends Panel
class_name DetailsPanel

signal showing_details_of(obj)
	
func _ready():
	assert(SelectedListManager.connect("selection_changed", self, "_on_selection_changed") == OK)
	
func hide_details():
	for child in self.get_children():
		child.visible = false
	
func show_details_of(obj):
	hide_details()
	if obj == null:
		push_error("Attempted to show the details of a null object")
	elif obj is Enemy:
		$EnemyDetailsPanel.enemy = obj
		$EnemyDetailsPanel.visible = true
		emit_signal("showing_details_of", obj)
	elif obj is GatheringItem:
		$ItemDetailsPanel.item = obj
		$ItemDetailsPanel.visible = true
		emit_signal("showing_details_of", obj)
	else:
		push_error("Attempted to show the details of an unrecognized object")

func _on_selection_changed(_added, _removed):
	if SelectedListManager.selected_list.size() == 0:
		hide_details()
	else:
		show_details_of(SelectedListManager.selected_list.back()["data"])

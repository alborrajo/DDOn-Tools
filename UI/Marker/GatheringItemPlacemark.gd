extends GenericPlacemark
class_name GatheringItemPlacemark

export (Resource) var item: Resource setget set_item
	
onready var _detailsPanel: DetailsPanel = DetailsPanel.get_instance(get_tree())
var list_manager = SelectedListManager

func _on_GatheringItemPlacemark_pressed():
	if Input.is_key_pressed(KEY_SHIFT):
		list_manager._toggle_selection(self, item)
	else:
		SelectedListManager._clear_list()
		list_manager._toggle_selection(self, item)

func set_item(i: GatheringItem) -> void:
	if item != null and item.is_connected("changed", self, "_on_item_changed"):
		item.disconnect("changed", self, "_on_item_changed")
		
	item = i
	
	if i != null:
		i.connect("changed", self, "_on_item_changed")
		_on_item_changed()
	
func _on_item_changed():
	text = item.get_display_name()

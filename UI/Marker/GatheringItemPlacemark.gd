extends GenericPlacemark
class_name GatheringItemPlacemark

export (Resource) var item: Resource setget set_item

func _ready():
	.ready()
	assert(SetProvider.connect("selected_day_night", self, "_on_day_night_selected") == OK)

func _on_GatheringItemPlacemark_pressed():
	_selection_function(item)
	
func select_placemark():
	SelectedListManager.add_to_selection(self, item)

func set_item(i: GatheringItem) -> void:
	if item != null and item.is_connected("changed", self, "_on_item_changed"):
		item.disconnect("changed", self, "_on_item_changed")
		
	item = i
	
	if i != null:
		assert(i.connect("changed", self, "_on_item_changed") == OK)
		_on_item_changed()
	
func _on_item_changed():
	text = String(item.num)
	icon = load(item.item.icon_path)

func get_drag_data(position):
	.get_drag_data(position)
	return item as GatheringItem

extends GenericPlacemark
class_name GatheringItemPlacemark

export (Resource) var item: Resource setget set_item

func _ready():
	.ready()
	SetProvider.connect("selected_day_night", self, "_on_day_night_selected")

func _on_GatheringItemPlacemark_pressed():
	_selection_function(item)

func set_item(i: GatheringItem) -> void:
	if item != null and item.is_connected("changed", self, "_on_item_changed"):
		item.disconnect("changed", self, "_on_item_changed")
		
	item = i
	
	if i != null:
		i.connect("changed", self, "_on_item_changed")
		_on_item_changed()
	
func _on_item_changed():
	text = item.get_display_name()

extends GenericPlacemark
class_name GatheringItemPlacemark

export (Resource) var item: Resource setget set_item

func _ready():
	.ready()
	assert(SelectedListManager.connect("item_filter_changed", self, "_on_item_filter_changed") == OK)
	assert(SetProvider.connect("selected_day_night", self, "_on_day_night_selected") == OK)

func _on_GatheringItemPlacemark_pressed():
	_selection_function()
	
func _get_selection_entity():
	return item

func set_item(i: GatheringItem) -> void:
	if item != null and item.is_connected("changed", self, "_on_item_changed"):
		item.disconnect("changed", self, "_on_item_changed")
		
	item = i
	
	if i != null:
		assert(i.connect("changed", self, "_on_item_changed") == OK)
		_on_item_changed()
	
func _on_item_changed():
	text = String(item.num)
	icon = item.item.icon

func get_drag_data(position):
	.get_drag_data(position)
	return item as GatheringItem


func _on_item_filter_changed(uppercase_filter_text: String):
	if item.item.matches_filter_text(uppercase_filter_text):
		modulate = SelectedListManager.FILTER_MATCH_COLOR
		return
	modulate = SelectedListManager.FILTER_NONMATCH_COLOR

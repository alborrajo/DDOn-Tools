extends GenericPlacemark
class_name GatheringItemPlacemark

var gathering_item: GatheringItem setget _set_gathering_item

func _ready():
	.ready()
	assert(SelectedListManager.connect("item_filter_changed", self, "_on_item_filter_changed") == OK)
	assert(SetProvider.connect("selected_day_night", self, "_on_day_night_selected") == OK)

func _on_GatheringItemPlacemark_pressed():
	_selection_function()
	
func get_selection_entity():
	return gathering_item

func _set_gathering_item(i: GatheringItem) -> void:
	if gathering_item != null and gathering_item.is_connected("changed", self, "_on_item_changed"):
		gathering_item.disconnect("changed", self, "_on_item_changed")
		
	gathering_item = i
	
	if i != null:
		assert(i.connect("changed", self, "_on_item_changed") == OK)
		_on_item_changed()
	
func _on_item_changed():
	text = String(gathering_item.num)
	icon = gathering_item.item.icon

func get_drag_data(position):
	.get_drag_data(position)
	return gathering_item


func _on_item_filter_changed(uppercase_filter_text: String):
	if gathering_item.item.matches_filter_text(uppercase_filter_text):
		modulate = SelectedListManager.FILTER_MATCH_COLOR
		return
	modulate = SelectedListManager.FILTER_NONMATCH_COLOR

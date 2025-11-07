extends GenericPlacemark
class_name GatheringItemPlacemark

var gathering_item: GatheringItem: set = _set_gathering_item

func _ready():
	super.ready()
	assert(SelectedListManager.connect("item_filter_changed", Callable(self, "_on_item_filter_changed")) == OK)
	assert(SetProvider.connect("s_selected_day_night", Callable(self, "_on_day_night_selected")) == OK)

func _on_GatheringItemPlacemark_pressed():
	_selection_function()
	
func get_selection_entity():
	return gathering_item

func _set_gathering_item(i: GatheringItem) -> void:
	if gathering_item != null and gathering_item.is_connected("changed", Callable(self, "_on_item_changed")):
		gathering_item.disconnect("changed", Callable(self, "_on_item_changed"))
		
	gathering_item = i
	
	if i != null:
		assert(i.connect("changed", Callable(self, "_on_item_changed")) == OK)
		_on_item_changed()
	
func _on_item_changed():
	# Godot 4 migration
	# String constructor String(int) removed. Suggested replacement: global method str()
	# text = String(gathering_item.num)
	text = str(gathering_item.num)
	icon = gathering_item.item.icon

# Godot 4 migration
# "position" is shadowing an already-declared property in the base class
# func _get_drag_data(position):
func _get_drag_data(at_position):
	super._get_drag_data(at_position)
	return gathering_item


func _on_item_filter_changed(uppercase_filter_text: String):
	if gathering_item.item.matches_filter_text(uppercase_filter_text):
		modulate = SelectedListManager.FILTER_MATCH_COLOR
		return
	modulate = SelectedListManager.FILTER_NONMATCH_COLOR

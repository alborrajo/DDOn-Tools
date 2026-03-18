extends Tree
class_name ItemTree

var _rebuild_list_thread = null

func _ready():
	var root := create_item()
	_rebuild_list_thread = Thread.new()
	assert(_rebuild_list_thread.start(Callable(self, "_do_rebuild_list").bind([root])) == OK)
	
func _on_FilterLineEdit_text_changed(filter_text: String):
	var normalized_filter_text := filter_text.to_upper()
	for item_element in get_root().get_children():
		var item: Item = item_element.get_metadata(0)
		var matches := normalized_filter_text.length() == 0 or item.matches_filter_text(normalized_filter_text)
		item_element.visible = matches
	SelectedListManager.set_item_filter(filter_text)

func _do_rebuild_list(args: Array) -> void:
	var root: Object = args[0]
	var deferred_calls = []
	
	# Load everything first
	for item in DataProvider.item_list:
		var text := "%s\n%s [%d]" % [item.name, "★".repeat(item.quality_stars), item.id]
		deferred_calls.append(["_add_item_to_tree_node", root, text, item])
			
	# Defer calls that modify the scene tree since they're not thread safe
	for deferred_call in deferred_calls:
		call_deferred(deferred_call[0], deferred_call[1], deferred_call[2], deferred_call[3])

func _add_item_to_tree_node(parent: Object, text: String, metadata: Object) -> void:
	var item_item := create_item(parent)
	item_item.custom_minimum_height = 48
	item_item.set_text(0, text)
	item_item.set_metadata(0, metadata)
	item_item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	
	item_item.set_custom_draw_callback(0, Callable(self, "_draw_tree_item"))
	
func _draw_tree_item(tree_item: TreeItem, rect: Rect2):
	var item: Item = tree_item.get_metadata(0)
	var icon_position := Vector2(rect.position.x + (24 - float(item.icon.get_width())/2), rect.position.y + (float(rect.size.y)/2 - float(item.icon.get_height())/2))
	draw_texture(item.icon, icon_position)
	draw_string(get_theme_font("font"), rect.position + Vector2(48, rect.size.y/2), item.name)
	draw_string(get_theme_font("font"), rect.position + Vector2(48, rect.size.y/2 + 16), "%s[%d]" % ["★".repeat(item.quality_stars), item.id])

func _get_drag_data(at_position):
	var selected_items = []
	var selected_tree_item = get_next_selected(null)
	while selected_tree_item != null:
		var selected_item = selected_tree_item.get_metadata(0) as Item
		print_debug("Dragging %s" % [tr(selected_item.name)])
		selected_items.append(selected_item)
		selected_tree_item = get_next_selected(selected_tree_item)
	return selected_items

extends Tree
class_name ItemTree

export (String, FILE, "*.csv") var itemsCSV := "res://resources/items.csv"

var items_cache: Array
var initialized := false

var _rebuild_list_thread = null
var _cancel_rebuild_list_thread := false

func _ready():
	init_item_list()
	
func init_item_list():
	if initialized:
		return
		
	# TODO: Move to DataProvider
	items_cache = []
	var file := File.new()
	assert(file.open(itemsCSV, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 3:
			var item := Item.new(int(csv_line[0]), int(csv_line[1]), int(csv_line[2]), int(csv_line[3]))
			items_cache.append(item)
	file.close()
	
	_rebuild_list()
	initialized = true
	
func _on_FilterLineEdit_text_changed(new_text: String):
	_rebuild_list(new_text)
	SelectedListManager.set_item_filter(new_text)

func _rebuild_list(filter_text: String = ""):
	clear()
	var root := create_item()
	
	# If there's an old thread that hasn't finished, cancel it
	# if there's an old thread that has finished, join it and start a new one
	# if there's no old thread, start a new one
	if _rebuild_list_thread != null and _rebuild_list_thread.is_active():
		_cancel_rebuild_list_thread = true
		_rebuild_list_thread.wait_to_finish()
	
	_cancel_rebuild_list_thread = false
	_rebuild_list_thread = Thread.new()
	assert(_rebuild_list_thread.start(self, "_do_rebuild_list", [root, filter_text]) == OK)

func _do_rebuild_list(args: Array) -> void:
	var root: Object = args[0]
	var filter_text: String = args[1]
	var deferred_calls = []
	var normalized_filter_text := filter_text.to_upper()
	
	# Load everything first
	for item in items_cache:
		if _cancel_rebuild_list_thread:
			_cancel_rebuild_list_thread = false
			return
		if normalized_filter_text.length() == 0 or item.matches_filter_text(normalized_filter_text):
			var text := "%s\n%s [%d]" % [item.name, "★".repeat(item.quality_stars), item.id]
			var icon = item.icon
			deferred_calls.append(["_add_item_to_tree_node", root, text, icon, item])
			
	# Defer calls that modify the scene tree since they're not thread safe
	for deferred_call in deferred_calls:
		call_deferred(deferred_call[0], deferred_call[1], deferred_call[2], deferred_call[3], deferred_call[4])

func _add_item_to_tree_node(parent: Object, text: String, icon: Texture, metadata: Object) -> void:
	var item_item := create_item(parent)
	item_item.custom_minimum_height = 48
	item_item.set_text(0, text)
	item_item.set_metadata(0, metadata)
	item_item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item_item.set_custom_draw(0, self, "_draw_tree_item")
	
func _draw_tree_item(tree_item: TreeItem, rect: Rect2):
	var item: Item = tree_item.get_metadata(0)
	var icon_position := Vector2(rect.position.x + (24 - item.icon.get_width()/2), rect.position.y + (rect.size.y/2 - item.icon.get_height()/2))
	draw_texture(item.icon, icon_position)
	draw_string(get_font("font"), rect.position + Vector2(48, rect.size.y/2), item.name)
	draw_string(get_font("font"), rect.position + Vector2(48, rect.size.y/2 + 16), "%s[%d]" % ["★".repeat(item.quality_stars), item.id])


func get_drag_data(position):
	var selected_item: Item =  get_item_at_position(position).get_metadata(0)
	print_debug("Dragging %s" % [tr(selected_item.name)])
	return selected_item

func get_item_by_id(id: int) -> Item:
	# Also inefficient af
	for item in items_cache:
		if item.id == id:
			return item
	printerr("Couldn't find item with id", id)
	return null

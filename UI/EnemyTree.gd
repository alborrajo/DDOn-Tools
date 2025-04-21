extends Tree
class_name EnemyTree

export (String, FILE, "*.csv") var enemyCSV := "res://resources/enemies.csv"

var enemy_cache: Array
var initialized := false

func _ready():
	init_enemy_list()
		
func init_enemy_list():
	if initialized:
		return
		
	enemy_cache = []
	var file := File.new()
	assert(file.open(enemyCSV, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 3:
			var enemy := EnemyType.new(csv_line[0].hex_to_int(), int(csv_line[2]))
			enemy_cache.append(enemy)
	file.close()
	_rebuild_list()
	initialized = true
	
func _on_FilterLineEdit_text_changed(new_text):
	_rebuild_list(new_text)
	SelectedListManager.set_enemy_filter(new_text)
	
func _rebuild_list(filter_text: String = ""):
	var normalized_filter_text = filter_text.to_upper()
	clear()
	hide_root = true
	var root = create_item()
	for enemy in enemy_cache:
		if normalized_filter_text.length() == 0 or enemy.matches_filter_text(normalized_filter_text):
			var enemy_item = create_item(root)
			enemy_item.set_text(0, "%s [%s]" % [enemy.name, enemy.get_hex_id()]) # Displaying name and ID
			enemy_item.set_metadata(0, enemy)

func get_drag_data(position):
	var selected_enemy_type: EnemyType =  get_item_at_position(position).get_metadata(0)
	print_debug("Dragging %s" % [tr(selected_enemy_type.name)])
	return selected_enemy_type

func get_enemy_by_id(id: int) -> EnemyType:
	# Also inefficient af
	for enemy_type in enemy_cache:
		if enemy_type.id == id:
			return enemy_type
	printerr("Couldn't find enemy with id", id)
	return null

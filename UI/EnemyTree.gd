extends Tree
class_name EnemyTree


func _ready():
	_rebuild_list()
	
func _on_FilterLineEdit_text_changed(new_text):
	_rebuild_list(new_text)
	SelectedListManager.set_enemy_filter(new_text)
	
func _rebuild_list(filter_text: String = ""):
	var normalized_filter_text = filter_text.to_upper()
	clear()
	hide_root = true
	var root = create_item()
	for enemy in DataProvider.enemy_list:
		if normalized_filter_text.length() == 0 or enemy.matches_filter_text(normalized_filter_text):
			var enemy_item = create_item(root)
			enemy_item.set_text(0, "%s [%s]" % [enemy.name, enemy.get_hex_id()]) # Displaying name and ID
			enemy_item.set_metadata(0, enemy)

func get_drag_data(position):
	var selected_enemy_types = []
	var selected_tree_item = get_next_selected(null)
	while selected_tree_item != null:
		var selected_enemy_type = selected_tree_item.get_metadata(0) as EnemyType
		print_debug("Dragging %s" % [tr(selected_enemy_type.name)])
		selected_enemy_types.append(selected_enemy_type)
		selected_tree_item = get_next_selected(selected_tree_item)
	return selected_enemy_types

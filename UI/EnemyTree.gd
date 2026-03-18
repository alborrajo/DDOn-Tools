extends Tree
class_name EnemyTree


func _ready():
	hide_root = true
	var root = create_item()
	for enemy in DataProvider.enemy_list:
		var enemy_item = create_item(root)
		enemy_item.set_text(0, "%s [%s]" % [enemy.name, enemy.get_hex_id()]) # Displaying name and ID
		enemy_item.set_metadata(0, enemy)
	
func _on_FilterLineEdit_text_changed(filter_text):
	var normalized_filter_text = filter_text.to_upper()
	for enemy_tree_item in get_root().get_children():
		var enemy: EnemyType = enemy_tree_item.get_metadata(0)
		var matches_filter = normalized_filter_text.length() == 0 or enemy.matches_filter_text(normalized_filter_text)
		enemy_tree_item.visible = matches_filter
	SelectedListManager.set_enemy_filter(filter_text)

# Godot 4 migration
# "position" is shadowing an already-declared property in the base class
# func _get_drag_data(position):
func _get_drag_data(at_position):
	var selected_enemy_types = []
	var selected_tree_item = get_next_selected(null)
	while selected_tree_item != null:
		var selected_enemy_type = selected_tree_item.get_metadata(0) as EnemyType
		print_debug("Dragging %s" % [tr(selected_enemy_type.name)])
		selected_enemy_types.append(selected_enemy_type)
		selected_tree_item = get_next_selected(selected_tree_item)
	return selected_enemy_types

extends PanelContainer
class_name EnemySetPlacemark

export var stage_id: int
export var layer_no: int
export var group_id: int
export var subgroup_id: int

var _enemies := []

onready var _original_scale := rect_scale

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == BUTTON_RIGHT and (event as InputEventMouseButton).is_pressed():
		for child in $VBoxContainer.get_children():
			if child is Control and get_scaled_global_rect(child).has_point(get_global_mouse_position()):
				# Right click on the placemark
				remove_enemy(child.get_meta("enemy"))
				break

func add_enemy(enemy: Enemy) -> void:
	_enemies.append(enemy)
	var label := Label.new()
	label.text = enemy.name
	label.set_meta("enemy", enemy)
	$VBoxContainer.add_child(label)
	
func remove_enemy(enemy_to_remove: Enemy) -> void:
	for i in _enemies.size():
		if _enemies[i] == enemy_to_remove:
			_enemies.remove(i)
			break
			
	for child in $VBoxContainer.get_children():
		if child is Control and child.get_meta("enemy") == enemy_to_remove:
			child.queue_free()
			break

func clear_enemies() -> void:
	_enemies.clear()

func get_enemies() -> Array:
	return _enemies

func _process(delta):
	rect_scale = _original_scale * get_tree().get_nodes_in_group("camera")[0].zoom.x

static func get_scaled_global_rect(control: Control) -> Rect2:
	var global_rect := control.get_global_rect()
	return Rect2(global_rect.position, global_rect.size*control.rect_scale)

extends Label
class_name EnemyPlacemark

export var stage_id: int
export var layer_no: int
export var group_id: int
export var subgroup_id: int
export var position_index: int
export var enemy_id: String

onready var _original_scale := rect_scale
onready var _original_text := text

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed() and get_scaled_global_rect().has_point(get_global_mouse_position()):
		# Right click on the placemark
		set_enemy(null)
		get_tree().set_input_as_handled()

func set_enemy(enemy: Enemy) -> void:
	if enemy == null:
		enemy_id = ""
		text = _original_text
	else:
		enemy_id = enemy.id
		text = enemy.name

func get_scaled_global_rect():
	var global_rect := get_global_rect()
	return Rect2(global_rect.position, global_rect.size*rect_scale)

func _process(delta):
	rect_scale = _original_scale * get_tree().get_nodes_in_group("camera")[0].zoom.x

extends Resource
class_name EnemySet

export var stage_id: int setget _set_stage_id
export var layer_no: int setget _set_layer_no
export var group_id: int setget _set_group_id
export var subgroup_id: int setget _set_subgroup_id

var _enemies: Array

func _init(stage_id: int, layer_no: int, group_id: int, subgroup_id: int):
	self.stage_id = stage_id
	self.layer_no = layer_no
	self.group_id = group_id
	self.subgroup_id = subgroup_id
	_enemies = []

func get_enemies() -> Array:
	return _enemies

func add_enemy(enemy: Enemy) -> void:
	_enemies.append(enemy)
	emit_changed()
	
func remove_enemy(index: int) -> void:
	_enemies.remove(index)
	emit_changed()
	
func clear_enemies() -> void:
	_enemies.clear()
	emit_changed()
	
func _set_stage_id(value: int) -> void:
	stage_id = value
	emit_changed()
	
func _set_layer_no(value: int) -> void:
	layer_no = value
	emit_changed()
	
func _set_group_id(value: int) -> void:
	group_id = value
	emit_changed()
	
func _set_subgroup_id(value: int) -> void:
	subgroup_id = value
	emit_changed()

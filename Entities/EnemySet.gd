extends Resource
class_name EnemySet

export var stage_id: int setget _set_stage_id
export var layer_no: int setget _set_layer_no
export var group_id: int setget _set_group_id
export var subgroup_id: int setget _set_subgroup_id
export var max_positions: int setget _set_max_positions

var _enemies: Array

func _init(_stage_id: int, _layer_no: int, _group_id: int, _subgroup_id: int):
	self.stage_id = _stage_id
	self.layer_no = _layer_no
	self.group_id = _group_id
	self.subgroup_id = _subgroup_id
	self.max_positions = 0
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
	
func _to_string():
	return "Enemy Set (%d,%d,%d,%d) - %d/%d spots" % [stage_id, layer_no, group_id, subgroup_id, effective_enemy_count(), max_positions]
	
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
func _set_max_positions(value: int) -> void:
	max_positions = value
	emit_changed()

func effective_enemy_count() -> int:
	var day_enemies := 0
	var night_enemies := 0
	for enemy in _enemies:
		if enemy.time_type == 0:
			day_enemies = day_enemies+1
			night_enemies = night_enemies+1
		elif enemy.time_type == 1:
			day_enemies = day_enemies+1
		elif enemy.time_type == 2:
			night_enemies = night_enemies+1
		else:
			printerr("Unknown time type"+enemy.time_type)
	return int(max(day_enemies, night_enemies))

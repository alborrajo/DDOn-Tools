extends Resource
class_name EnemySet

export var stage_id: int setget _set_stage_id
export var layer_no: int setget _set_layer_no
export var group_id: int setget _set_group_id
export var subgroup_id: int setget _set_subgroup_id
export var positions: Array setget _set_positions

func _init(_stage_id: int, _layer_no: int, _group_id: int, _subgroup_id: int):
	self.stage_id = _stage_id
	self.layer_no = _layer_no
	self.group_id = _group_id
	self.subgroup_id = _subgroup_id
	self.positions = []

func add_enemy(enemy: Enemy) -> int:
	# Find first null position
	var position_index = -1
	for i in positions.size():
		var position: EnemyPosition = positions[i]
		if position.enemies.size() == 0:
			position_index = i
			break
	
	if position_index == -1:
		return FAILED
	else:
		positions[position_index].add_enemy(enemy)
		return OK
		
func add_enemy_at_index(enemy: Enemy, index: int) -> int:
	if index < 0 || index >= positions.size():
		return FAILED
	else:
		positions[index].add_enemy(enemy)
		return OK
		
func remove_enemy_and_shift(index: int) -> int:
	if index < 0 || index >= positions.size():
		return FAILED
		
	for idx in range(index, positions.size() - 1):
		positions[idx].enemies = positions[idx+1].enemies
	positions[positions.size()-1].clear_enemies()
	return OK
	
func clear_enemies() -> void:
	for position in positions:
		position.clear_enemies()
	
func _to_string():
	return "Enemy Set (%d,%d,%d,%d) - %d/%d spots" % [stage_id, layer_no, group_id, subgroup_id, effective_enemy_count(), positions.size()]
	
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

func _set_positions(value: Array) -> void:
	for old_position in positions:
		if old_position.is_connected("changed", self, "emit_changed"):
			old_position.disconnect("changed", self, "emit_changed")
	positions = value
	for new_position in positions:
		assert(new_position.connect("changed", self, "emit_changed") == OK)
	emit_changed()

func effective_enemy_count() -> int:
	var count := 0
	for position in positions:
		if position.enemies.size() > 0:
			count = count+1
	return count

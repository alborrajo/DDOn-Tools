extends Resource
class_name EnemySet

export var stage_id: int setget _set_stage_id
export var layer_no: int setget _set_layer_no
export var group_id: int setget _set_group_id

export var subgroup_position_template: Array # Array of Vector3

var subgroups: Array # Array of EnemySubgroup

func _init(_stage_id: int, _layer_no: int, _group_id: int):
	self.stage_id = _stage_id
	self.layer_no = _layer_no
	self.group_id = _group_id
	self.subgroup_position_template = []
	self.subgroups = []

func get_subgroup_or_create_with_positions(subgroup_id: int, positions: Array):
	if subgroups.size() <= subgroup_id:
		subgroups.resize(subgroup_id+1)
	if subgroups[subgroup_id] == null:
		var new_subgroup := EnemySubgroup.new(positions)
		assert(new_subgroup.connect("changed", self, "emit_changed") == OK)
		subgroups[subgroup_id] = new_subgroup
	return subgroups[subgroup_id]
	
func get_subgroup(subgroup_id: int):
	return get_subgroup_or_create_with_positions(subgroup_id, subgroup_position_template)
	
func clear_enemies() -> void:
	for subgroup in subgroups:
		if subgroup != null:
			subgroup.clear_enemies()

func _set_stage_id(value: int) -> void:
	stage_id = value
	emit_changed()
	
func _set_layer_no(value: int) -> void:
	layer_no = value
	emit_changed()
	
func _set_group_id(value: int) -> void:
	group_id = value
	emit_changed()

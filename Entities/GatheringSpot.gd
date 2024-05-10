extends Resource
class_name GatheringSpot

export var stage_id: int setget _set_stage_id
export var group_id: int setget _set_group_id
export var subgroup_id: int setget _set_subgroup_id

var _gathering_items: Array

func _init(_stage_id: int, _group_id: int, _subgroup_id: int):
	self.stage_id = _stage_id
	self.group_id = _group_id
	self.subgroup_id = _subgroup_id
	_gathering_items = []

func get_gathering_items() -> Array:
	return _gathering_items

func add_item(item: GatheringItem) -> void:
	_gathering_items.append(item)
	emit_changed()
	
func remove_item(index: int) -> void:
	_gathering_items.remove(index)
	emit_changed()
	
func clear_gathering_items() -> void:
	_gathering_items.clear()
	emit_changed()
	
func _to_string():
	return "Gathering Spot (%d,%d,%d)" % [stage_id, group_id, subgroup_id]
	
func _set_stage_id(value: int) -> void:
	stage_id = value
	emit_changed()
	
func _set_group_id(value: int) -> void:
	group_id = value
	emit_changed()
	
func _set_subgroup_id(value: int) -> void:
	subgroup_id = value
	emit_changed()

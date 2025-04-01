extends Resource
class_name GatheringSpot

const GATHERING_TYPES := [
	"OM_GATHER_NONE",
	"OM_GATHER_TREE_LV1",
	"OM_GATHER_TREE_LV2",
	"OM_GATHER_TREE_LV3",
	"OM_GATHER_TREE_LV4",
	"OM_GATHER_JWL_LV1",
	"OM_GATHER_JWL_LV2",
	"OM_GATHER_JWL_LV3",
	"OM_GATHER_CRST_LV1",
	"OM_GATHER_CRST_LV2",
	"OM_GATHER_CRST_LV3",
	"OM_GATHER_CRST_LV4",
	"OM_GATHER_KEY_LV1",
	"OM_GATHER_KEY_LV2",
	"OM_GATHER_KEY_LV3",
	"OM_GATHER_TREA_IRON",
	"OM_GATHER_DRAGON",
	"OM_GATHER_CORPSE",
	"OM_GATHER_SHIP",
	"OM_GATHER_GRASS",
	"OM_GATHER_FLOWER",
	"OM_GATHER_MUSHROOM",
	"OM_GATHER_CLOTH",
	"OM_GATHER_BOOK",
	"OM_GATHER_SAND",
	"OM_GATHER_BOX",
	"OM_GATHER_ALCHEMY",
	"OM_GATHER_WATER",
	"OM_GATHER_SHELL",
	"OM_GATHER_ANTIQUE",
	"OM_GATHER_TWINKLE",
	"OM_GATHER_TREA_OLD",
	"OM_GATHER_TREA_TREE",
	"OM_GATHER_TREA_SILVER",
	"OM_GATHER_TREA_GOLD",
	"OM_GATHER_KEY_LV4",
	"OM_GATHER_ONE_OFF",
]

export var stage_id: int setget _set_stage_id
export var group_id: int setget _set_group_id
export var subgroup_id: int setget _set_subgroup_id
export var type: int setget _set_type
export var coordinates: Vector3 setget _set_coordinates

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
	return "Gathering Spot (%s) @ (%d,%d,%d)" % [GATHERING_TYPES[type], stage_id, group_id, subgroup_id]
	
func _set_stage_id(value: int) -> void:
	stage_id = value
	emit_changed()
	
func _set_group_id(value: int) -> void:
	group_id = value
	emit_changed()
	
func _set_subgroup_id(value: int) -> void:
	subgroup_id = value
	emit_changed()

func _set_type(value: int) -> void:
	type = value
	emit_changed()

func _set_coordinates(value: Vector3) -> void:
	coordinates = value
	emit_changed()

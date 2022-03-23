extends Resource
class_name EnemyType

export var id: int
export var name: String
export var default_hm_preset_no: int

func _init(id: int, name: String, default_hm_preset_no: int):
	self.id = id
	self.name = name
	self.default_hm_preset_no = default_hm_preset_no

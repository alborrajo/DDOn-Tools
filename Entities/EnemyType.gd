extends Resource
class_name EnemyType

const TRANSLATION_KEY_FORMAT = "NAME_0x%06X"

export var id: int
export var name: String setget , _get_name
export var default_hm_preset_no: int

func _init(_id: int, _name: String, _default_hm_preset_no: int):
	self.id = _id
	self.name = _name
	self.default_hm_preset_no = _default_hm_preset_no

func _get_name():
	return tr(TRANSLATION_KEY_FORMAT % id)

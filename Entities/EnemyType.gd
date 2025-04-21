extends Resource
class_name EnemyType

const HEX_ID_FORMAT = "0x%06X"
const TRANSLATION_KEY_FORMAT = "NAME_" + HEX_ID_FORMAT

export var id: int
export var name: String setget , _get_name
export var default_hm_preset_no: int

func _init(_id: int, _default_hm_preset_no: int):
	self.id = _id
	self.default_hm_preset_no = _default_hm_preset_no

func _get_name():
	return tr(TRANSLATION_KEY_FORMAT % id)
	
func get_hex_id() -> String:
	return HEX_ID_FORMAT % id
	
func matches_filter_text(uppercase_filter_text: String) -> bool:
	return uppercase_filter_text in _get_name().to_upper() or uppercase_filter_text in String(get_hex_id()).to_upper()

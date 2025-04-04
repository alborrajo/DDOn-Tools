extends Resource
class_name Item

const TRANSLATION_KEY_FORMAT = "ITEM_NAME_%d"

export var id: int
export var icon_no: int
export var icon_co_no: int
export var icon_path: String setget , _get_icon_path
export var name: String setget , _get_name

var _cached_icon_path = null

func _init(_id: int, _icon_no: int, _icon_co_no: int):
	self.id = _id
	self.icon_no = _icon_no
	self.icon_co_no = _icon_co_no

func _get_icon_path():
	if _cached_icon_path == null:
		var arc_path = "res://resources/items/ii%06d" % [self.icon_no]
		var dir = Directory.new()
		assert(dir.open(arc_path) == OK)
		assert(dir.list_dir_begin(true) == OK)
		var icon_filename = dir.get_next()
		assert(icon_filename != "")
		_cached_icon_path = arc_path+"/"+icon_filename
	return _cached_icon_path

func _get_name():
	return tr(TRANSLATION_KEY_FORMAT % id)

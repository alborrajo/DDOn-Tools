extends Resource
class_name Item

const TRANSLATION_KEY_FORMAT = "ITEM_NAME_%d"

export var id: int
export var quality_stars: int
export var icon_no: int
export var icon_co_no: int
export var icon: Texture setget , _get_icon
export var name: String setget , _get_name

var _cached_icon = null

func _init(_id: int, _quality_stars: int, _icon_no: int, _icon_co_no: int):
	self.id = _id
	self.quality_stars = _quality_stars
	self.icon_no = _icon_no
	self.icon_co_no = _icon_co_no

func _get_icon():
	if _cached_icon == null:
		var arc_path = "res://resources/items/ii%06d" % [self.icon_no]
		var dir = Directory.new()
		assert(dir.open(arc_path) == OK)
		assert(dir.list_dir_begin(true) == OK)
		var icon_filename = dir.get_next()
		assert(icon_filename != "")
		var icon_path = arc_path+"/"+icon_filename
		_cached_icon = load(icon_path)
	return _cached_icon

func _get_name():
	return tr(TRANSLATION_KEY_FORMAT % id)

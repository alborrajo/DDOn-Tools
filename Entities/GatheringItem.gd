extends Resource
class_name GatheringItem

var item: Item setget _set_item
var num: int setget _set_num
var quality: int setget _set_quality
var is_hidden: bool setget _set_is_hidden

func _init(item: Item):
	self.item = item
	self.num = 1

func get_display_name() -> String:
	return "%s (%d)" % [item.name, num]

func _set_item(value):
	item = value
	emit_changed()
func _set_num(value):
	num = value
	emit_changed()
func _set_quality(value):
	quality = value
	emit_changed()
func _set_is_hidden(value):
	is_hidden = value
	emit_changed()

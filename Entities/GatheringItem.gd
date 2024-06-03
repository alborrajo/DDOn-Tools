extends Resource
class_name GatheringItem

var item: Item setget _set_item
var num: int setget _set_num
var max_num: int setget _set_max_num
var quality: int setget _set_quality
var is_hidden: bool setget _set_is_hidden
var drop_chance: float setget _set_drop_chance

func _init(_item: Item):
	self.item = _item
	self.num = 1
	self.max_num = 1
	self.drop_chance = 100

func get_display_name() -> String:
	return "%s (%d~%d)" % [item.name, num, max_num]

func _set_item(value):
	item = value
	emit_changed()
	
func _set_num(value):
	num = value
	if max_num < value:
		max_num = value
	emit_changed()
	
func _set_max_num(value):
	if value >= num:
		max_num = value
	else:
		max_num = num
	emit_changed()
	
func _set_quality(value):
	quality = value
	emit_changed()
	
func _set_is_hidden(value):
	is_hidden = value
	emit_changed()
	
func _set_drop_chance(value):
	drop_chance = clamp(value, 0, 100)
	emit_changed()

extends Reference
class_name RoomMap

var map_name: String
var offset: Vector2

func _init(map_name: String, offset: Vector2):
	self.map_name = map_name
	self.offset = offset

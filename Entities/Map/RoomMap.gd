extends Reference
class_name RoomMap

var map_name: String
var offset: Vector2

func _init(mn: String, o: Vector2):
	self.map_name = mn
	self.offset = o

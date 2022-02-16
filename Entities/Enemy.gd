extends Resource
class_name Enemy

export var id: String

export var name: String

func _init(id: String, name: String):
	self.id = id
	self.name = name

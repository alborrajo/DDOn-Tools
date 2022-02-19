extends Resource
class_name EnemyType

export var id: int

export var name: String

func _init(id: int, name: String):
	self.id = id
	self.name = name

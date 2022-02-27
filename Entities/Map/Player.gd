extends MapEntity

class_name Player

var CharacterId : int
var FirstName : String
var LastName : String

func _init(var player : Dictionary).(player):
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]
	#print_debug("[%d] %s %s @ (X: %d, Y: %d, Z: %d)" % [CharacterId, FirstName, LastName, X, Y, Z])

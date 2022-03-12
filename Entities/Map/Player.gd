extends MapEntity
class_name Player

var CharacterId : int
var FirstName : String
var LastName : String

func _init(player : Dictionary, land_id: String).(Vector3(player["X"],player["Y"],player["Z"]), land_id):
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]
	print_debug("[%d] %s %s @ (X: %d, Y: %d, Z: %d)" % [CharacterId, FirstName, LastName, pos.x, pos.y, pos.z])

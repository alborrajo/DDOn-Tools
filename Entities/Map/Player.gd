extends MapEntity
class_name Player

var CharacterId : int
var FirstName : String
var LastName : String
var StageNo: int

func _init(player : Dictionary, field_id: String = "0").(Vector3(player["X"],player["Y"],player["Z"]), field_id):
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]
	StageNo = player["StageNo"]
	print_debug("[%d] %s %s @ %d %s" % [CharacterId, FirstName, LastName, StageNo, pos.round()])

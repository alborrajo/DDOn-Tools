extends MapEntity
class_name PlayerMapEntity

var CharacterId : int
var FirstName : String
var LastName : String

func _init(player : Dictionary).(Vector3(player["X"],player["Y"],player["Z"]), player["StageNo"]):
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]

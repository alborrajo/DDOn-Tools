extends Reference
class_name PlayerMapEntity

var StageNo: int
var pos: Vector3
var AccountId: int
var AccountName: String
var CharacterId : int
var FirstName : String
var LastName : String

func _init(player: Dictionary):
	StageNo = player["StageNo"]
	pos = Vector3(player["X"],player["Y"],player["Z"])
	AccountId = player["AccountId"]
	AccountName = player["AccountName"]
	CharacterId = player["CharacterId"]
	FirstName = player["FirstName"]
	LastName = player["LastName"]

extends MapEntity
class_name Marker

var UniqueId : int
var GroupNo : int
var StageNo : int

func _init(marker : Dictionary, field_id: String).(Vector3(marker["Pos"]["X"],marker["Pos"]["Y"],marker["Pos"]["Z"]), field_id):
	UniqueId = marker["UniqueId"]
	GroupNo = marker["GroupNo"]
	StageNo = marker["StageNo"]

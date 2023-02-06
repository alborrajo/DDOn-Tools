extends MapEntity
class_name Marker

var UniqueId : int
var GroupNo : int

func _init(marker : Dictionary, stage_no: int).(Vector3(marker["Pos"]["X"],marker["Pos"]["Y"],marker["Pos"]["Z"]), stage_no):
	UniqueId = marker["UniqueId"]
	GroupNo = marker["GroupNo"]

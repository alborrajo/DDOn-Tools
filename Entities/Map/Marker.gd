extends MapEntity

class_name Marker

var Type : String
var UniqueId : int
var GroupNo : int
var StageNo : int

func _init(var marker : Dictionary).(marker):
	Type = marker["Type"]
	UniqueId = marker["UniqueId"]
	GroupNo = marker["GroupNo"]
	StageNo = marker["StageNo"]
	
	

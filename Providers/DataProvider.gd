extends Node

export (String, FILE, "*.csv") var stage_list_json := "res://resources/StageList.json"

var stage_list: Array

func _ready():
	var file := File.new()
	file.open(stage_list_json, File.READ)
	stage_list = parse_json(file.get_as_text())
	
func stage_no_to_stage_id(stage_no: int) -> int:
	for stage in stage_list:
		if stage["StageNo"] == stage_no:
			return stage["ID"]
			
	push_warning("No stage found with StageNo %s" % stage_no)
	return -1

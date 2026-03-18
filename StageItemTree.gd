extends Tree
class_name StagesItemTree

func _ready():
	var stage_no_list = DataProvider.repo["StageEctMarkers"].keys()
	var root = create_item()
	for stage_no in stage_no_list:
		var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
		var item_text = ""
		if stage_id == -1:
			item_text = "Stage No. " + stage_no
		else:
			item_text = "%s [%s]" % [tr(str("STAGE_NAME_", stage_id)), stage_id]
		var stage_item := root.create_child()
		stage_item.set_text(0,item_text)
		stage_item.set_metadata(0,stage_no)

func _on_StagesLineEdit_text_changed(filter_text: String):
	for stage_item in get_root().get_children():
		var item_text = stage_item.get_text(0)
		var matches := filter_text == "" or item_text.to_lower().find(filter_text.to_lower()) != -1
		stage_item.visible = matches

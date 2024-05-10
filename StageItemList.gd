extends ItemList
class_name StagesItemList

func _ready():
	self.clear()
	var stage_no_list = DataProvider.repo["StageEctMarkers"].keys()
	for stage_no in stage_no_list:
		var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
		if stage_id == -1:
			add_item("Stage No. "+stage_no) # TODO: i18n
		else:
			add_item("%s [%s]" % [tr(str("STAGE_NAME_",stage_id)), stage_id])
		set_item_metadata(get_item_count()-1, stage_no)


func _on_StagesLineEdit_text_changed(new_text: String):
	new_text = new_text.to_lower() # Normalize to lowercase for case insensitivity
	clear()
	var stage_no_list = DataProvider.repo["StageEctMarkers"].keys()
	for stage_no in stage_no_list:
		var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
		var item_text = ""
		if stage_id == -1:
			item_text = "Stage No. " + stage_no
		else:
			item_text = "%s [%s]" % [tr(str("STAGE_NAME_", stage_id)), stage_id]

		# Check if the item text matches the input text
		if new_text == "" or item_text.to_lower().find(new_text) != -1:
			add_item(item_text) # Add item if it matches
			set_item_metadata(get_item_count()-1, stage_no)

extends ItemList
class_name StagesItemList

func _ready():
	self.clear()
	var stage_no_list = DataProvider.repo["StageEctMarkers"].keys()
	for stage_no in stage_no_list:
		var stage_id = DataProvider.stage_no_to_stage_id(int(stage_no))
		add_item("%s [%s]" % [tr(str("STAGE_NAME_",stage_id)), stage_id])
		set_item_metadata(get_item_count()-1, stage_no)

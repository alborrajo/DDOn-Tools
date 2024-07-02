extends OptionButton
class_name NamedEnemyParamsIdOptionButton

var _last_selected_id: int = -1
var _last_filter_text: String = ""

func _ready():
	_rebuild_list()
	select_by_id(Enemy.DEFAULT_NAMED_PARAMS_ID)
	
func select_by_id(id: int):
	_last_selected_id = id
	var idx := get_item_index(id)
	if idx == -1:
		# Rebuild filtered list if the named param with the id isn't in the filtered list
		_rebuild_list(_last_filter_text)
		idx = get_item_index(id)
	select(idx)
	

func _rebuild_list(filter_text: String = ""):
	clear()
	var normalized_filter_text = filter_text.to_upper()
	for named_param in DataProvider.named_params:
		var named_param_text: String = "%s [%d]" % [named_param.format_name("<name>"), named_param.id]
		var normalized_named_param_text := named_param_text.to_upper()
		if normalized_filter_text.length() == 0 or normalized_filter_text in normalized_named_param_text or named_param.id == _last_selected_id:
			add_item(named_param_text, named_param.id)
			var last_added_item_index := get_item_count()-1
			set_item_metadata(last_added_item_index, named_param)
			set_item_tooltip(last_added_item_index, named_param.to_string())

func _on_NamedEnemyParamsIdOptionButton_item_selected(index):
	_last_selected_id = get_item_id(index)
	
func _on_NamedEnemyParamsFilterLineEdit_text_changed(filter_text):
	_last_filter_text = filter_text
	_rebuild_list(filter_text)
	select_by_id(_last_selected_id)

func _on_NamedParamResetButton_pressed():
	select_by_id(Enemy.DEFAULT_NAMED_PARAMS_ID)
	emit_signal("item_selected", selected)

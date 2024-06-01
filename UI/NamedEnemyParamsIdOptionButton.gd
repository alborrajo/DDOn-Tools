extends OptionButton
class_name NamedEnemyParamsIdOptionButton

func _ready():
	for named_param in DataProvider.named_params:
		add_item(named_param.format_name("<name>"), named_param.id)
		var last_added_item_index := get_item_count()-1
		set_item_metadata(last_added_item_index, named_param)
		set_item_tooltip(last_added_item_index, named_param.to_string())

func select(idx: int):
	if idx == -1:
		select_by_id(0x8FA)
	else:
		.select(idx)
	
func select_by_id(id: int):
	select(get_item_index(id))

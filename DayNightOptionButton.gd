extends OptionButton

func _on_DayNightOptionButton_item_selected(index):
	SetProvider.select_day_night(index)

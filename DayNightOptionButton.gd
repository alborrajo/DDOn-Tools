extends OptionButton

signal day_night_selected(index)

func _ready():
	connect("item_selected", self, "_on_DayNightOptionButton_item_selected")

func _on_DayNightOptionButton_item_selected(index):
	emit_signal("day_night_selected", index)

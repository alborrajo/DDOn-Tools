extends PopupPanel
class_name NotificationPopup

func notify(text: String) -> void:
	$Label.text = text
	popup()

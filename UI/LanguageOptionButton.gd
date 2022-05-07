extends OptionButton
class_name LanguageOptionButton

func _ready():
	for locale in TranslationServer.get_loaded_locales():
		add_item(TranslationServer.get_locale_name(locale))
		set_item_metadata(get_item_count()-1, locale)
		if(TranslationServer.get_locale() == locale):
			select(get_item_count()-1)
		
	connect("item_selected", self, "_on_item_selected")
	
func _on_item_selected(idx: int):
	TranslationServer.set_locale(get_item_metadata(idx))
	
	# Reload everything, lol, lmao, yolo
	# Yes, this means unsaved changes will get lost
	get_tree().reload_current_scene()

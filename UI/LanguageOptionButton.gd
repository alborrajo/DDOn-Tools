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
	
	# Autosave to prevent unsaved changes from getting lost
	var saved_successfully: bool = owner.get_node("left/tab/Enemies/FileMenu").resave()
	
	if saved_successfully:
		# Reload everything, lol, lmao, yolo	
		get_tree().reload_current_scene()

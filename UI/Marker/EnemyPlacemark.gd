extends GenericPlacemark
class_name EnemyPlacemark

const COLOR_BLOOD_ORB = Color.VIOLET
const COLOR_HIGH_ORB = Color.ORANGE_RED
const COLOR_DEFAULT = Color.WHITE

@export var enemy: Resource: set = set_enemy

func _ready():
	super.ready()
	assert(SelectedListManager.connect("enemy_filter_changed", Callable(self, "_on_enemy_filter_changed")) == OK)
	assert(SetProvider.connect("s_selected_day_night", Callable(self, "_on_day_night_selected")) == OK)
	_on_day_night_selected(SetProvider.selected_day_night)
	
func _on_day_night_selected(index):
	if enemy != null:
		_update_placemark_visibility(index)
	else:
		printerr("ENEMY REFERENCE IS NULL")

func _update_placemark_visibility(index):
	if enemy != null:
		var enemyTimeType = enemy.time_type
		if index == 0 or enemyTimeType == 0 or enemyTimeType == index:
			show()
		else:
			hide()

func _on_EnemyPlacemark_pressed():
	_selection_function()
	
func get_selection_entity():
	return enemy
	
func set_enemy(em: Enemy) -> void:
	if enemy != null and enemy.is_connected("changed", Callable(self, "_on_enemy_changed")):
		enemy.disconnect("changed", Callable(self, "_on_enemy_changed"))
		
	enemy = em
		
	if em != null:
		assert(em.connect("changed", Callable(self, "_on_enemy_changed")) == OK)
		_on_enemy_changed()
	
func _on_enemy_changed():
	text = enemy.get_display_name()
	
	if enemy.named_param.type == NamedParam.Type.NAMED_TYPE_REPLACE:
		text = "*"+text
	
	if enemy.time_type == 1:
		text = "\u2600"+text # day
	elif enemy.time_type == 2:
		text = "\u25d0"+text # night
	elif enemy.time_type == 3:
		text = "\u2756"+text # custom
	
	if enemy.is_blood_enemy:
		self_modulate = COLOR_BLOOD_ORB
	elif enemy.is_highorb_enemy:
		self_modulate = COLOR_HIGH_ORB
	else: 
		self_modulate = COLOR_DEFAULT

# Godot 4 migration
# The local function parameter "position" is shadowing an already-declared property in the base class "Control".
# func _get_drag_data(position):
func _get_drag_data(at_position):
	super._get_drag_data(at_position)
	return enemy

func _on_enemy_filter_changed(uppercase_filter_text: String):
	if enemy.enemy_type.matches_filter_text(uppercase_filter_text):
		modulate = SelectedListManager.FILTER_MATCH_COLOR
		return
	modulate = SelectedListManager.FILTER_NONMATCH_COLOR

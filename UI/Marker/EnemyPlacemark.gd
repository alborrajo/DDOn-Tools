extends GenericPlacemark
class_name EnemyPlacemark

const COLOR_BLOOD_ORB = Color.rebeccapurple
const COLOR_HIGH_ORB = Color.darkred
const COLOR_DEFAULT = Color.white

export (Resource) var enemy: Resource setget set_enemy

onready var _detailsPanel: DetailsPanel = DetailsPanel.get_instance(get_tree())
var ToD_index = 0

func _ready():
	.ready()
	SetProvider.connect("selected_day_night", self, "_on_day_night_selected")
	SetProvider.set_ToD()

func _on_day_night_selected(index):
	if enemy != null:
		_update_placemark_visibility(index)
		#print("should be:", index)
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
	_selection_function(enemy)

func set_enemy(em: Enemy) -> void:
	if enemy != null and enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
		
	enemy = em
		
	if em != null:
		em.connect("changed", self, "_on_enemy_changed")
		_on_enemy_changed()
	
	if enemy != null and enemy.has_method("_time_type"):
		var time_type = enemy.get_time_type()
	
func _on_enemy_changed():
	text = enemy.get_display_name()
	if enemy.is_blood_enemy:
		self_modulate = COLOR_BLOOD_ORB
	elif enemy.is_highorb_enemy:
		self_modulate = COLOR_HIGH_ORB
	else: 
		self_modulate = COLOR_DEFAULT

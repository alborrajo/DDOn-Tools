extends GenericPlacemark
class_name EnemyPlacemark

const COLOR_BLOOD_ORB = Color.rebeccapurple
const COLOR_HIGH_ORB = Color.darkred
const COLOR_DEFAULT = Color.white

export (Resource) var enemy: Resource setget set_enemy

onready var _enemyDetails: EnemyDetails = EnemyDetails.get_instance(get_tree()) 

func _on_EnemyPlacemark_pressed():
	# Left Click
	_enemyDetails.enemy = enemy
	
func set_enemy(em: Enemy) -> void:
	if enemy != null and enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
		
	enemy = em
		
	if em != null:
		em.connect("changed", self, "_on_enemy_changed")
		_on_enemy_changed()
	
func _on_enemy_changed():
	text = enemy.get_display_name()
	
	if enemy.is_blood_enemy:
		modulate = COLOR_BLOOD_ORB
	elif enemy.is_highorb_enemy:
		modulate = COLOR_HIGH_ORB
	else: 
		modulate = COLOR_DEFAULT

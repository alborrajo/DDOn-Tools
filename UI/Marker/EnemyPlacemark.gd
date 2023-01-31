extends Button
class_name EnemyPlacemark

signal enemy_removed()

const COLOR_BLOOD_ORB = Color.rebeccapurple
const COLOR_HIGH_ORB = Color.darkred
const COLOR_DEFAULT = Color.white

export (Resource) var enemy: Resource setget set_enemy

onready var _enemyDetails: EnemyDetails = EnemyDetails.get_instance(get_tree()) 

func _gui_input(event):
	if event is InputEventMouseButton:
		# Right Click
		if (event as InputEventMouseButton).button_mask == BUTTON_RIGHT:
			# Notify removal
			emit_signal("enemy_removed")
			# Deselect this enemy from the enemy details panel
			# TODO: Decouple by moving selected enemy to EnemyProvider maybe
			if _enemyDetails.enemy == enemy:
				_enemyDetails.enemy = null
			# Remove node
			queue_free()

func _on_EnemyPlacemark_pressed():
	# Left Click
	_enemyDetails.enemy = enemy
	
func set_enemy(em: Enemy) -> void:
	if enemy != null and enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
		
	enemy = em
		
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

extends Button
class_name EnemyPlacemark

export (Resource) var enemy: Resource setget set_enemy

onready var _enemyDetails: EnemyDetails = EnemyDetails.get_instance(get_tree()) 

func _on_EnemyPlacemark_gui_input(event):
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_mask == BUTTON_RIGHT:
			# Right Click
			if _enemyDetails.enemy == enemy:
				_enemyDetails.enemy = null
			queue_free()

func _on_EnemyPlacemark_pressed():
	# Left Click
	_enemyDetails.enemy = enemy
	
func set_enemy(em: Enemy) -> void:
	text = "%s (Lv. %d)" % [em.enemy_type.name, em.lv]
	enemy = em

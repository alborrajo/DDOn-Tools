extends Resource
class_name EnemyPosition

export var coordinates: Vector3 setget _set_coordinates
var enemies: Array = [] setget _set_enemies

func _init(p: Vector3):
	self.coordinates = p
	
func _set_coordinates(c):
	coordinates = c
	emit_changed()

func _set_enemies(e):
	enemies = e
	emit_changed()
	
func add_enemy(e: Enemy):
	enemies.append(e)
	emit_changed()
	
func remove_enemy(index: int):
	enemies.remove(index)
	emit_changed()

func clear_enemies():
	enemies.clear()
	emit_changed()

func has_conflicting_enemy_times() -> bool:
	# TODO: Check custom times too
	var enemy_during_day := false
	var enemy_during_night := false
	for enemy in enemies:
		if enemy.time_type == 1:
			if enemy_during_day:
				return true
			enemy_during_day = true
		elif enemy.time_type == 2:
			if enemy_during_night:
				return true
			enemy_during_night = true
		else:
			if enemy_during_day || enemy_during_night:
				return true
			enemy_during_day = true
			enemy_during_night = true
	return false

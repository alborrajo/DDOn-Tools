extends ConfirmationDialog
class_name DayNightTimeMigrationConfirmationDialog

var enemies_with_old_day_range: Array
var enemies_with_old_night_range: Array

func _on_EnemyFileMenu_file_loaded():
	# Heuristic for guessing if the file is from when we mistakenly had 
	# the day as 7:00 to 17:59 and the night as 18:00 to 6:59 instead of
	# the day as 6:00 to 17:59 and the night as 18:00 to 5:59 like we do now
	enemies_with_old_day_range = []
	enemies_with_old_night_range = []
	var has_enemies_with_new_time_range := false
	for enemy_set in SetProvider.get_all_enemy_sets():
		for enemy_subgroup in enemy_set.subgroups:
			if enemy_subgroup != null:
				for enemy_position in enemy_subgroup.positions:
					for enemy in enemy_position.enemies:
						# Check if it has the new time range
						if enemy.time_type == 1 or enemy.time_type == 2:
							has_enemies_with_new_time_range = true
							break
						elif enemy.time_type == 3:
							if enemy.custom_time == "07:00,17:59":
								enemies_with_old_day_range.append(enemy)
							elif enemy.custom_time == "18:00,06:59":
								enemies_with_old_night_range.append(enemy)
	if not has_enemies_with_new_time_range and (not enemies_with_old_day_range.empty() or not enemies_with_old_night_range.empty()):
		popup()

func _on_DayNightTimeMigrationConfirmationDialog_confirmed():
	for enemy in enemies_with_old_day_range:
		enemy.time_type = 1
	for enemy in enemies_with_old_night_range:
		enemy.time_type = 2

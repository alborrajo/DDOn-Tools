extends Resource
class_name EnemySubgroup

var positions: Array # Array of EnemyPositions

func _init(position_template: Array):
	self.positions = []
	for position_template_item in position_template:
		var position := EnemyPosition.new(position_template_item)
		assert(position.connect("changed", self, "emit_changed") == OK)
		self.positions.append(position)

func add_enemy(enemy: Enemy) -> int:
	# Find first non-conflictive position
	var position_index = -1
	for i in positions.size():
		var position: EnemyPosition = positions[i]
		if not position.adding_enemy_causes_conflict(enemy):
			position_index = i
			break
	
	if position_index == -1:
		# Put in the first position
		var result := add_enemy_at_index(enemy, 0)
		if result == OK:
			return ERR_PRINTER_ON_FIRE
		else:
			return result
	else:
		positions[position_index].add_enemy(enemy)
		return OK
		
func add_enemy_at_index(enemy: Enemy, index: int) -> int:
	if index < 0 || index >= positions.size():
		return FAILED
	else:
		positions[index].add_enemy(enemy)
		return OK
		
func remove_enemy_and_shift(index: int) -> int:
	if index < 0 || index >= positions.size():
		return FAILED
		
	for idx in range(index, positions.size() - 1):
		positions[idx].enemies = positions[idx+1].enemies
	positions[positions.size()-1].clear_enemies()
	return OK
	
func clear_enemies() -> void:
	for position in positions:
		position.clear_enemies()

func effective_enemy_count() -> int:
	var count := 0
	for position in positions:
		if position.enemies.size() > 0:
			count = count+1
	return count

extends GenericMarker
class_name PlayerMarker

var player : Player

func set_player(var p_player : Player):
	player = p_player
	set_pos_vec(player.get_map_position())

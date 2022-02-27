extends GenericMarker
class_name PlayerMarker

var player : Player

func set_player_json(var json : Dictionary):
	player = Player.new(json)
	set_player(player)

func set_player(var p_player : Player):
	player = p_player
	set_pos_vec(player.get_map_position())

extends AI
class_name StayCloseToPlayerAI

var follow_threshold_min: float = 20.0
var follow_threshold_max: float = 50.0

## virtual
func get_next_stop() -> Vector2:
	var player_pos = get_tree().get_first_node_in_group("player").global_position
	player_pos += Vector2(randf_range(follow_threshold_min, follow_threshold_max), 0.0)
#	player_pos.y = path.curve.get_point_position(0).y
	var next_stop = path.get_closest_point_to(player_pos)
#	print("player pos: " + str(player_pos))
	return next_stop

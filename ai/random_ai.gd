extends AI
class_name RandomAI

var random_stops_count: int = 3
var current_stops: int = 0

## virtual
func get_next_stop() -> Vector2:
	var next_stop: Vector2 = path.get_random_position()
	if current_stops >= random_stops_count:
		next_stop = path.get_final_position()
	current_stops += 1
	
	return next_stop

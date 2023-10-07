extends AI
class_name StopsInOrderAI

var stop: int = 0

## virtual
func get_next_stop() -> Vector2:
	var next_stop: Vector2
	next_stop = path.get_position_at(stop)
	stop += 1
	return next_stop

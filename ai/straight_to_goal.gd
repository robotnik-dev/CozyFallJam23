extends AI
class_name StraightToGoalAI


func get_next_stop() -> Vector2:
	return path.get_final_position()


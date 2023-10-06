extends Path2D
class_name Path

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

func get_random_position() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position

func get_final_position() -> Vector2:
	return curve.get_point_position(curve.point_count - 1)

extends Path2D
class_name Path

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

func get_random_position() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position

func get_final_position() -> Vector2:
	return curve.get_point_position(curve.point_count - 1)

func get_position_at(idx: int) -> Vector2:
	if idx >= curve.point_count:
		return get_final_position()
	return curve.get_point_position(idx)

func get_closest_point_to(pos: Vector2) -> Vector2:
	return curve.get_closest_point(to_local(pos))

extends Node
class_name AI

@export var curve: Resource

var path: Path

var _reached_threshold: float = 30.0

func setup() -> void:
	path = get_tree().get_first_node_in_group("path")
	path.curve = curve

## virtual
func get_next_stop() -> Vector2:
	return Vector2.ZERO

func is_final_stop(pos: Vector2) -> bool:
	print("animal pos: " + str(pos))
	print("final pos: " + str(path.get_final_position()))
	return abs(pos - path.get_final_position()).x <= _reached_threshold

func _to_string() -> String:
	return "AI"

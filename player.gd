extends CharacterBody2D
class_name PLayer

@export var speed: float = 1000.0
@export var damp: float = 50.0
@export var acceleration: float = 50.0
@export var move_tilt: float = 15.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	var direction = _get_input_direction()
	if abs(direction) > 0:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
		create_tween().tween_property(self, "rotation_degrees", sign(direction) * move_tilt, 0.2)
	else:
		velocity.x = move_toward(velocity.x, 0.0, damp)
		create_tween().tween_property(self, "rotation_degrees", 0.0, 0.2)
	
	velocity.y += gravity * delta
	move_and_slide()

func _get_input_direction() -> float:
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

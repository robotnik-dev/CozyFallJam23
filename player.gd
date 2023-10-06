extends CharacterBody2D
class_name PLayer

@export var speed: float = 1000.0
@export var damp: float = 50.0
@export var acceleration: float = 50.0
@export var move_tilt: float = 15.0
@export var up_speed: float = 15.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _floating: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("float"):
		_floating = true
	elif event.is_action_released("float"):
		_floating = false
	

func _physics_process(delta: float) -> void:
	var direction = _get_input_direction()
	if abs(direction) > 0:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
		create_tween().tween_property(self, "rotation_degrees", sign(direction) * move_tilt, 0.2)
	else:
		velocity.x = move_toward(velocity.x, 0.0, damp)
		create_tween().tween_property(self, "rotation_degrees", 0.0, 0.2)
	
	var float_multiplier = -1.0 if _floating else 1.0
#	velocity.y += gravity * delta * float_multiplier
	velocity.y = move_toward(velocity.y, gravity * float_multiplier, up_speed)
	move_and_slide()

func _get_input_direction() -> float:
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

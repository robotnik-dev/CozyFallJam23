extends CharacterBody2D
class_name Animal

signal goal_reached
signal happiness_changed(value)

@export var speed: float = 500.0
@export var damp: float = 50.0
@export var acceleration: float = 5.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hearts: Node2D = $Hearts

enum State {
	BEFORE_ROOF,
	WAITING_FOR_ESCORT,
	ON_THE_WAY,
	GOAL_REACHED
}

enum Happy {
	VERY,
	OKAY,
	NOT
}

var heart_scene: PackedScene = preload("res://heart.tscn")
var happiness: float = 0.0:
	set(value):
		happiness = clampf(value, 0.0, 100.0)
## between 0.1 and 1.0
var happiness_fill_speed: float = 0.5:
	set(value):
		happiness_fill_speed = clampf(value, 0.1, 1.0)

var ai: AI
var in_rain: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var roof_stop: Vector2
var final_stop: Vector2
var goal_treshold: float = 5.0

var state: State = State.BEFORE_ROOF:
	set(value):
		state = value
		_update_animation()

#func _ready() -> void:
#	goal_pos = get_tree().get_first_node_in_group("main").get_goal_position()
#	navigation_agent_2d.target_position = goal_pos

func setup(_roof_stop: Vector2, _final_stop: Vector2) -> void:
	roof_stop = _roof_stop
	final_stop = _final_stop
	# set first destination
	navigation_agent_2d.target_position = roof_stop
	ai = _get_ai_or_null()
	if ai:
		ai.setup()


func _process(delta: float) -> void:
	if in_rain:
		happiness -= 1.0 * happiness_fill_speed
	else:
		happiness += 1.0 * happiness_fill_speed
	happiness_changed.emit(happiness)

func _physics_process(delta: float) -> void:
#	if not navigation_agent_2d.is_navigation_finished():
	var next_pos = navigation_agent_2d.get_next_path_position()
	velocity.x = (next_pos - global_position).normalized().x * speed
	
	velocity.y += gravity * delta
	move_and_slide()

func _update_animation() -> void:
	match state:
		State.BEFORE_ROOF:
			pass
		State.WAITING_FOR_ESCORT:
			animation_player.play("waiting_for_escort")
		State.ON_THE_WAY:
			animation_player.stop()
		State.GOAL_REACHED:
			_spawn_hearts()
			animation_player.play("goal_reached")

func _get_happiness() -> Happy:
	if happiness >= 80.0:
		return Happy.VERY
	elif happiness >= 40.0:
		return Happy.OKAY
	else:
		return Happy.NOT

func _spawn_hearts() -> void:
	var happy = _get_happiness()
	var num_hearts: int = 1
	match happy:
		Happy.VERY:
			num_hearts = 5
		Happy.OKAY:
			num_hearts = 2
		Happy.NOT:
			pass
	for i in range(num_hearts):
		var heart = heart_scene.instantiate()
		hearts.add_child(heart)
		var rand_x = randf_range(-150, 150)
		create_tween().tween_property(heart, "position", Vector2(rand_x, -136), 1.0)
		create_tween().parallel().tween_property(heart, "modulate", Color(1, 1, 1, 0), 1.0)
	
	Events.hearts_increased.emit(num_hearts)

func _get_ai_or_null() -> AI:
	var ai = null
	for child in get_children():
		if child.to_string() == "AI":
			ai = child
	return ai

## called from animation player "goal_reached"
func _on_goal_reached() -> void:
	goal_reached.emit()
	queue_free()

func _on_navigation_agent_2d_navigation_finished() -> void:
	if state == State.BEFORE_ROOF:
		state = State.WAITING_FOR_ESCORT
#	elif state == State.ON_THE_WAY:
#		if ai.is_final_stop(global_position):
#			state = State.GOAL_REACHED
#			set_physics_process(false)
#		else:
#			navigation_agent_2d.target_position = ai.get_next_stop()


func _on_player_detect_body_entered(body: Node2D) -> void:
	if state == State.WAITING_FOR_ESCORT or state == State.BEFORE_ROOF:
		state = State.ON_THE_WAY
		navigation_agent_2d.target_position = ai.get_next_stop()
		return
	in_rain = false


func _on_player_detect_body_exited(body: Node2D) -> void:
	in_rain = true


func _on_anti_stuck_timer_timeout() -> void:
	if state == State.ON_THE_WAY:
		if not ai.is_final_stop(global_position):
			if navigation_agent_2d.is_navigation_finished():
				navigation_agent_2d.target_position = ai.get_next_stop()
		else:
			state = State.GOAL_REACHED
			set_physics_process(false)

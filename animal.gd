extends CharacterBody2D
class_name Animal

signal goal_reached
signal happiness_changed(value)

@export var speed: float = 500.0
@export var slime_trail_spawn: Node2D
@export var flying: bool = false
@export var water_animal: bool = false
@export var wait_for_escort: bool = true
#@export var slime_trail_spawn_timer: Timer
## every ai that makes sense on this animal
@export var ai_scenes: Array[PackedScene]
## every curve that makes sense
@export var curves: Array[Resource]

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hearts: Node2D = $Hearts
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

enum State {
	BEFORE_ROOF,
	WAITING_FOR_ESCORT,
	ON_THE_WAY,
	FLY,
	STANDING_STILL,
	GOAL_REACHED,
	CELEBRATING
}

enum Happy {
	VERY,
	OKAY,
	NOT
}
var heart_scene: PackedScene = preload("res://heart.tscn")
var slime_trai_scene: PackedScene = preload("res://slime_trail.tscn")
var happiness: float = 100.0:
	set(value):
		happiness = clampf(value, 0.0, 100.0)
## between 0.0 and 1.0
@export var happiness_fill_speed: float = 0.5:
	set(value):
		happiness_fill_speed = clampf(value, 0.0, 1.0)
@export var happiness_drop_speed: float = 0.5:
	set(value):
		happiness_drop_speed = clampf(value, 0.0, 1.0)
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

@onready var default_speed = speed

func _ready() -> void:
	var boring_timer = Timer.new()
	add_child(boring_timer)
	boring_timer.wait_time = 10.0
	boring_timer.timeout.connect(_on_boring_timer_timeout)
	boring_timer.start()
	randomize()
	_update_animation()

func _on_trail_spawn() -> void:
	var trail = slime_trai_scene.instantiate()
	slime_trail_spawn.add_child(trail)
	trail.top_level = true
	trail.global_position = slime_trail_spawn.global_position


func setup(_roof_stop: Vector2, _final_stop: Vector2) -> void:
	roof_stop = _roof_stop
	final_stop = _final_stop
	# set first destination
	navigation_agent_2d.target_position = roof_stop
	_pick_random_ai()
	ai = _get_ai_or_null()
	if ai:
		ai.setup()


func _process(delta: float) -> void:
	var fill_direction = -1.0 if water_animal else 1.0
	if in_rain:
		happiness -= 1.0 * happiness_drop_speed * fill_direction
	else:
		happiness += 1.0 * happiness_fill_speed * fill_direction
	happiness_changed.emit(happiness)

func _physics_process(delta: float) -> void:
	if not navigation_agent_2d.is_navigation_finished():
		var next_pos = navigation_agent_2d.get_next_path_position()
		velocity.x = (next_pos - global_position).normalized().x * speed
		if flying:
			velocity.y = (next_pos - global_position).normalized().y * speed
		else:
			velocity.y += gravity * delta
	else:
		velocity.x = 0.0
	move_and_slide()

func _pick_random_ai() -> void:
	var ai_scene = ai_scenes.pick_random()
	var ai = ai_scene.instantiate()
	add_child(ai)
	var curve = curves.pick_random()
	ai.curve = curve


func _update_animation() -> void:
	match state:
		State.BEFORE_ROOF:
			animation_player.play("walk")
		State.WAITING_FOR_ESCORT:
			animation_player.seek(0)
			animation_player.stop()
			animation_player.play("waiting_for_escort")
		State.ON_THE_WAY:
			animation_player.seek(0)
			animation_player.stop()
			animation_player.play("walk")
		State.STANDING_STILL:
			animation_player.seek(0)
			animation_player.stop()
		State.GOAL_REACHED:
			_spawn_hearts()
			animation_player.seek(0)
			animation_player.stop()
			animation_player.play("goal_reached")
		State.CELEBRATING:
			# tood animation
			animation_player.seek(0)
			animation_player.stop()
			animation_player.play("waiting_for_escort")

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
			num_hearts = 3
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
		if wait_for_escort:
			state = State.WAITING_FOR_ESCORT
		else:
			state = State.ON_THE_WAY
			navigation_agent_2d.target_position = ai.get_next_stop()
			return
	
	elif state == State.ON_THE_WAY:
		speed = default_speed
		if ai.is_final_stop(global_position):
			set_physics_process(false)
			set_process(false)
			audio_stream_player.play()
			await audio_stream_player.finished
			state = State.GOAL_REACHED
		else:
			if is_equal_approx(velocity.x, 0.0):
				state = State.STANDING_STILL
				return
			var next_stop = ai.get_next_stop()
			navigation_agent_2d.target_position = next_stop


func _on_player_detect_body_entered(body: Node2D) -> void:
	if state == State.WAITING_FOR_ESCORT or state == State.BEFORE_ROOF:
		state = State.ON_THE_WAY
		navigation_agent_2d.target_position = ai.get_next_stop()
		return
	in_rain = false


func _on_player_detect_body_exited(body: Node2D) -> void:
	in_rain = true


func _on_anti_stuck_timer_timeout() -> void:
	if state == State.STANDING_STILL:
		# move a little bit
		speed = default_speed / 3
		var offset = 200.0
		var direction = 1.0 if sign(randf_range(-1.0, 1.0)) == 1 else -1.0
		var offset_pos = Vector2(global_position.x + offset * direction, global_position.y)
		navigation_agent_2d.target_position = offset_pos
		state = State.ON_THE_WAY


func _on_boring_timer_timeout() -> void:
	if state == State.WAITING_FOR_ESCORT:
		audio_stream_player.play()

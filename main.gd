extends Node

@export var animal_spawner: AnimalSpawner
@export var ui: CanvasLayer
@export var game_won_spawner: Node2D
@export var points_to_win: int = 35

var game_complete_scene: PackedScene = preload("res://game_complete_screen.tscn")
var game_finished: bool = false

func _ready() -> void:
	animal_spawner.animal_reached_destination.connect(round_start)
	Events.game_complete.connect(_on_game_complete)
	Events.play_again.connect(_on_play_again)
	animal_spawner.setup()
	round_start()

func round_start() -> void:
	if game_finished:
		return
	for child in ui.get_children():
		child.queue_free()
	animal_spawner.spawn_animal()

func _on_game_complete(hearts: int) -> void:
	game_finished = true
	var game_complete = game_complete_scene.instantiate()
	ui.add_child(game_complete)
	# todo let animals hopp
	game_won_spawner.spawn_all_animals()

func _on_play_again() -> void:
	game_finished = false
	get_tree().reload_current_scene()

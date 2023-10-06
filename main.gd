extends Node

@export var animal_spawner: AnimalSpawner

func _ready() -> void:
	animal_spawner.animal_reached_destination.connect(round_start)
	round_start()

func round_start() -> void:
	animal_spawner.spawn_animal()

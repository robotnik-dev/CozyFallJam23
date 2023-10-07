extends Node2D

@export var animal_spawner: AnimalSpawner
@export var path: PathFollow2D


func spawn_all_animals() -> void:
	var animals_scenes = animal_spawner.get_all_animal_scenes()
	var ratio = 0.0
	for scene in animals_scenes:
		var animal: Animal = scene.instantiate()
		add_child(animal)
		animal.state = Animal.State.CELEBRATING
#		animal.global_position.y = path.curve.get_point_position(0).y
		path.progress_ratio = ratio
		animal.global_position = path.global_position
		ratio  += float(animals_scenes.size()) / 10.0

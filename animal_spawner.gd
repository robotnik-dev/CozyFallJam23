extends Marker2D
class_name AnimalSpawner

signal animal_reached_destination

@export var available_animals: Array[PackedScene]
@export var destination: Node2D
@export var roof_stop: Node2D

func spawn_animal(random: bool = true) -> void:
	var animal_scene: PackedScene
	if random:
		animal_scene = available_animals.pick_random()
	else:
		# just the first
		animal_scene = available_animals[0]
	
	var animal: Animal = animal_scene.instantiate()
	add_child(animal)
	animal.setup(roof_stop.global_position, destination.global_position)
	animal.goal_reached.connect(_on_animal_goal_reached)


func _on_animal_goal_reached() -> void:
	animal_reached_destination.emit()

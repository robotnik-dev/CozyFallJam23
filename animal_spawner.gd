extends Marker2D
class_name AnimalSpawner

signal animal_reached_destination
@export var random: bool = true
@export var available_animals: Array[PackedScene]
@export var first_animal: PackedScene
@export var middle_animal: PackedScene
@export var last_animal: PackedScene
## just for unique scenes
@export var destination: Node2D
@export var roof_stop: Node2D


var available_animals_this_run: Array[PackedScene]
var _rng = RandomNumberGenerator.new()

func setup() -> void:
	# shuffle animals
	set_order()
#	if random:
#		shuffle_animals()

func set_order() -> void:
	randomize()
	available_animals.shuffle()
	available_animals.insert(0, first_animal)
	available_animals.append(last_animal)
	available_animals.insert(3, middle_animal)
	available_animals_this_run = available_animals.duplicate(true)

func shuffle_animals() -> void:
	randomize()
	available_animals.shuffle()
	available_animals_this_run = available_animals.duplicate(true)

func spawn_animal() -> void:
	var animal_scene: PackedScene
	if available_animals_this_run.is_empty():
		shuffle_animals()
	
	if random:
		animal_scene = available_animals_this_run.pop_front()
	else:
		# just the first
		animal_scene = available_animals_this_run[0]
	
	var animal: Animal = animal_scene.instantiate()
	add_child(animal)
	animal.setup(roof_stop.global_position, destination.global_position)
	animal.goal_reached.connect(_on_animal_goal_reached)

## unique animal scenes
func get_all_animal_scenes() -> Array[PackedScene]:
#	var anims: Array[PackedScene]
#	for scene in picked_animals_this_run.keys():
#		anims.append(scene)
	return available_animals

func _on_animal_goal_reached() -> void:
	animal_reached_destination.emit()

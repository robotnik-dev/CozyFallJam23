extends ProgressBar

@export var animal: Animal


func _ready() -> void:
	animal.happiness_changed.connect(_on_happiness_changed)

func _on_happiness_changed(happiness: float) -> void:
	value = happiness
	var happy = animal._get_happiness()
	match happy:
		animal.Happy.VERY:
			self_modulate = Color(0.01469646021724, 0.52578055858612, 0.049476608634)
		animal.Happy.OKAY:
			self_modulate = Color(0.61750048398972, 0.35948377847672, 0.10623816400766)
		animal.Happy.NOT:
			self_modulate = Color(0.78289949893951, 0.13546872138977, 0.16901791095734)

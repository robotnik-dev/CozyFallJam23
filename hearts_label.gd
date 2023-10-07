extends Label


func _ready() -> void:
	Events.hearts_increased.connect(_on_hearts_increased)

func _on_hearts_increased(amount: int) -> void:
	text = str(int(text) + amount)
	if int(text) >= get_tree().get_first_node_in_group("main").points_to_win:
		Events.game_complete.emit(int(text))

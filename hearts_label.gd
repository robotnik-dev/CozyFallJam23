extends Label


func _ready() -> void:
	Events.hearts_increased.connect(_on_hearts_increased)

func _on_hearts_increased(amount: int) -> void:
	text = str(int(text) + amount)

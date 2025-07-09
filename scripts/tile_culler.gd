extends VisibleOnScreenNotifier2D

func _process(_delta: float) -> void:
	if is_on_screen():
		$"../CollisionShape2D".disabled = false
		$"../Sprite2D".visible = true
	else:
		$"../CollisionShape2D".disabled = true
		$"../Sprite2D".visible = false

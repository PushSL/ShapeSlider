extends VisibleOnScreenNotifier2D

func _process(_delta: float) -> void:
	if is_on_screen():
		$"../kill".disabled = false
		$"../Sprite2D".visible = true
	else:
		$"../kill".disabled = true
		$"../Sprite2D".visible = false

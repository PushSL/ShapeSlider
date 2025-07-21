extends VisibleOnScreenNotifier2D

func _ready() -> void:
	if not is_on_screen():
		$"../Sprite2D".visible = false

func _on_screen_entered() -> void:
	$"../Sprite2D".visible = true


func _on_screen_exited() -> void:
	$"../Sprite2D".visible = false

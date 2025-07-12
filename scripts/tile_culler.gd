extends VisibleOnScreenNotifier2D

func _ready() -> void:
	if not is_on_screen():
		$"../CollisionShape2D".disabled = true
		$"../Sprite2D".visible = false

func _on_screen_entered() -> void:
	$"../CollisionShape2D".disabled = false
	$"../Sprite2D".visible = true


func _on_screen_exited() -> void:
	$"../CollisionShape2D".disabled = true
	$"../Sprite2D".visible = false

extends VisibleOnScreenNotifier2D

func _ready() -> void:
	if not is_on_screen():
		$"../kill".disabled = true
		$"../Sprite2D".visible = false

func _on_screen_entered() -> void:
	$"../kill".disabled = false
	$"../Sprite2D".visible = true


func _on_screen_exited() -> void:
	$"../kill".disabled = true
	$"../Sprite2D".visible = false

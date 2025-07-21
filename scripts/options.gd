extends GridContainer

func _on_swipe_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$/root/Editor.swipe = true
		$Swipe.theme = load("res://themes/Style_Button_1.tres")
	else:
		$/root/Editor.swipe = false
		$Swipe.theme = load("res://themes/Style_Box_8.tres")

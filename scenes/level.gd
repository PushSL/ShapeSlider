extends Node2D
var ground_color: Color = Color8(0, 255, 102, 255)


func _process(delta: float) -> void:
	$Ground/Control/ColorRect.position.x = $Player.position.x - 700
	$Ground/CollisionShape2D.position.x = $Player.position.x
	$Ground/Control/TextureRect.size.x = $Player.global_position.x + DisplayServer.window_get_size().x + 1000

extends Node2D
var ground_color: Color = Color8(0, 255, 102, 255)
@export var object_data: Array
#For level_data it goes object(int), position.x(float), position.y(float), layer(int)

func _process(_delta: float) -> void:
	$Ground/Control/ColorRect.position.x = $Player.position.x - 700
	$Ground/CollisionShape2D.position.x = $Player.position.x
	$Ground/Control/TextureRect.size.x = $Player.global_position.x + DisplayServer.window_get_size().x + 1000

func _enter_tree() -> void:
	for object in object_data:
		var object_path
		match object.x:
			0.0:
				object_path = load("res://tiles/block_0.tscn").instantiate()
		match object.w:

			4:
				$/T4.add_child(object_path)
			3:
				$/T3.add_child(object_path)
			2:
				$/T2.add_child(object_path)
			1:
				$/T1.add_child(object_path)
			-1:
				$/B1.add_child(object_path)
			-2:
				$/B2.add_child(object_path)
			-3:
				$/B3.add_child(object_path)
			-4:
				$/B4.add_child(object_path)
			_:
				add_child(object_path)

		object_path.position = Vector2(object.y, object.z)
	$Ground/Control/TextureRect.position.x = -1000

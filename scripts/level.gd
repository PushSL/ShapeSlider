extends Node2D
@export var level: Resource
var ground_color: Color = Color8(0, 255, 102, 255)
#For level_data it goes object(int), position.x(float), position.y(float), layer(int)
func load_objects() -> void:
	for object in level.object_data:
		var object_path
		match int(object.x):
			1:
				object_path = load("res://tiles/block_0.tscn").instantiate()
			_:
				object_path  = load("res://tiles/base_block.tscn").instantiate()
		match int(object.w):
			4:
				$T4.add_child(object_path)
			3:
				$T3.add_child(object_path)
			2:
				$T2.add_child(object_path)
			1:
				$T1.add_child(object_path)
			-1:
				$B1.add_child(object_path)
			-2:
				$B2.add_child(object_path)
			-3:
				$B3.add_child(object_path)
			-4:
				$B4.add_child(object_path)
			_:
				add_child(object_path)
		object_path.position = Vector2(object.y, object.z)

func _process(_delta: float) -> void:
	$Ground/Control/ColorRect.position.x = $Player.position.x - 700
	$Ground/CollisionShape2D.position.x = $Player.position.x
	$Ground/Control/TextureRect.size.x = $Player.global_position.x + DisplayServer.window_get_size().x + 1000

func _enter_tree() -> void:
	$Ground/Control/TextureRect.position.x = -1000

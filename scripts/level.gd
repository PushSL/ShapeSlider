extends Node2D
var level: level_data
var ground_color: Color = Color8(0, 255, 102, 255)

func load_data() -> void:
	for object in level.object_data:
		match object.type:
			1:
				object.loaded_object = preload("res://tiles/block_0.tscn").instantiate()
			2:
				object.loaded_object = preload("res://tiles/spike_0.tscn").instantiate()
			_:
				object.loaded_object = preload("res://tiles/base_block.tscn").instantiate()
		match object.layer:
			4:
				$T4.add_child(object.loaded_object)
			3:
				$T3.add_child(object.loaded_object)
			2:
				$T2.add_child(object.loaded_object)
			1:
				$T1.add_child(object.loaded_object)
			-1:
				$B1.add_child(object.loaded_object)
			-2:
				$B2.add_child(object.loaded_object)
			-3:
				$B3.add_child(object.loaded_object)
			-4:
				$B4.add_child(object.loaded_object)
			_:
				object.layer = 1
				$T1.add_child(object.loaded_object)
		object.loaded_object.position = object.position * 9.6

func clear_level():
	for layer in [$T4, $T3, $T2, $T1, $B1, $B2, $B3, $B4]:
		var thread: Thread = Thread.new()
		thread.start(clear_layer.bind(layer.get_children()))

func clear_layer(objects: Array):
	for object in objects:
		object.queue_free()

func _physics_process(_delta: float) -> void:
	$Ground/Control/ColorRect.position.x = $Player.position.x - 700
	$Ground/CollisionShape2D.position.x = $Player.position.x
	$Ground/Control/TextureRect.size.x = $Player.global_position.x + DisplayServer.window_get_size().x + 1000

func _enter_tree() -> void:
	$Ground/Control/TextureRect.position.x = -1000

extends Node2D
var level: level_data
var loaded_object: Array
var ground_color: Color = Color8(0, 255, 102, 255)
var thread: Thread

func load_data() -> void:
	for object in level.object_data:
		var object_path: Node
		match object[0]:
			1:
				object_path = preload("res://tiles/block_0.tscn").instantiate()
			2:
				object_path = preload("res://tiles/spike_0.tscn").instantiate()
			_:
				object_path = preload("res://tiles/base_block.tscn").instantiate()
		match object[2]:
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
		object_path.position = object[1] * 9.6
		loaded_object.insert(loaded_object.size(), object_path)

func clear_level():
	loaded_object.clear()
	var threads: Array
	for layer in [$T4, $T3, $T2, $T1, $B1, $B2, $B3, $B4]:
		var thread: Thread = Thread.new()
		thread.start(clear_layer.bind(layer, layer.get_children()))
		threads.insert(threads.size(), thread)

func clear_layer(layer: Node, objects: Array):
	var now = Time.get_ticks_msec()
	for object in objects:
		object.queue_free()
	print(Time.get_ticks_msec() - now)

func _physics_process(_delta: float) -> void:
	if $Player.alive:
		for object in loaded_object:
			pass
	$Ground/Control/ColorRect.position.x = $Player.position.x - 700
	$Ground/CollisionShape2D.position.x = $Player.position.x
	$Ground/Control/TextureRect.size.x = $Player.global_position.x + DisplayServer.window_get_size().x + 1000

func _enter_tree() -> void:
	$Ground/Control/TextureRect.position.x = -1000

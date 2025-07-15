extends Control
@onready var level_path: Array = $/root/ShapeSlider/UI/Menu.level_path
@onready var current_level: int = $/root/ShapeSlider/UI/Menu.current_level
@onready var level: level_data = load(level_path[current_level])
var drag_start_camera_position: Vector2
var drag_start_cursor_position: Vector2
var selected_object: int = 1

func _ready() -> void:
	load_data()
	modulate.a = 0
	Engine.physics_ticks_per_second = 1	

func _process(delta: float) -> void:
	if Input.is_action_just_released("left_click") and (abs(drag_start_cursor_position.x - get_viewport().get_mouse_position().x) < 6 or abs(drag_start_cursor_position.y - get_viewport().get_mouse_position().y) < 6) or Input.is_action_pressed("left_click") and Input.is_action_pressed("swipe"):
		var place: bool = true
		if level.object_data.size() != 0:
			for object in level.object_data:
				if object[1] == (((get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6)) / 10).round() * 10 and object[0] == selected_object:
					place = false
		else:
			place = true
		if place == true:
			place_tile(selected_object, (get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6), 1)
			save()

	if Input.is_action_pressed("right_click") and Input.is_action_pressed("swipe") or Input.is_action_just_released("right_click"):
		delete_tile((get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6))
		clear_level()
		load_data()

	if not Input.is_action_pressed("swipe"):
		camera()

func save() -> void:
	var data := level_data.new()
	data.object_data = level.object_data
	data.song_path = level.song_path
	data.level_name = level.level_name
	data.level_id = level.level_id
	data.easy_best = level.easy_best
	data.hard_best = level.hard_best
	var error := ResourceSaver.save(data, level_path[current_level])
	if error:
		print("An error happened while saving data: ", error)

func camera():
	if Input.is_action_just_pressed("left_click"):
		drag_start_cursor_position = get_viewport().get_mouse_position()
		drag_start_camera_position = $Camera.position
	if Input.is_action_pressed("left_click") and (abs(drag_start_cursor_position.x - get_viewport().get_mouse_position().x) > 6 or abs(drag_start_cursor_position.y - get_viewport().get_mouse_position().y) > 6):
		$Camera.position = drag_start_camera_position + (drag_start_cursor_position - get_viewport().get_mouse_position()) / $Camera.zoom.x
	if Input.is_action_just_pressed("zoom_in"):
		$Camera.zoom *= Vector2(1.25, 1.25)
	if Input.is_action_just_pressed("zoom_out"):
		$Camera.zoom /= Vector2(1.25, 1.25)


func place_tile(type: int, position: Vector2, layer: int, snap: int = 10) -> void:
	level.object_data.insert(level.object_data.size(),[type, round(position / snap) * snap,layer])
	var object_path: Node
	match type:
		1:
			object_path = preload("res://tiles/block_0.tscn").instantiate()
		2:
			object_path = preload("res://tiles/spike_0.tscn").instantiate()
		_:
			object_path = preload("res://tiles/base_block.tscn").instantiate()
	match layer:
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
	object_path.position = round(position / snap) * snap * 9.6


func delete_tile(position: Vector2 = Vector2.ZERO, snap: int = 10) -> void:
	position = (position / snap).round() * snap
	for object in level.object_data:
		if position == object[1]:
			level.object_data.remove_at(level.object_data.find(object))
			break
	save()
	

func clear_level():
	for layer in [$T4, $T3, $T2, $T1, $B1, $B2, $B3, $B4]:
		for object in layer.get_children():
			layer.remove_child(object)
			object.queue_free() 

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

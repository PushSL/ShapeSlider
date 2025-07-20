extends Control
@onready var level_path: Array = $/root/ShapeSlider/UI/Menu.level_path
@onready var current_level: int = $/root/ShapeSlider/UI/Menu.current_level
@onready var level: level_data = load(level_path[current_level])
@onready var stored_level: level_data = level
var drag_start_camera_position: Vector2
var drag_start_cursor_position: Vector2
var selected_object: int = 1
var block_input: bool = false

func _ready() -> void:
	load_data()
	$UI/Menu/Label.text = level.level_name
	modulate.a = 0
	Engine.physics_ticks_per_second = 1

func _process(_delta: float) -> void:
	var camera_rect = Rect2(
		$Camera.global_position - get_viewport_rect().size / 2 / $Camera.zoom,
		get_viewport_rect().size / $Camera.zoom)
	for object in level.object_data:
		if object.loaded_object:
			var object_position = object.loaded_object.global_position
			var object_size = object.loaded_object.get_rect().size if object.loaded_object.has_method("get_rect") else Vector2(128 * object.loaded_object.scale.x, 128 * object.loaded_object.scale.y)  # Fallback
			var object_rect = Rect2(object_position - object_size / 2, object_size)
			object.loaded_object.visible = camera_rect.intersects(object_rect)
	if Input.is_action_just_pressed("exit"):
		_on_menu_button_pressed()
	if block_input == false:
		if Input.is_action_just_released("left_click") and (abs(drag_start_cursor_position.x - get_viewport().get_mouse_position().x) < 6 or abs(drag_start_cursor_position.y - get_viewport().get_mouse_position().y) < 6) or Input.is_action_pressed("left_click") and Input.is_action_pressed("swipe"):
			var place: bool = true
			if level.object_data.size() != 0:
				var position: Vector2 = ((get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6) / 10).round() * 10 
				for object in level.object_data:
					if object.position == position and object.type == selected_object:
						place = false
						break
			else:
				place = true
			if place == true:
				place_tile(selected_object, (get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6), 1)
		if Input.is_action_pressed("right_click") and Input.is_action_pressed("swipe") or Input.is_action_just_released("right_click"):
			delete_tile((get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6))
		if not Input.is_action_pressed("swipe"):
			camera()
		else:
			drag_start_cursor_position = get_viewport().get_mouse_position()

func save() -> void:
	var data := level_data.new()
	data.object_data = level.object_data
	data.song_path = level.song_path
	data.level_name = level.level_name
	data.level_id = level.level_id
	data.easy_best = level.easy_best
	data.hard_best = level.hard_best
	var error := ResourceSaver.save(data, level_path[current_level], ResourceSaver.FLAG_COMPRESS)
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
	var object = object.new()
	object.type = type
	object.position = round(position / snap) * snap
	object.layer = layer
	level.object_data.append(object)
	match type:
		1:
			object.loaded_object = preload("res://tiles/block_0.tscn").instantiate()
		2:
			object.loaded_object = preload("res://tiles/spike_0.tscn").instantiate()
		_:
			object.loaded_object = preload("res://tiles/base_block.tscn").instantiate()
	match layer:
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
			$T1.add_child(object.loaded_object)
	object.loaded_object.get_child(0).queue_free()
	object.loaded_object.position = object.position * 9.6

func delete_tile(position: Vector2 = Vector2.ZERO, snap: int = 10) -> void:
	position = (position / snap).round() * snap
	for object in level.object_data:
		if object.position == position:
			object.loaded_object.queue_free()
			level.object_data.remove_at(level.object_data.find(object))
			break


func clear_level():
	var threads: Array
	for layer in [$T4, $T3, $T2, $T1, $B1, $B2, $B3, $B4]:
		var thread: Thread = Thread.new()
		thread.start(clear_layer.bind(layer.get_children()))
		threads.insert(threads.size(), thread)
		thread.wait_to_finish()

func clear_layer(objects: Array):
	for object in objects:
		object.queue_free()

func load_data() -> void:
	level = level_data.new()
	level = stored_level
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
		object.loaded_object.get_child(0).queue_free()
		object.loaded_object.position = object.position * 9.6


func _on_save_pressed() -> void:
	save()


func _on_load_pressed() -> void:
	clear_level()
	load_data()


func _on_mouse_entered() -> void:
	block_input = true


func _on_mouse_exited() -> void:
	if not $UI/Menu.visible:
		drag_start_cursor_position = get_viewport().get_mouse_position()
		drag_start_camera_position = $Camera.position
		block_input = false


func _on_menu_button_pressed() -> void:
	if $UI/Menu.visible:
		$UI/Menu.visible = false
		block_input = false
	else:
		$UI/Menu.visible = true
		block_input = true


func _on_exit_pressed() -> void:
	queue_free()
	Engine.physics_ticks_per_second = 240
	$/root/ShapeSlider/UI/Menu.scene = "main_menu"
	$/root/ShapeSlider/UI/Menu.visible = true
	$/root/ShapeSlider/UI/Menu.modulate.a = 1

func is_in_position(position: Vector2):
	var target_position = position
	if position == target_position:
		return true
	else:
		return false

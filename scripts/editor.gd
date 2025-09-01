extends Control
@onready var level_path: Array = $/root/ShapeSlider/UI/Menu.level_path
@onready var current_level: int = $/root/ShapeSlider/UI/Menu.current_level
@onready var level: level_data = load(level_path[current_level])
@onready var stored_level: level_data = level
@onready var object_map: Array = $/root/ShapeSlider/UI/Menu.object_map
var deletion_queue: Array
var camera_rect: Rect2
var last_place: Vector2
var drag_start_camera_position: Vector2
var drag_start_cursor_position: Vector2
var selected_object: int = 1
var block_input: bool = false
var swipe: bool = false

func _ready() -> void:
	load_data()
	$UI/Menu/Label.text = level.level_name
	modulate.a = 0
	Engine.physics_ticks_per_second = 1


func _process(_delta: float) -> void:
	if Input.is_action_just_released("swipe"):
		_deferred()
	if Input.is_action_just_pressed("exit"):
		_on_menu_button_pressed()
	if block_input == false:
		if Input.is_action_just_released("left_click") and (abs(drag_start_cursor_position.x - get_viewport().get_mouse_position().x) < 6 or abs(drag_start_cursor_position.y - get_viewport().get_mouse_position().y) < 6) or Input.is_action_pressed("left_click") and (Input.is_action_pressed("swipe") or swipe):
			var place: bool = true
			if level.object_data.size() != 0:
				var position: Vector2 = ((get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6) / 10).round() * 10 
				var now: int = Time.get_ticks_msec()
				#place = !find_object(position, selected_object)
				for object in level.object_data:
					if object.position == position and object.type == selected_object:
						place = false
						break
				print(Time.get_ticks_msec() - now)
			else:
				place = true
			if place == true:
				place_tile(selected_object, (get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6), 1)

		if Input.is_action_pressed("right_click") and (Input.is_action_pressed("swipe") or swipe) or Input.is_action_just_released("right_click"):
			delete_tile((get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6))
	if Input.is_action_just_released("swipe"):
		drag_start_cursor_position = get_viewport().get_mouse_position()
		drag_start_camera_position = $Camera.position
	camera()

func save() -> void:
	var data := level_data.new()
	data.object_data = level.object_data
	data.song_path = level.song_path
	data.level_name = level.level_name
	data.level_id = level.level_id
	data.easy_best = level.easy_best
	data.hard_best = level.hard_best
	for object in level.object_data:
		if object.position.x > data.level_length:
			data.level_length = object.position.x
	var error := ResourceSaver.save(data, level_path[current_level], ResourceSaver.FLAG_COMPRESS)
	if error:
		print("An error happened while saving data: ", error)

func camera():
	if not Input.is_action_pressed("swipe") and !swipe:
		if Input.is_action_just_pressed("left_click"):
			drag_start_cursor_position = get_viewport().get_mouse_position()
			drag_start_camera_position = $Camera.position
		if Input.is_action_pressed("left_click") and (abs(drag_start_cursor_position.x - get_viewport().get_mouse_position().x) > 6 or abs(drag_start_cursor_position.y - get_viewport().get_mouse_position().y) > 6):
			$Camera.position = drag_start_camera_position + (drag_start_cursor_position - get_viewport().get_mouse_position()) / $Camera.zoom.x
			update_culler()
		else:
			drag_start_cursor_position = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("zoom_in"):
		$Camera.zoom *= Vector2(1.25, 1.25)
		update_culler()
	if Input.is_action_just_pressed("zoom_out"):
		$Camera.zoom /= Vector2(1.25, 1.25)
		update_culler()

func place_tile(type: int, position: Vector2, layer: int, snap: int = 10) -> void:
	var object = object.new()
	object.type = type
	object.position = round(position / snap) * snap
	object.layer = layer
	var i: int = level.object_data.size() - 1
	while i >= 0 and level.object_data[i].position > object.position:
		i -= 1
	level.object_data.insert(i + 1, object)
	object.loaded_object = load(object_map[type]).instantiate()
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
	object.loaded_object.position = object.position * 9.6
	deletion_queue.append(object.loaded_object.get_child(0))
	if not Input.is_action_just_pressed("swipe"):
		_deferred()

func delete_tile(position: Vector2 = Vector2.ZERO, snap: int = 10) -> void:
	position = (position / snap).round() * snap
	var index: int
	for object in level.object_data:
		if object.position == position:
			deletion_queue.append(object.loaded_object)
			object.loaded_object.visible = false
			level.object_data.remove_at(index)
			break
		index += 1


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
		object.loaded_object = load(object_map[object.type]).instantiate()
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
		object.loaded_object.get_child(0).queue_free()
	update_culler()


func _on_save_pressed() -> void:
	save()


func _on_load_pressed() -> void:
	clear_level()
	load_data()


func _on_mouse_entered() -> void:
	block_input = true

func update_culler(option: String = "all"):
	if option == "all" or option == "camera":
		camera_rect = Rect2($Camera.global_position - get_viewport_rect().size / 2 / $Camera.zoom, get_viewport_rect().size / $Camera.zoom)
	if option == "all" or option == "objects":
		for object in level.object_data:
			var object_size = Vector2(128 * object.loaded_object.scale.x, 128 * object.loaded_object.scale.y)  # Fallback
			object.rect = Rect2(object.loaded_object.global_position - object_size / 2, object_size)
			object.loaded_object.visible = camera_rect.intersects(object.rect)

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

func _deferred():
	for object in deletion_queue:
		object.call_deferred("queue_free")
	deletion_queue.clear()

func lexicographically_sort(a, b):
	if a.position.x == b.position.x:
		return a.position.y < b.position.y
	return a.position.x < b.position.x

func find_object(position: Vector2, type: int) -> bool:
	var left: int = 0
	var right: int = level.object_data.size() - 1
	while left <= right:
		var mid = (left + right) / 2
		var object = level.object_data[mid]
		if object.position == position:
			return object.type == type
		elif object.position < position:
			left = mid + 1
		else:
			right = mid - 1
	return false

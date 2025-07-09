extends Control
@onready var level_path: Array = $/root/ShapeSlider/UI/Menu.level_path
@onready var current_level: int = $/root/ShapeSlider/UI/Menu.current_level
@onready var level: level_data = load(level_path[current_level])
var move: Vector2

func _ready() -> void:
	load_data()
	modulate.a = 0
	Engine.physics_ticks_per_second = 1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		place_tile(2, (get_global_mouse_position() - Vector2(DisplayServer.window_get_size()) / Vector2(2, 2)) / Vector2(9.6, 9.6), 1)
		save()
	
	
	if Input.is_action_just_pressed("move"):
		move = $Camera.position - get_local_mouse_position()
	
	if Input.is_action_pressed("move"):
		$Camera.position = (move - get_local_mouse_position()) * -1

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


func delete_tile(index: int) -> void:
	level.object_data.remove_at(index)
	
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

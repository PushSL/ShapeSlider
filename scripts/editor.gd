extends Control
@onready var level_path: Array = $/root/ShapeSlider/UI/Menu.level_path
@onready var current_level: int = $/root/ShapeSlider/UI/Menu.current_level
@onready var object_data: Array = load(level_path[current_level]).object_data

func _ready() -> void:
	modulate.a = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		place_tile(1, Vector2(100,0), 1)
		#delete_tile(object_data.size() - 1)

#func save() -> void:
	

func place_tile(type: int, position: Vector2, layer: int) -> void:
	print("\nBefore: ",object_data)
	object_data.insert(object_data.size(),[type,position,layer])
	print("After: ",object_data)

func delete_tile(index: int) -> void:
	print("Before: ",object_data)
	object_data.remove_at(index)
	print("After: ",object_data)

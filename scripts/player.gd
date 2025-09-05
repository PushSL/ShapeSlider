extends CharacterBody2D
const JUMP_VELOCITY: int = -1850
var alive: bool = true
var gamemode: String = "cube"
var position_x: float = 0
var camera_rect: Rect2
var datalock: bool = false
func _physics_process(delta: float) -> void:
	if $"/root/ShapeSlider/UI/Pause Menu".visible == false:
		if Input.is_action_just_pressed("reset"):
			kill(0)
		if alive:
			match gamemode:
				"cube": cube(delta)
				"ship": ship(delta)
				"ufo": ufo(delta)
			move_and_slide()
			position_x += 4.275
			position.x = position_x

func update_culler(option: String = "all", safe_mode: bool = true, range: Array = []):
	if option == "all" or option == "camera":
		camera_rect = Rect2($Sprite/Camera2D.global_position + $Sprite/Camera2D.offset - Vector2(96, 96) - get_viewport_rect().size / 2 / $Sprite/Camera2D.zoom, get_viewport_rect().size + Vector2(96, 96) / $Sprite/Camera2D.zoom)
	if safe_mode and option == "all" or option == "objects":
		if range.is_empty():
			for object in $/root/Level.level.object_data:
				if object.loaded_object:
					var object_size = Vector2(128 * object.loaded_object.scale.x, 128 * object.loaded_object.scale.y)
					object.rect = Rect2(object.loaded_object.global_position - object_size / 2, object_size)
					object.loaded_object.visible = camera_rect.intersects(object.rect)
					object.loaded_object.get_child(0).disabled = not object.loaded_object.visible
		else:
			for index in range:
				var object = $/root/Level.level.object_data[index]
				if object.loaded_object:
					var object_size = Vector2(128 * object.loaded_object.scale.x, 128 * object.loaded_object.scale.y)
					object.rect = Rect2(object.loaded_object.global_position - object_size / 2, object_size)
					object.loaded_object.visible = camera_rect.intersects(object.rect)
					object.loaded_object.get_child(0).disabled = not object.loaded_object.visible
	elif option == "all" or option == "objects":
		if range.is_empty():
			for object in $/root/Level.level.object_data:
				var object_size = Vector2(128 * object.loaded_object.scale.x, 128 * object.loaded_object.scale.y)
				object.rect = Rect2(object.loaded_object.global_position - object_size / 2, object_size)
				object.loaded_object.visible = camera_rect.intersects(object.rect)
				object.loaded_object.get_child(0).disabled = not object.loaded_object.visible
		else:
			for index in range:
				var object = $/root/Level.level.object_data[index]
				var object_size = Vector2(128 * object.loaded_object.scale.x, 128 * object.loaded_object.scale.y)
				object.rect = Rect2(object.loaded_object.global_position - object_size / 2, object_size)
				object.loaded_object.visible = camera_rect.intersects(object.rect)
				object.loaded_object.get_child(0).disabled = not object.loaded_object.visible

func uncull():
	for object in $/root/Level.level.object_data:
		if object.loaded_object:
			object.loaded_object.visible = true
			object.loaded_object.get_child(0).disabled = false

func cube(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if velocity.y == 0:
		$Sprite.rotation_degrees = ($Sprite.rotation_degrees + round($Sprite.rotation_degrees / 90) * 90) / 2
	else:
		$Sprite.rotate(7 * delta)
	
	if Input.is_action_pressed("jump") and velocity.y == 0:
		velocity.y = JUMP_VELOCITY
		
	if velocity.y > 5000:
			velocity.y = 5000
		
func ship(delta: float) -> void:
	if is_on_wall():
		kill()
	if is_on_floor() or is_on_ceiling():
		#velocity.y /= 2 * delta
		$Sprite.rotation_degrees = ($Sprite.rotation_degrees + round($Sprite.rotation_degrees / 90) * 90) / 18
	
	if Input.is_action_pressed("jump"):
		$Sprite.rotation_degrees -= 135 * delta
	else:
		$Sprite.rotation_degrees += 135 * delta
		
		
	if $Sprite.rotation_degrees > 45:
			$Sprite.rotation_degrees = 45
	
	if $Sprite.rotation_degrees < -45:
			$Sprite.rotation_degrees = -45
		
	velocity = $Sprite.transform.x * 500
	velocity.x = 0
		
	if velocity.y > 750:
			velocity.y = 750
	
	if velocity.y < -750:
			velocity.y = -750
			
func ufo(_delta: float) -> void:
	if is_on_wall():
		kill()
		
	velocity.y += 50

	if Input.is_action_just_pressed("jump"):
		velocity.y = -1000
		
	if velocity.y > 900:
			velocity.y = 900

func kill(time = 0.5, start_delay = 0.1):
	if alive:
		alive = false
		datalock = true
		$CollisionShape2D.disabled = true
		$/root/Level/Song.playing = false
		if time != 0:
			$Explode.play()
			await get_tree().create_timer(time).timeout
		position = Vector2.ZERO
		datalock = false
		await $/root/Level.clear_level().finished()
		$/root/Level.load_data()
		$Sprite.rotation_degrees = 0
		position_x = 0
		velocity = Vector2.ZERO
		$Sprite/Camera2D.position_smoothing_enabled = false
		$Sprite/Camera2D.drag_vertical_enabled = false
		await get_tree().process_frame
		$Sprite/Camera2D.position_smoothing_enabled = true
		$Sprite/Camera2D.drag_vertical_enabled = true
		await get_tree().create_timer(start_delay).timeout
		alive = true
		$CollisionShape2D.disabled = false
		$/root/Level/Song.playing = true



func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_child(0, false).name == "kill":
		kill()


func _on_deathbox_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	kill()

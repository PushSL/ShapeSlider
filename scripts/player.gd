extends CharacterBody2D
const JUMP_VELOCITY = -1900

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		kill(0)
	if velocity.y > 5000:
		velocity.y = 5000
	position.x += 937 * delta
	if not is_on_floor():
		velocity += get_gravity() * delta
		$Sprite.rotate(6.5 * delta)
	else:
		$Sprite.rotation_degrees = ($Sprite.rotation_degrees + round($Sprite.rotation_degrees / 90) * 90) / 2
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move_and_slide()

func kill(time = 0.75):
	if get_tree().paused == false:
		$Camera2D.position_smoothing_enabled = false
		get_tree().paused = true
		if time != 0:
			await get_tree().create_timer(time).timeout
		$Sprite.rotation_degrees = 0
		position = Vector2(48, -48)
		velocity = Vector2.ZERO
		get_tree().reload_current_scene()
		$Camera2D.position_smoothing_enabled = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Spike":
		kill()

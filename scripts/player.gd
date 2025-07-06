extends CharacterBody2D
const JUMP_VELOCITY = -1850
var alive: bool = true


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		kill(0)
	if alive:
		if velocity.y > 5000:
			velocity.y = 5000
		if is_on_wall() or is_on_ceiling():
			kill()
		position.x += 937 * delta
		if not is_on_floor():
			velocity += get_gravity() * delta
			$Sprite.rotate(6.5 * delta)
		else:
			$Sprite.rotation_degrees = ($Sprite.rotation_degrees + round($Sprite.rotation_degrees / 90) * 90) / 2
			
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		move_and_slide()

func kill(time = 0.75, start_delay = 0.25):
	if alive:
		alive = false
		$CollisionShape2D.disabled = true
		$/root/Level/Song.stop()
		if time != 0:
			$Explode.play()
			await get_tree().create_timer(time).timeout
		$Sprite.rotation_degrees = 0
		position = Vector2(48, -48)
		velocity = Vector2.ZERO
		$Camera2D.position_smoothing_enabled = false
		await get_tree().create_timer(0).timeout
		$Camera2D.position_smoothing_enabled = true
		await get_tree().create_timer(start_delay).timeout
		$CollisionShape2D.disabled = false
		$/root/Level/Song.play()
		alive = true


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Spike":
		kill()

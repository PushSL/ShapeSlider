extends CharacterBody2D
const JUMP_VELOCITY = -1850
var alive: bool = true
var gamemode: String = "ship"

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		kill(0)
	if alive:
		match gamemode:
			"cube": cube(delta)
			"ship": ship(delta)

		position.x += 975 * delta
		move_and_slide()
	
func cube(delta: float) -> void:
	if is_on_wall() or is_on_ceiling():
		kill()

	if not is_on_floor():
		velocity += get_gravity() * delta
		$Sprite.rotate(6.5 * delta)
	else:
		$Sprite.rotation_degrees = ($Sprite.rotation_degrees + round($Sprite.rotation_degrees / 90) * 90) / 2
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if velocity.y > 5000:
			velocity.y = 5000
		
func ship(delta: float) -> void:
	
	if is_on_wall():
		kill()
		
	if is_on_floor() or is_on_ceiling():
		velocity.y /= 2 * delta
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
		$Sprite/Camera2D.position_smoothing_enabled = false
		$Sprite/Camera2D.drag_vertical_enabled = false
		await get_tree().create_timer(0).timeout
		$Sprite/Camera2D.position_smoothing_enabled = true
		$Sprite/Camera2D.drag_vertical_enabled = true
		await get_tree().create_timer(start_delay).timeout
		$CollisionShape2D.disabled = false
		$/root/Level/Song.play()
		alive = true


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Spike":
		kill()

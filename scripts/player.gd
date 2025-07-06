extends CharacterBody2D
const JUMP_VELOCITY = -1900

func _physics_process(delta: float) -> void:
	if $"../../UI/Menu".scene == "gameplay":
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

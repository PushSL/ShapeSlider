extends CharacterBody2D

const JUMP_VELOCITY = -1900
var dead: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		kill(0)
	if velocity.y > 5000:
		velocity.y = 5000
	
	if !dead:
		velocity.x = 937
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		$Sprite.rotate(6.5 * delta)
	else:
		$Sprite.rotation_degrees = ($Sprite.rotation_degrees + round($Sprite.rotation_degrees / 90) * 90) / 2
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move_and_slide()

func kill(time = 0.75):
	dead = true
	await get_tree().create_timer(time).timeout
	$Sprite/Camera2D.position_smoothing_enabled = false
	position = Vector2(48, -48)
	velocity = Vector2.ZERO
	$Sprite.rotation_degrees = 0
	dead = false
	$Sprite/Camera2D.position_smoothing_enabled = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Spike":
		kill()

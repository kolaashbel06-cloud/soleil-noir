extends KinematicBody

var joystick = null
var speed := 7.0
var velocity := Vector3.ZERO
const GRAVITY := 25.0


func _physics_process(delta):
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if joystick != null and joystick.output.length() > 0.1:
		dir = joystick.output

	if dir.length() > 1.0:
		dir = dir.normalized()

	velocity.x = dir.x * speed
	velocity.z = dir.y * speed
	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= GRAVITY * delta

	velocity = move_and_slide(velocity, Vector3.UP)

	# Tourner le personnage vers la direction de déplacement (avant = -Z)
	if dir.length() > 0.1:
		var target_angle := atan2(-dir.x, -dir.y)
		rotation.y = lerp_angle(rotation.y, target_angle, min(1.0, delta * 12.0))

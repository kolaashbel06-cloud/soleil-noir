extends KinematicBody
# Joueur : humain low-poly, déplacement, coup, esquive, points de vie.

signal died

const SPEED := 7.0
const GRAVITY := 25.0
const ATTACK_TIME := 0.35
const ATTACK_HIT_AT := 0.15   # le coup touche 0,15 s après le début de l'animation
const ATTACK_RANGE := 2.4
const ATTACK_DAMAGE := 25.0
const DODGE_TIME := 0.28
const DODGE_SPEED := 17.0
const DODGE_COOLDOWN := 0.9
const SPAWN_POINT := Vector3(0.0, 1.0, 0.0)

var joystick = null
var max_hp := 100.0
var hp := 100.0
var dead := false
var dodge_cd := 0.0

var human
var velocity := Vector3.ZERO
var last_dir := Vector2(0.0, -1.0)

var _attack_t := 0.0
var _attack_hit_done := true
var _dodge_t := 0.0
var _dodge_dir := Vector3.ZERO
var _invuln := 0.0
var _knock := Vector3.ZERO
var _respawn_t := 0.0


func _ready():
	add_to_group("player")

	var cs := CollisionShape.new()
	var shape := BoxShape.new()
	shape.extents = Vector3(0.4, 0.9, 0.4)
	cs.shape = shape
	add_child(cs)

	human = Spatial.new()
	human.set_script(load("res://Humanoid.gd"))
	human.shirt_color = Color(0.9, 0.3, 0.2)
	human.pants_color = Color(0.2, 0.3, 0.6)
	human.translation = Vector3(0.0, -0.9, 0.0)
	add_child(human)


func _read_direction() -> Vector2:
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if joystick != null and joystick.output.length() > 0.1:
		dir = joystick.output
	if dir.length() > 1.0:
		dir = dir.normalized()
	return dir


func _face(dir2: Vector2, delta: float, rate: float):
	rotation.y = lerp_angle(rotation.y, atan2(-dir2.x, -dir2.y), min(1.0, delta * rate))


func _physics_process(delta):
	if dead:
		_respawn_t -= delta
		if _respawn_t <= 0.0:
			_respawn()
		return

	_attack_t = max(0.0, _attack_t - delta)
	dodge_cd = max(0.0, dodge_cd - delta)
	_invuln = max(0.0, _invuln - delta)

	var dir := _read_direction()
	if dir.length() > 0.1:
		last_dir = dir.normalized()

	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("dodge"):
		dodge()

	var horizontal := Vector3.ZERO
	if _dodge_t > 0.0:
		_dodge_t -= delta
		horizontal = _dodge_dir * DODGE_SPEED
	else:
		horizontal = Vector3(dir.x, 0.0, dir.y) * SPEED
		if _attack_t > 0.0:
			horizontal *= 0.35
	horizontal += _knock
	_knock = _knock.linear_interpolate(Vector3.ZERO, min(1.0, delta * 8.0))

	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= GRAVITY * delta
	velocity = move_and_slide(velocity, Vector3.UP)

	# Orientation
	if _dodge_t > 0.0:
		_face(Vector2(_dodge_dir.x, _dodge_dir.z), delta, 20.0)
	elif _attack_t <= 0.0 and dir.length() > 0.1:
		_face(dir, delta, 12.0)

	# Le coup touche au bon moment de l'animation
	if _attack_t > 0.0 and not _attack_hit_done and (ATTACK_TIME - _attack_t) >= ATTACK_HIT_AT:
		_do_hit()

	human.speed_factor = Vector2(velocity.x, velocity.z).length() / SPEED


func _nearest_enemy(max_dist):
	var best = null
	var best_d = max_dist
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d = e.global_transform.origin.distance_to(global_transform.origin)
		if d < best_d:
			best_d = d
			best = e
	return best


func attack():
	if dead or _attack_t > 0.0 or _dodge_t > 0.0:
		return
	_attack_t = ATTACK_TIME
	_attack_hit_done = false
	# Aide à la visée : on se tourne vers l'ennemi le plus proche
	var target = _nearest_enemy(4.0)
	if target != null:
		var to = target.global_transform.origin - global_transform.origin
		rotation.y = atan2(-to.x, -to.z)
	human.play_attack(ATTACK_TIME)


func _do_hit():
	_attack_hit_done = true
	var fwd = -global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var to = e.global_transform.origin - global_transform.origin
		to.y = 0.0
		var dist = to.length()
		if dist <= ATTACK_RANGE and (dist < 0.8 or fwd.dot(to.normalized()) > 0.2):
			e.take_damage(ATTACK_DAMAGE, global_transform.origin)


func dodge():
	if dead or _dodge_t > 0.0 or dodge_cd > 0.0:
		return
	var d = Vector3.ZERO
	var cur := _read_direction()
	if cur.length() > 0.1:
		d = Vector3(cur.x, 0.0, cur.y)
	else:
		d = -global_transform.basis.z
		d.y = 0.0
	_dodge_dir = d.normalized()
	_dodge_t = DODGE_TIME
	dodge_cd = DODGE_COOLDOWN
	_invuln = DODGE_TIME + 0.08   # invulnérable pendant l'esquive
	_attack_t = 0.0


func take_damage(amount: float, from_pos: Vector3):
	if dead or _invuln > 0.0:
		return
	hp -= amount
	_invuln = 0.35
	var away = global_transform.origin - from_pos
	away.y = 0.0
	if away.length() > 0.01:
		_knock = away.normalized() * 6.0
	human.flash(Color(1.0, 0.2, 0.2), 0.15)
	if hp <= 0.0:
		_die()


func _die():
	dead = true
	hp = 0.0
	_respawn_t = 2.5
	human.set_fallen(true)
	emit_signal("died")


func _respawn():
	translation = SPAWN_POINT
	velocity = Vector3.ZERO
	_knock = Vector3.ZERO
	hp = max_hp
	dead = false
	_invuln = 1.5
	human.set_fallen(false)

extends KinematicBody
# Ennemi : humain low-poly qui te poursuit, arme son coup (flash jaune) puis frappe.
# Astuce : esquive au moment du flash jaune pour ne pas être touché.

const SPEED := 3.6
const GRAVITY := 25.0
const DETECT := 22.0
const ATTACK_RANGE := 1.7
const ATTACK_DAMAGE := 12.0
const WINDUP := 0.5
const ATTACK_COOLDOWN := 1.4

var main_ref = null
var max_hp := 50.0
var hp := 50.0
var dead := false

var human
var velocity := Vector3.ZERO
var _player = null
var _knock := Vector3.ZERO
var _stun := 0.0
var _cd := 0.8
var _windup_t := 0.0
var _dead_t := 2.5


func _ready():
	add_to_group("enemies")

	var cs := CollisionShape.new()
	var shape := BoxShape.new()
	shape.extents = Vector3(0.4, 0.9, 0.4)
	cs.shape = shape
	add_child(cs)

	human = Spatial.new()
	human.set_script(load("res://Humanoid.gd"))
	human.shirt_color = Color.from_hsv(rand_range(0.7, 0.95), 0.55, 0.45)
	human.pants_color = Color(0.15, 0.15, 0.18)
	human.hair_color = Color(0.05, 0.05, 0.05)
	human.translation = Vector3(0.0, -0.9, 0.0)
	add_child(human)


func _get_player():
	if _player == null or not is_instance_valid(_player):
		var l = get_tree().get_nodes_in_group("player")
		if l.size() > 0:
			_player = l[0]
		else:
			_player = null
	return _player


func _face(v: Vector3, delta: float):
	rotation.y = lerp_angle(rotation.y, atan2(-v.x, -v.z), min(1.0, delta * 10.0))


func _physics_process(delta):
	if dead:
		_dead_t -= delta
		if _dead_t <= 0.0:
			queue_free()
		return

	_stun = max(0.0, _stun - delta)
	_cd = max(0.0, _cd - delta)

	var move := Vector3.ZERO
	var p = _get_player()
	if p != null and not p.dead:
		var to = p.global_transform.origin - global_transform.origin
		to.y = 0.0
		var dist = to.length()
		if _windup_t > 0.0:
			_face(to, delta)
			_windup_t -= delta
			if _windup_t <= 0.0:
				if dist <= ATTACK_RANGE + 0.7:
					p.take_damage(ATTACK_DAMAGE, global_transform.origin)
				_cd = ATTACK_COOLDOWN
		elif _stun <= 0.0 and dist < DETECT:
			_face(to, delta)
			if dist > ATTACK_RANGE:
				move = to.normalized() * SPEED
			elif _cd <= 0.0:
				_windup_t = WINDUP
				human.play_attack(WINDUP)
				human.flash(Color(1.0, 0.85, 0.2), 0.18)
	else:
		_windup_t = 0.0

	var horizontal = move + _knock
	_knock = _knock.linear_interpolate(Vector3.ZERO, min(1.0, delta * 8.0))

	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= GRAVITY * delta
	velocity = move_and_slide(velocity, Vector3.UP)

	human.speed_factor = Vector2(velocity.x, velocity.z).length() / 7.0


func take_damage(amount: float, from_pos: Vector3):
	if dead:
		return
	hp -= amount
	_stun = 0.35
	_windup_t = 0.0
	_cd = max(_cd, 0.6)
	var away = global_transform.origin - from_pos
	away.y = 0.0
	if away.length() > 0.01:
		_knock = away.normalized() * 7.0
	human.flash(Color(1.0, 1.0, 1.0), 0.1)
	if hp <= 0.0:
		_die()


func _die():
	dead = true
	hp = 0.0
	_dead_t = 2.5
	collision_layer = 0
	collision_mask = 0
	human.set_fallen(true)
	if main_ref != null:
		main_ref.on_enemy_died()

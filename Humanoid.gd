extends Spatial
# Petit humain low-poly construit avec des cubes.
# Les pieds sont à y = 0 et l'avant du personnage est vers -Z.

var skin_color := Color(0.87, 0.68, 0.54)
var shirt_color := Color(0.9, 0.3, 0.2)
var pants_color := Color(0.2, 0.3, 0.6)
var hair_color := Color(0.15, 0.1, 0.08)

# Mis à jour par le joueur / l'ennemi : 0 = immobile, 1 = vitesse de marche normale
var speed_factor := 0.0

var _mats := []
var _base := []
var _lleg
var _rleg
var _larm
var _rarm
var _phase := 0.0
var _attack_t := 0.0
var _attack_dur := 0.35
var _flash_t := 0.0
var _fallen := false


func _ready():
	scale = Vector3(0.9, 0.9, 0.9)

	# Jambes (pivot à la hanche)
	_lleg = _pivot(Vector3(-0.17, 0.85, 0.0))
	_part(_lleg, Vector3(0.28, 0.85, 0.3), Vector3(0.0, -0.425, 0.0), pants_color)
	_rleg = _pivot(Vector3(0.17, 0.85, 0.0))
	_part(_rleg, Vector3(0.28, 0.85, 0.3), Vector3(0.0, -0.425, 0.0), pants_color)

	# Torse
	_part(self, Vector3(0.72, 0.72, 0.38), Vector3(0.0, 1.21, 0.0), shirt_color)

	# Bras (pivot à l'épaule) avec les mains
	_larm = _pivot(Vector3(-0.47, 1.52, 0.0))
	_part(_larm, Vector3(0.22, 0.68, 0.24), Vector3(0.0, -0.3, 0.0), shirt_color)
	_part(_larm, Vector3(0.2, 0.16, 0.22), Vector3(0.0, -0.68, 0.0), skin_color)
	_rarm = _pivot(Vector3(0.47, 1.52, 0.0))
	_part(_rarm, Vector3(0.22, 0.68, 0.24), Vector3(0.0, -0.3, 0.0), shirt_color)
	_part(_rarm, Vector3(0.2, 0.16, 0.22), Vector3(0.0, -0.68, 0.0), skin_color)

	# Tête, cheveux, yeux
	_part(self, Vector3(0.4, 0.4, 0.4), Vector3(0.0, 1.78, 0.0), skin_color)
	_part(self, Vector3(0.44, 0.14, 0.44), Vector3(0.0, 1.96, 0.0), hair_color)
	_part(self, Vector3(0.44, 0.32, 0.12), Vector3(0.0, 1.8, 0.17), hair_color)
	_part(self, Vector3(0.07, 0.07, 0.02), Vector3(-0.1, 1.8, -0.205), Color(0.05, 0.05, 0.05))
	_part(self, Vector3(0.07, 0.07, 0.02), Vector3(0.1, 1.8, -0.205), Color(0.05, 0.05, 0.05))


func _pivot(pos: Vector3) -> Spatial:
	var p := Spatial.new()
	p.translation = pos
	add_child(p)
	return p


func _part(parent: Node, size: Vector3, pos: Vector3, color: Color) -> MeshInstance:
	var mi := MeshInstance.new()
	var mesh := CubeMesh.new()
	mesh.size = size
	var mat := SpatialMaterial.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.translation = pos
	parent.add_child(mi)
	_mats.append(mat)
	_base.append(color)
	return mi


# Animation de coup (le bras droit part vers l'avant)
func play_attack(duration: float):
	_attack_dur = duration
	_attack_t = duration


# Fait clignoter tout le corps d'une couleur (coup reçu, avertissement...)
func flash(color: Color, duration: float):
	for m in _mats:
		m.albedo_color = color
	_flash_t = duration


# Le personnage tombe sur le dos (KO) ou se relève
func set_fallen(value: bool):
	_fallen = value


func _process(delta):
	# Fin du clignotement : on remet les couleurs d'origine
	if _flash_t > 0.0:
		_flash_t -= delta
		if _flash_t <= 0.0:
			for i in range(_mats.size()):
				_mats[i].albedo_color = _base[i]

	# Chute / relevé
	var tilt = 0.0
	if _fallen:
		tilt = 1.45
	rotation.x = lerp(rotation.x, tilt, min(1.0, delta * 6.0))

	# Marche
	var moving = speed_factor > 0.15 and not _fallen
	var swing = 0.0
	if moving:
		_phase += delta * (9.0 + 3.0 * speed_factor)
		swing = sin(_phase) * 0.8 * min(speed_factor, 1.3)

	var k = min(1.0, delta * 14.0)
	_lleg.rotation.x = lerp(_lleg.rotation.x, swing, k)
	_rleg.rotation.x = lerp(_rleg.rotation.x, -swing, k)
	_larm.rotation.x = lerp(_larm.rotation.x, -swing, k)

	if _attack_t > 0.0:
		_attack_t -= delta
		var p = 1.0 - clamp(_attack_t / _attack_dur, 0.0, 1.0)
		_rarm.rotation.x = sin(p * PI) * 2.4
	else:
		_rarm.rotation.x = lerp(_rarm.rotation.x, swing, k)

extends Spatial
# Prototype v0.1 : petit monde low-poly, joueur déplaçable, caméra qui suit.

const CAM_OFFSET := Vector3(0, 14, 11)

var player
var camera
var joystick


func _ready():
	_setup_inputs()
	_build_environment()
	_build_world()
	_build_player()
	_build_camera()
	_build_ui()


func _setup_inputs():
	# Clavier pour tester sur PC (ZQSD pour AZERTY, WASD, flèches)
	var map = {
		"move_up": [KEY_W, KEY_Z, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_Q, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
	}
	for action in map.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code in map[action]:
			var ev := InputEventKey.new()
			ev.scancode = code
			InputMap.action_add_event(action, ev)


func _build_environment():
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.53, 0.78, 0.95)
	env.ambient_light_color = Color(0.75, 0.75, 0.85)
	env.ambient_light_energy = 0.6
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	add_child(sun)


func _mesh_box(size: Vector3, color: Color) -> MeshInstance:
	var mi := MeshInstance.new()
	var mesh := CubeMesh.new()
	mesh.size = size
	var mat := SpatialMaterial.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	return mi


func _box(pos: Vector3, size: Vector3, color: Color, collide := true) -> Spatial:
	var holder: Spatial
	if collide:
		holder = StaticBody.new()
		var cs := CollisionShape.new()
		var shape := BoxShape.new()
		shape.extents = size / 2.0
		cs.shape = shape
		holder.add_child(cs)
	else:
		holder = Spatial.new()
	holder.add_child(_mesh_box(size, color))
	holder.translation = pos
	add_child(holder)
	return holder


func _build_world():
	# Sol
	_box(Vector3(0, -0.5, 0), Vector3(200, 1, 200), Color(0.35, 0.65, 0.35))
	# Routes en croix
	_box(Vector3(0, 0.02, 0), Vector3(200, 0.04, 8), Color(0.2, 0.2, 0.22), false)
	_box(Vector3(0, 0.02, 0), Vector3(8, 0.04, 200), Color(0.2, 0.2, 0.22), false)
	# Bâtiments aléatoires (toujours les mêmes grâce à la graine)
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in range(40):
		var x := rng.randf_range(-80.0, 80.0)
		var z := rng.randf_range(-80.0, 80.0)
		var h := rng.randf_range(3.0, 14.0)
		var w := rng.randf_range(4.0, 9.0)
		var hue := rng.randf_range(0.0, 1.0)
		if abs(x) < 10.0 or abs(z) < 10.0:
			continue  # on laisse les routes libres
		_box(Vector3(x, h / 2.0, z), Vector3(w, h, w), Color.from_hsv(hue, 0.35, 0.9))


func _build_player():
	player = KinematicBody.new()
	player.set_script(load("res://Player.gd"))
	var cs := CollisionShape.new()
	var shape := BoxShape.new()
	shape.extents = Vector3(0.4, 0.9, 0.4)
	cs.shape = shape
	player.add_child(cs)
	player.add_child(_mesh_box(Vector3(0.8, 1.8, 0.8), Color(0.9, 0.3, 0.2)))
	# "Nez" pour voir où regarde le personnage (avant = -Z)
	var nose := _mesh_box(Vector3(0.3, 0.3, 0.5), Color(1, 1, 1))
	nose.translation = Vector3(0, 0.4, -0.5)
	player.add_child(nose)
	player.translation = Vector3(0, 1.0, 0)
	add_child(player)


func _build_camera():
	camera = Camera.new()
	camera.far = 300.0
	add_child(camera)
	camera.translation = player.translation + CAM_OFFSET
	camera.look_at(player.translation, Vector3.UP)


func _build_ui():
	var layer := CanvasLayer.new()
	add_child(layer)

	joystick = Control.new()
	joystick.set_script(load("res://VirtualJoystick.gd"))
	layer.add_child(joystick)
	joystick.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	player.joystick = joystick

	var label := Label.new()
	label.text = "Prototype v0.1 - ZQSD / fleches ou joystick tactile (moitie gauche de l'ecran)"
	label.rect_position = Vector2(16, 12)
	layer.add_child(label)


func _process(delta):
	if player == null or camera == null:
		return
	var target = player.translation + CAM_OFFSET
	camera.translation = camera.translation.linear_interpolate(target, min(1.0, delta * 5.0))
	camera.look_at(player.translation, Vector3.UP)

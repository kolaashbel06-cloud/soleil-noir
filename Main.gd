extends Spatial
# Prototype v0.2 : humains low-poly, combat (coup + esquive), ennemis, barre de vie.

const CAM_OFFSET := Vector3(0, 14, 11)
const MAX_ENEMIES := 5

var player
var camera
var joystick
var hud
var kills := 0
var _spawn_timer := 5.0
var _t := 0.0
var _beat := 0
const LOG_PATH := "user://boot.log"


func _ready():
	randomize()
	var previous := _read_log()
	_log_start()
	_setup_inputs()
	_log("inputs")
	_build_environment()
	_log("environnement")
	_build_world()
	_log("monde")
	_build_player()
	_log("joueur")
	_build_camera()
	_log("camera")
	_build_ui()
	_log("interface")
	_show_previous_log(previous)
	for i in range(MAX_ENEMIES):
		_spawn_enemy(_road_spawn_pos())
	_log("ennemis")
	_log("demarrage termine")


# --- Journal de demarrage -----------------------------------------------------
# Ecrit chaque etape dans un petit fichier. Si le jeu se fige, au prochain lancement
# l'ecran affiche la derniere etape atteinte, ce qui permet de localiser le probleme.

func _read_log() -> String:
	var f := File.new()
	if not f.file_exists(LOG_PATH):
		return ""
	if f.open(LOG_PATH, File.READ) != OK:
		return ""
	var text := f.get_as_text()
	f.close()
	return text


func _log_start():
	var f := File.new()
	if f.open(LOG_PATH, File.WRITE) == OK:
		f.store_line("== nouveau lancement ==")
		f.close()


func _log(msg: String):
	var f := File.new()
	if f.open(LOG_PATH, File.READ_WRITE) == OK:
		f.seek_end()
		f.store_line(msg)
		f.close()


func _show_previous_log(previous: String):
	# Si le lancement precedent ne s'est pas termine proprement, on montre ou il s'est arrete.
	if previous == "" or previous.find("tout va bien") != -1:
		return
	var lines = previous.strip_edges().split("\n")
	var last = lines[lines.size() - 1]
	var label := Label.new()
	label.text = "Dernier lancement interrompu apres : " + last
	label.rect_position = Vector2(16, 120)
	label.modulate = Color(1.0, 0.9, 0.3)
	hud.get_parent().add_child(label)


func _setup_inputs():
	# Clavier pour tester sur PC (ZQSD pour AZERTY, WASD, flèches, Espace = coup, Maj = esquive)
	var map = {
		"move_up": [KEY_W, KEY_Z, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_Q, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"attack": [KEY_SPACE, KEY_J],
		"dodge": [KEY_SHIFT, KEY_K],
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

	hud = Control.new()
	hud.set_script(load("res://Hud.gd"))
	hud.player = player
	hud.camera = camera
	hud.main = self
	layer.add_child(hud)
	hud.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	hud.connect("attack_pressed", player, "attack")
	hud.connect("dodge_pressed", player, "dodge")

	var label := Label.new()
	label.text = "Prototype v0.3 - ZQSD/fleches, Espace = coup, Maj = esquive, ou ecran tactile"
	label.rect_position = Vector2(16, 12)
	layer.add_child(label)


# --- Ennemis ---------------------------------------------------------------

func _road_spawn_pos() -> Vector3:
	var sgn = 1.0
	if randf() < 0.5:
		sgn = -1.0
	var far = rand_range(18.0, 60.0) * sgn
	var side = rand_range(-3.0, 3.0)
	if randf() < 0.5:
		return Vector3(far, 1.0, side)
	return Vector3(side, 1.0, far)


func _spawn_enemy(pos: Vector3):
	var e := KinematicBody.new()
	e.set_script(load("res://Enemy.gd"))
	e.translation = pos
	e.main_ref = self
	add_child(e)


func _alive_enemies() -> int:
	var n := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.dead:
			n += 1
	return n


func on_enemy_died():
	kills += 1


func _process(delta):
	if player == null or camera == null:
		return
	_t += delta
	if _beat == 0:
		_beat = 1
		_log("premiere image")
	elif _beat == 1 and _t > 2.0:
		_beat = 2
		_log("2 secondes")
	elif _beat == 2 and _t > 5.0:
		_beat = 3
		_log("tout va bien")

	var target = player.translation + CAM_OFFSET
	camera.translation = camera.translation.linear_interpolate(target, min(1.0, delta * 5.0))
	camera.look_at(player.translation, Vector3.UP)

	# De nouveaux ennemis arrivent régulièrement par les routes
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 5.0
		if _alive_enemies() < MAX_ENEMIES:
			var pos = _road_spawn_pos()
			if pos.distance_to(player.translation) > 20.0:
				_spawn_enemy(pos)


func _notification(what):
	# Bouton "retour" d'Android : on revient a l'ecran-titre
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_log("retour au titre (tout va bien)")
		get_tree().change_scene("res://Title.tscn")

extends Control
# Ecran-titre de DRAEVEN : fond sombre, lueur, lame, nom et bouton JOUER.
# Tout est construit par le code (comme le reste du prototype).

const GAME_SCENE := "res://Main.tscn"

var _bg
var _glow
var _dagger
var _name
var _play
var _version
var _dagger_pos := Vector2.ZERO
var _t := 0.0
var _starting := false


func _ready():
	_bg = ColorRect.new()
	_bg.color = Color(0.063, 0.063, 0.071)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	_glow = _make_rect("res://title_glow.png")
	_dagger = _make_rect("res://title_dagger.png")
	_name = _make_rect("res://title_wordmark.png")

	_play = TextureButton.new()
	_play.texture_normal = load("res://btn_play.png")
	_play.texture_pressed = load("res://btn_play_pressed.png")
	_play.expand = true
	_play.stretch_mode = TextureButton.STRETCH_SCALE
	_play.connect("pressed", self, "_on_play")
	add_child(_play)

	_version = Label.new()
	_version.text = "v0.3 - prototype"
	_version.modulate = Color(1, 1, 1, 0.35)
	add_child(_version)

	get_viewport().connect("size_changed", self, "_layout")
	_layout()


func _make_rect(path: String) -> TextureRect:
	var r := TextureRect.new()
	r.texture = load(path)
	r.expand = true
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _layout():
	var s = get_viewport().get_visible_rect().size
	_bg.rect_position = Vector2.ZERO
	_bg.rect_size = s

	# Lame et lueur, a gauche
	var cx = s.x * 0.27
	var cy = s.y * 0.5
	if _dagger.texture != null:
		var dh = s.y * 0.8
		var ds = _dagger.texture.get_size()
		var dw = dh * ds.x / ds.y
		_dagger.rect_size = Vector2(dw, dh)
		_dagger_pos = Vector2(cx - dw / 2.0, cy - dh / 2.0)
		_dagger.rect_position = _dagger_pos
		var gs = dh * 1.5
		_glow.rect_size = Vector2(gs, gs)
		_glow.rect_position = Vector2(cx - gs / 2.0, cy - gs / 2.0)

	# Nom et bouton, a droite
	var nx = s.x * 0.66
	var nw = min(s.x * 0.5, 760.0)
	if _name.texture != null:
		var ns = _name.texture.get_size()
		var nh = nw * ns.y / ns.x
		_name.rect_size = Vector2(nw, nh)
		_name.rect_position = Vector2(nx - nw / 2.0, s.y * 0.40 - nh / 2.0)
	if _play.texture_normal != null:
		var ps = _play.texture_normal.get_size()
		var bw = nw * 0.58
		var bh = bw * ps.y / ps.x
		_play.rect_size = Vector2(bw, bh)
		_play.rect_position = Vector2(nx - bw / 2.0, s.y * 0.72 - bh / 2.0)
		_play.rect_pivot_offset = _play.rect_size / 2.0

	_version.rect_position = Vector2(s.x - 190.0, s.y - 40.0)


func _process(delta):
	_t += delta
	modulate = Color(1, 1, 1, min(1.0, _t / 0.8))
	_dagger.rect_position = _dagger_pos + Vector2(0.0, sin(_t * 1.3) * 8.0)
	_glow.modulate = Color(1, 1, 1, 0.8 + 0.2 * sin(_t * 1.7))
	var k = 1.0 + 0.03 * sin(_t * 3.0)
	_play.rect_scale = Vector2(k, k)


func _on_play():
	if _starting:
		return
	_starting = true
	get_tree().change_scene(GAME_SCENE)


func _unhandled_input(event):
	# Pour tester sur PC : Entree ou Espace
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or event.scancode == KEY_SPACE:
			_on_play()


func _notification(what):
	# Bouton "retour" d'Android : on quitte le jeu depuis l'ecran-titre
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

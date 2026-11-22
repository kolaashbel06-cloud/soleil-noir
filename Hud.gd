extends Control
# Interface : barre de vie, boutons Coup / Esquive, barres de vie des ennemis, compteur.

signal attack_pressed
signal dodge_pressed

var player = null
var camera = null
var main = null

const ATTACK_R := 75.0
const DODGE_R := 55.0

var _attack_touch := -1
var _dodge_touch := -1
var _font


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = get_font("font", "Label")


func _attack_center() -> Vector2:
	var s = get_viewport().get_visible_rect().size
	return Vector2(s.x - 130.0, s.y - 150.0)


func _dodge_center() -> Vector2:
	var s = get_viewport().get_visible_rect().size
	return Vector2(s.x - 300.0, s.y - 95.0)


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if _attack_touch == -1 and event.position.distance_to(_attack_center()) <= ATTACK_R * 1.25:
				_attack_touch = event.index
				emit_signal("attack_pressed")
			elif _dodge_touch == -1 and event.position.distance_to(_dodge_center()) <= DODGE_R * 1.25:
				_dodge_touch = event.index
				emit_signal("dodge_pressed")
		else:
			if event.index == _attack_touch:
				_attack_touch = -1
			if event.index == _dodge_touch:
				_dodge_touch = -1


func _process(_delta):
	update()


func _text(text, pos: Vector2, sc = 1.0, color = Color(1, 1, 1, 1)):
	draw_set_transform(pos, 0.0, Vector2(sc, sc))
	draw_string(_font, Vector2.ZERO, text, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _text_centered(text, center: Vector2, sc = 1.0, color = Color(1, 1, 1, 1)):
	var w = _font.get_string_size(text).x * sc
	_text(text, center + Vector2(-w / 2.0, 5.0 * sc), sc, color)


func _draw_button(center: Vector2, radius: float, col: Color, label: String, pressed: bool, dimmed: bool):
	var alpha = 0.35
	if pressed:
		alpha = 0.7
	if dimmed:
		alpha = 0.15
	draw_circle(center, radius, Color(col.r, col.g, col.b, alpha))
	draw_arc(center, radius, 0.0, TAU, 40, Color(1, 1, 1, 0.6), 3.0)
	_text_centered(label, center, 1.5)


func _draw():
	var s = get_viewport().get_visible_rect().size

	# Barre de vie du joueur
	if player != null:
		var ratio = clamp(player.hp / player.max_hp, 0.0, 1.0)
		draw_rect(Rect2(16, 40, 304, 26), Color(0, 0, 0, 0.55))
		draw_rect(Rect2(18, 42, 300.0 * ratio, 22), Color(0.85, 0.2, 0.2))
		_text("Vie", Vector2(26, 60))

	# Compteur
	if main != null:
		_text("Ennemis vaincus : %d" % main.kills, Vector2(16, 92))

	# Barres de vie des ennemis
	if camera != null:
		for e in get_tree().get_nodes_in_group("enemies"):
			if e.dead:
				continue
			var wp = e.global_transform.origin + Vector3(0.0, 2.2, 0.0)
			if camera.is_position_behind(wp):
				continue
			var sp = camera.unproject_position(wp)
			var r = clamp(e.hp / e.max_hp, 0.0, 1.0)
			draw_rect(Rect2(sp.x - 26.0, sp.y - 4.0, 52.0, 8.0), Color(0, 0, 0, 0.6))
			draw_rect(Rect2(sp.x - 25.0, sp.y - 3.0, 50.0 * r, 6.0), Color(0.9, 0.75, 0.2))

	# Boutons tactiles
	var dodge_ready = player == null or player.dodge_cd <= 0.0
	_draw_button(_attack_center(), ATTACK_R, Color(0.9, 0.25, 0.2), "Coup", _attack_touch != -1, false)
	_draw_button(_dodge_center(), DODGE_R, Color(0.25, 0.55, 0.95), "Esquive", _dodge_touch != -1, not dodge_ready)

	# Message de KO
	if player != null and player.dead:
		_text_centered("KO ! Tu reviens dans un instant...", Vector2(s.x / 2.0, s.y / 2.0), 2.0)

extends Control
# Joystick virtuel : touche la moitié gauche de l'écran, glisse pour te déplacer.

var output := Vector2.ZERO
var _touch_index := -1
var _center := Vector2.ZERO
const RADIUS := 110.0


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event):
	if event is InputEventScreenTouch:
		var half_width = get_viewport().get_visible_rect().size.x * 0.5
		if event.pressed and _touch_index == -1 and event.position.x < half_width:
			_touch_index = event.index
			_center = event.position
			_update_stick(event.position)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			output = Vector2.ZERO
			update()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_stick(event.position)


func _update_stick(pos: Vector2):
	var d := pos - _center
	if d.length() > RADIUS:
		d = d.normalized() * RADIUS
	output = d / RADIUS
	update()


func _draw():
	if _touch_index != -1:
		draw_circle(_center, RADIUS, Color(1, 1, 1, 0.15))
		draw_circle(_center + output * RADIUS, 40.0, Color(1, 1, 1, 0.4))

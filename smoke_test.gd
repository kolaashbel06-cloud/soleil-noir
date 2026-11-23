extends SceneTree
# Test rapide lance par GitHub Actions (jamais utilise sur le telephone).
# Il demarre le jeu sans ecran, ramene des ennemis pres du joueur, simule un coup et une esquive,
# puis affiche SMOKE_OK s'il est arrive au bout sans planter.

var _t := 0.0
var _stage := 0
var _main = null


func _initialize():
	var title = load("res://Title.tscn").instance()
	root.add_child(title)
	title.queue_free()
	print("TEST : ecran-titre charge")
	_main = load("res://Main.tscn").instance()
	root.add_child(_main)
	print("TEST : jeu charge")


func _idle(delta):
	_t += delta
	if _main == null or _main.player == null:
		print("SMOKE_ECHEC : le jeu n'a pas cree de joueur")
		return true
	var p = _main.player
	if _stage == 0 and _t > 1.5:
		_stage = 1
		for e in get_nodes_in_group("enemies"):
			e.translation = p.translation + Vector3(0.0, 0.0, -1.5)
		print("TEST : ennemis ramenes pres du joueur")
	elif _stage == 1 and _t > 2.0:
		_stage = 2
		Input.action_press("attack")
	elif _stage == 2 and _t > 2.2:
		_stage = 3
		Input.action_release("attack")
		Input.action_press("dodge")
	elif _stage == 3 and _t > 2.5:
		_stage = 4
		Input.action_release("dodge")
	elif _stage == 4 and _t > 6.0:
		print("SMOKE_OK : le jeu a tourne 6 secondes. Vie du joueur = ", p.hp, ", ennemis vaincus = ", _main.kills)
		return true
	return false

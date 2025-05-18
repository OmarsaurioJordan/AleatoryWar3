extends Area2D

const velocidad = 100
const vista = 200
const bisco = 2 * PI * 0.03

var alma = null # linea a la que pertenece
var errarMove = false
var errarDir = Vector2(0, 1)
var colis = []
var grupo = 0 # color al que pertenece
var blanco = null
var meta = Vector2(0, 0)
var desfase = 0
var raiz = null

func _ready():
	raiz = get_node("..").get_node("..")
	get_node("Anima").play("quieto")
	# inicializacion
	Pelea()
	# crear sombra
	var aux = load("res://Scenes/Sombra.tscn").instance()
	raiz.get_node("Sombras").add_child(aux)
	aux.origen = self

func Pelea():
	# alistarse para iniciar desafio
	for i in range(5):
		get_node("Cuerpo/Cabeza/Herida" + str(i)).visible = false
		get_node("Cuerpo/Bala" + str(i)).visible = false
	if raiz.isPlay:
		get_node("Recarga").start(rand_range(0.5, 1))
	meta = Vector2((raiz.limites[0] + raiz.limites[2]) / 2.0,
		(raiz.limites[1] + raiz.limites[3]) / 2.0)

func _process(delta):
	var unt = Vector2(position.x, position.y)
	# colision
	if not colis.empty():
		var dir = Vector2(0, 0)
		for c in colis:
			dir += position - c.position
		position += dir.normalized() * velocidad * delta
	# acciones
	elif raiz.isPlay:
		IA(delta)
	# limitar
	var ant = Vector2(position.x, position.y)
	position.x = clamp(position.x, raiz.limites[0], raiz.limites[2])
	position.y = clamp(position.y, raiz.limites[1], raiz.limites[3])
	if ant.x != position.x or ant.y != position.y:
		errarDir = errarDir.rotated(randf() * 2 * PI)
		var seg = 2 * PI * 0.25
		desfase = rand_range(-seg, seg)
	# animacion
	if unt.x != position.x or unt.y != position.y:
		if get_node("Anima").current_animation != "caminar":
			get_node("Anima").play("caminar")
	elif get_node("Anima").current_animation != "quieto":
		get_node("Anima").play("quieto")
	# nombrelimite
	get_node("Nombre").visible = position.y > raiz.limites[4]
	get_node("NomSom").visible = not get_node("Nombre").visible

func IA(delta):
	# verificar existencia blanco
	if blanco != null:
		var ok = false
		for m in get_tree().get_nodes_in_group("monigotes"):
			if m == blanco:
				ok = position.distance_to(blanco.position) < vista * 1.1
				break
		if not ok:
			blanco = null
	# en caso de existir blanco interactuar
	if blanco != null:
		# darle guerra si tiene municion
		if get_node("Recarga").is_stopped():
			# dispararle al blanco
			var falla = rand_range(-bisco, bisco)
			Disparo(position.direction_to(blanco.position).rotated(falla))
			# moverse para interactuar
			meta = blanco.position
			var dis = position.distance_to(blanco.position)
			if dis < vista * 0.25:
				# esta cerca, hay que huir
				var dir = blanco.position.direction_to(position)
				position += dir.rotated(desfase) * velocidad * delta
				errarDir = errarDir.rotated(randf() * 2 * PI)
			elif dis > vista * 0.75:
				# esta lejos, hay que acercarce
				var dir = position.direction_to(blanco.position)
				position += dir.rotated(desfase) * velocidad * delta
				errarDir = errarDir.rotated(randf() * 2 * PI)
			else:
				# esta a distancia media, hay que bailarlo
				position += errarDir * velocidad * delta
		# huir a causa de no tener municion
		else:
			var dir = blanco.position.direction_to(position)
			position += dir.rotated(desfase) * velocidad * delta
	# pero si no existe, buscarlo y/o rastrearlo
	else:
		# debe buscarse un nuevo blanco
		var monis = get_tree().get_nodes_in_group("monigotes")
		monis.shuffle()
		for m in monis:
			if m != self and (grupo == 0 or grupo != m.grupo):
				if position.distance_to(m.position) < vista:
					blanco = m
					break
		# hay que ir hacia el ultimo lugar que se le vio si hay municion
		if get_node("Recarga").is_stopped():
			if meta.x != 0 and meta.y != 0:
				var dir = position.direction_to(meta)
				position += dir * velocidad * delta
				if position.distance_to(meta) < 22:
					meta = Vector2(0, 0)
			# sino, solo resta errar por el mundo
			elif errarMove:
				position += errarDir * velocidad * delta
		# sino, solo resta errar por el mundo
		elif errarMove:
			position += errarDir * velocidad * delta

func Disparo(angulo):
	if get_node("Tiro").is_stopped() and get_node("Recarga").is_stopped():
		var tot = 5
		for i in range(5):
			if not get_node("Cuerpo/Bala" + str(i)).visible:
				tot -= 1
			else:
				get_node("Cuerpo/Bala" + str(i)).visible = false
				tot -= 1
				var aux = load("res://Scenes/Proyectil.tscn").instance()
				raiz.get_node("Arena").add_child(aux)
				aux.origen = self
				aux.alma = alma
				aux.grupo = grupo
				aux.direccion = angulo
				aux.position = position + angulo * 22
				aux.get_node("Bala").self_modulate = get_node("Cuerpo").self_modulate
				# crear sombra
				var som = load("res://Scenes/Sombra.tscn").instance()
				raiz.get_node("Sombras").add_child(som)
				som.origen = aux
				som.scale = Vector2(0.5, 0.5)
				# iniciar temporizador de cadencia
				if raiz.IsYes("Fastshots"):
					get_node("Tiro").start(rand_range(0.25, 0.5))
				else:
					get_node("Tiro").start(rand_range(0.5, 1))
				break
		if tot == 0:
			get_node("Recarga").start(rand_range(0.5, 1))

func AzarPos():
	position.x = rand_range(raiz.limites[0], raiz.limites[2])
	position.y = rand_range(raiz.limites[1], raiz.limites[3])

func Hit():
	call_deferred("Hot")
	# crear sangre
	var sangre = load("res://Scenes/Sangre.tscn").instance()
	raiz.get_node("Sangres").add_child(sangre)
	sangre.position = position + Vector2(rand_range(-5, 5), rand_range(-5, 5))

func Hot():
	var tot = 0
	for h in range(5):
		if get_node("Cuerpo/Cabeza/Herida" + str(h)).visible:
			tot += 1
	if tot >= raiz.Vidas():
		var aux = load("res://Scenes/Muerto.tscn").instance()
		raiz.get_node("Arena").add_child(aux)
		aux.alma = alma
		aux.position = position
		aux.Sincronizar()
		alma.get_node("Indice").text = str(raiz.ultimoVivo)
		raiz.ultimoVivo -= 1
		queue_free()
	else:
		Lamento()
		var hits = [0, 1, 2, 3, 4]
		hits.shuffle()
		for h in hits:
			if not get_node("Cuerpo/Cabeza/Herida" + str(h)).visible:
				get_node("Cuerpo/Cabeza/Herida" + str(h)).visible = true
				break

func Lamento():
	if not get_node("AudHerido").playing:
		get_node("AudHerido").stream = raiz.audiosHeridos[randi() % 6]
		get_node("AudHerido").play()

func Recuperarse():
	var hits = [0, 1, 2, 3, 4]
	hits.shuffle()
	for h in hits:
		if get_node("Cuerpo/Cabeza/Herida" + str(h)).visible:
			get_node("Cuerpo/Cabeza/Herida" + str(h)).visible = false
			break

func Sincronizar():
	for m in get_tree().get_nodes_in_group("lineas"):
		if m == alma:
			grupo = m.grupo
			get_node("Cuerpo").self_modulate = m.get_node("Grupo").self_modulate
			get_node("Nombre").text = m.get_node("Nombre").text
			get_node("NomSom").text = m.get_node("Nombre").text
			get_node("Cuerpo/Cabeza/Corona").visible = m.get_node("Corona").visible
			break
	if get_node("Nombre").text == "":
		queue_free()

func _on_Errar_timeout():
	get_node("Errar").start(rand_range(1, 4))
	blanco = null
	var seg = 2 * PI * 0.25
	desfase = rand_range(-seg, seg)
	if errarMove:
		errarMove = randf() < 0.666
		errarDir = errarDir.rotated(rand_range(-seg, seg))
	else:
		errarMove = randf() < 0.333
		errarDir = errarDir.rotated(randf() * 2 * PI)

func _on_Monigote_area_entered(area):
	if area.is_in_group("solidos"):
		colis.append(area)

func _on_Monigote_area_exited(area):
	if area.is_in_group("solidos"):
		colis.erase(area)

func _on_Recarga_timeout():
	if raiz.isPlay:
		var tot = 0
		for i in range(5):
			if get_node("Cuerpo/Bala" + str(i)).visible:
				tot += 1
			else:
				get_node("Cuerpo/Bala" + str(i)).visible = true
				tot += 1
				break
		if raiz.IsYes("Fastshots"):
			if tot == 5:
				get_node("Tiro").start(rand_range(0.25, 0.5))
			else:
				get_node("Recarga").start(rand_range(0.25, 0.5))
				get_node("AudRecarga").play()
		else:
			if tot == 5:
				get_node("Tiro").start(rand_range(0.5, 1))
			else:
				get_node("Recarga").start(rand_range(0.5, 1))
				get_node("AudRecarga").play()

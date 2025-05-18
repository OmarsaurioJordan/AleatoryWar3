extends Area2D

const velocidad = 10

var alma = null # linea a la que pertenece
var colis = []
var raiz = null

func _ready():
	raiz = get_node("..").get_node("..")

func _process(delta):
	# colision
	if not colis.empty():
		var dir = Vector2(0, 0)
		for c in colis:
			dir += position - c.position
		position += dir.normalized() * velocidad * delta
	# limitar
	position.x = clamp(position.x, raiz.limites[0], raiz.limites[2])
	position.y = clamp(position.y, raiz.limites[1], raiz.limites[3])
	# nombrelimite
	get_node("Nombre").visible = position.y > raiz.limites[5]
	get_node("NomSom").visible = not get_node("Nombre").visible

func Sincronizar():
	for m in get_tree().get_nodes_in_group("lineas"):
		if m == alma:
			get_node("Nombre").text = m.get_node("Nombre").text
			get_node("NomSom").text = m.get_node("Nombre").text
			get_node("Craneo/Corona").visible = m.get_node("Corona").visible
			break
	if get_node("Nombre").text == "":
		queue_free()

func _on_Muerto_area_entered(area):
	if area.is_in_group("solidos"):
		colis.append(area)

func _on_Muerto_area_exited(area):
	if area.is_in_group("solidos"):
		colis.erase(area)

func Revivir():
	var aux = load("res://Scenes/Monigote.tscn").instance()
	get_node("..").add_child(aux)
	aux.position = position
	aux.alma = alma
	aux.Sincronizar()
	queue_free()

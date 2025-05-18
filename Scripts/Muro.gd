extends Area2D

const velocidad = 10

var colis = []
var raiz

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

func AzarPos():
	position.x = rand_range(raiz.limites[0], raiz.limites[2])
	position.y = rand_range(raiz.limites[1], raiz.limites[3])

func _on_Muro_area_entered(area):
	if area.is_in_group("muros"):
		colis.append(area)

func _on_Muro_area_exited(area):
	if area.is_in_group("muros"):
		colis.erase(area)

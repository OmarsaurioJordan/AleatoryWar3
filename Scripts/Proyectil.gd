extends Area2D

const velocidad = 200

var alma = null # linea a la que pertenece
var origen = null # monigote al que pertenece
var grupo = 0 # color al que pertenece
var direccion = Vector2(0, 0)
var muros = []
var raiz = null

func _ready():
	raiz = get_node("..").get_node("..")

func _process(delta):
	if not muros.empty():
		var dir = Vector2(0, 0)
		for m in muros:
			dir += position - m.position
		direccion = dir.normalized()
	position += direccion * velocidad * delta

func _on_Final_timeout():
	queue_free()

func _on_Proyectil_area_entered(area):
	if area.is_in_group("muros"):
		muros.append(area)
		get_node("AudMuro").play()
	elif area.is_in_group("monigotes"):
		if area != origen and (grupo == 0 or grupo != area.grupo):
			var tot = 0
			for h in range(5):
				if area.get_node("Cuerpo/Cabeza/Herida" + str(h)).visible:
					tot += 1
			if tot >= raiz.Vidas():
				# poner la muerte en el contador de kills
				var val = int(alma.get_node("Kills").text) + 1
				alma.get_node("Kills").text = str(val)
				# darle una vida al que acerto el tiro
				if raiz.IsYes("Vidamas"):
					for m in get_tree().get_nodes_in_group("monigotes"):
						if m == origen:
							m.Recuperarse()
							break
				# crear notificacion
				var nn = area.alma.get_node("Nombre").text
				raiz.NoticiaNueva(alma.get_node("Nombre").text, nn)
			area.Hit()
			queue_free()

func _on_Proyectil_area_exited(area):
	if area.is_in_group("muros"):
		muros.erase(area)

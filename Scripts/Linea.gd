extends Node2D

var grupo = 0 # color al que pertenece
var raiz = null

func _ready():
	raiz = get_node("..").get_node("..")
	get_node("Grupo").self_modulate = raiz.grupo[grupo]
	get_node("Corona").visible = false

func _on_Grupo_pressed():
	grupo += 1
	if grupo >= raiz.grupo.size():
		grupo = 0
	get_node("Grupo").self_modulate = raiz.grupo[grupo]
	for m in get_tree().get_nodes_in_group("jugadores"):
		if m.alma == self:
			m.Sincronizar()

func _on_Nombre_text_changed(new_text):
	if raiz.isPlay and new_text == "":
		new_text = "?"
		get_node("Nombre").text = "?"
	var ok = false
	for m in get_tree().get_nodes_in_group("muertos"):
		if m.alma == self:
			if raiz.isPlay:
				m.Sincronizar()
				ok = true
			else:
				m.queue_free()
	for m in get_tree().get_nodes_in_group("monigotes"):
		if m.alma == self:
			m.Sincronizar()
			ok = true
	if not ok and new_text != "":
		var aux = load("res://Scenes/Monigote.tscn").instance()
		raiz.get_node("Arena").add_child(aux)
		aux.alma = self
		aux.AzarPos()
		aux.Sincronizar()
		get_node("AudNew").play()

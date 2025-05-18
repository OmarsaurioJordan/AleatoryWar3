extends Node2D

const grupo = [
	Color8(255, 255, 255), # blanco
	Color8(255, 125, 125), # rojo
	Color8(100, 255, 100), # verde
	Color8(150, 150, 255), # azul
	Color8(255, 255, 100) # amarillo
]
const limites = [315, 80, 937, 564, 133, 95] # x1,y1, x2,y2, yLimMo,yLimMu

var ultimoVivo = 18
var isPlay = false
var audiosHeridos = []

func _ready():
	randomize()
	get_node("Config").visible = false
	_on_Volumen_value_changed(get_node("Volumen").value)
	# cargar los audios para heridos
	var snd
	for i in range(6):
		snd = load("res://Sounds/s_herido" + str(i + 1) + ".wav")
		audiosHeridos.append(snd)
	# crear las lineas
	var resLinea = load("res://Scenes/Linea.tscn")
	var linea
	for i in range(18):
		linea = resLinea.instance()
		get_node("Lista").add_child(linea)
		linea.position = Vector2(0, i * 28)
		linea.name = "L" + str(i)

func _on_Modo_pressed():
	get_node("AudBoton").play()
	if get_node("Lista").visible:
		get_node("Lista").visible = false
		get_node("Config").visible = true
		get_node("Modo").text = "Lista"
	else:
		get_node("Lista").visible = true
		get_node("Config").visible = false
		get_node("Modo").text = "Configuration"

func _on_Play_pressed():
	isPlay = not isPlay
	if isPlay:
		get_node("Play").text = "Stop"
		get_node("AudFight").play()
		for m in get_tree().get_nodes_in_group("muertos"):
			m.Revivir()
		call_deferred("AlistaMonigotes")
		ultimoVivo = 18
		for m in get_tree().get_nodes_in_group("lineas"):
			m.get_node("Kills").text = "0"
			m.get_node("Indice").text = ""
			if m.get_node("Nombre").text == "":
				m.visible = false
				ultimoVivo -= 1
	else:
		get_node("Play").text = "Play"
		get_node("AudBoton").play()
		for m in get_tree().get_nodes_in_group("lineas"):
			m.visible = true
		for m in get_node("Sangres").get_children():
			m.queue_free()

func AlistaMonigotes():
	var relok = IsYes("Relocate")
	for m in get_tree().get_nodes_in_group("monigotes"):
		m.Pelea()
		if relok:
			m.AzarPos()

func CreaMuros(cuantos):
	for m in get_tree().get_nodes_in_group("muros"):
		m.queue_free()
	var muroClase = load("res://Scenes/Muro.tscn")
	var aux
	for _m in range(cuantos):
		aux = muroClase.instance()
		get_node("Arena").add_child(aux)
		aux.AzarPos()

func _on_MurosB_pressed():
	get_node("AudBoton").play()
	CreaMuros(get_node("Config/MurosV").value)

func TorcerValor(nodoName):
	var txt = get_node("Config/" + nodoName).text
	if txt.count("Yes") == 1:
		get_node("Config/" + nodoName).text = txt.replace("Yes", "No")
	else:
		get_node("Config/" + nodoName).text = txt.replace("No", "Yes")

func IsYes(nodoName):
	return get_node("Config/" + nodoName).text.count("Yes") == 1

func Vidas():
	if IsYes("Lowlives"):
		return 2
	else:
		return 5

func NoticiaNueva(asesino, asesinado):
	var maxY = 20
	for n in get_node("Noticias").get_children():
		maxY = max(maxY, n.rect_position.y + 72)
	var noti = load("res://Scenes/Noticia.tscn").instance()
	get_node("Noticias").add_child(noti)
	noti.rect_position = Vector2(-126, maxY)
	noti.text = noti.text.replace("#", asesino)
	noti.text = noti.text.replace("$", asesinado)

func _on_Relocate_pressed():
	get_node("AudBoton").play()
	TorcerValor("Relocate")

func _on_Vidamas_pressed():
	get_node("AudBoton").play()
	TorcerValor("Vidamas")

func _on_Fastshots_pressed():
	get_node("AudBoton").play()
	TorcerValor("Fastshots")

func _on_Lowlives_pressed():
	get_node("AudBoton").play()
	TorcerValor("Lowlives")

func _on_Volumen_value_changed(value):
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		var vol = lerp(-40, 1, value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), vol)

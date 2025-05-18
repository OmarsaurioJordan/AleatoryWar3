extends Sprite

var origen = null

func _process(_delta):
	var ok = false
	for m in get_tree().get_nodes_in_group("sombreados"):
		if m == origen:
			ok = true
			position = m.position
			break
	if not ok:
		queue_free()

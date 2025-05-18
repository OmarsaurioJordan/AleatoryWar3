extends Label

const velocidad = 60

func _process(delta):
	rect_position.y -= velocidad * delta
	if rect_position.y < -700:
		queue_free() 

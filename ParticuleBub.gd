extends Spatial
var lifetime = 1.3 
var time_remaining = lifetime
var end_auto = true

func _process(delta):
	if(end_auto):
		time_remaining -= delta
		if time_remaining <= 0:
			queue_free()

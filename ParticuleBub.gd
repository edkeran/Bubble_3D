extends Spatial
var lifetime = 1.3 
var time_remaining = lifetime

func _process(delta):
	time_remaining -= delta
	if time_remaining <= 0:
		queue_free()

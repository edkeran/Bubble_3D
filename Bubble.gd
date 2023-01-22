extends Spatial

var isShootBall = false
var isMovingBall = false
var velocity = 20

signal bubble_collide

func _process(delta):
	if(isMovingBall):
		self.translation.y += velocity * delta

func shoot_bubble():
	isMovingBall = true
	var new_parent = get_parent().get_parent();
	get_parent().remove_child(self)
	new_parent.add_child(self, true)

func _on_Area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if(isShootBall):
		isMovingBall = false
		emit_signal("bubble_collide")

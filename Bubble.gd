extends Spatial

var isShootBall = false
var isMovingBall = false
var velocity = 35
var angleRotationShoot

signal bubble_collide

func _process(delta):
	if(isMovingBall):
		self.translation.x += cos(deg2rad(angleRotationShoot+90)) * delta * velocity
		self.translation.y += abs(sin(deg2rad(angleRotationShoot+90))) * delta * velocity

func shoot_bubble():
	if(not isMovingBall):
		isMovingBall = true
		var position = self.global_translation
		angleRotationShoot = get_parent().rotation_degrees.z
		var new_parent = get_parent().get_parent();
		get_parent().remove_child(self)
		self.translation = position
		new_parent.add_child(self, true)

func _on_Area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if(isShootBall):
		isShootBall = false
		isMovingBall = false
		emit_signal("bubble_collide")

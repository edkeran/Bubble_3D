extends Spatial

var isShootBall = false
var isMovingBall = false
var velocity = 45
var maxVelocity = 75
var angleRotationShoot
var posAnt = Vector2(0,0)

signal bubble_collide

func _physics_process(delta):
	if(isMovingBall):
		posAnt = Vector2(self.translation.x, self.translation.y)
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
		
func _on_Area_area_entered(area):
	if(isShootBall and not("isWall" in area)):
		isShootBall = false
		isMovingBall = false
		self.translation.z = 0
		self.translation.x = posAnt.x 
		self.translation.y = posAnt.y
		self.velocity = 0
		emit_signal("bubble_collide")
	elif("isWall" in area):
		$AudioStreamPlayer.play()
		angleRotationShoot= angleRotationShoot*-1
		if(velocity < maxVelocity):
			velocity+=5

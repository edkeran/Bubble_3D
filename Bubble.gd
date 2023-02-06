extends KinematicBody

var isShootBall = false
var isMovingBall = false
var velocity = 40
var maxVelocity = 75
var angleRotationShoot
var offSetInit = Vector2(-16.8,24.4)
var radius = 1.2
var globalGridPos = Vector2(-1, -1)
var currentColor

signal bubble_collide(bubbleObj)

func _physics_process(delta):
	if(isMovingBall):
		var collision = self.move_and_collide(Vector3(cos(deg2rad(angleRotationShoot+90)) * delta * velocity, abs(sin(deg2rad(angleRotationShoot+90))) * delta * velocity, 0))
		if collision:
			_is_collided_action(collision.collider)

func shoot_bubble():
	if(not isMovingBall):
		isMovingBall = true
		var position = self.global_translation
		angleRotationShoot = get_parent().rotation_degrees.z
		var new_parent = get_parent().get_parent();
		get_parent().remove_child(self)
		self.translation = position
		new_parent.add_child(self, true)

func _is_collided_action(area):
	if(isShootBall and not("isWall" in area)):
		isShootBall = false
		isMovingBall = false
		var audio2 = load("res://Assets/Sounds/BubbleShock.mp3")
		$AudioStreamPlayer.stream = audio2
		$AudioStreamPlayer.play()
		_fix_to_grid_position()
		emit_signal("bubble_collide", self)
	elif("isWall" in area):
		var audio = load("res://Assets/Sounds/BubbleBounceWall.mp3")
		$AudioStreamPlayer.stream = audio
		$AudioStreamPlayer.play()
		angleRotationShoot = angleRotationShoot * -1
		if(velocity < maxVelocity):
			velocity+=5

func _fix_to_grid_position():
	var currentXMove = get_parent().correFila
	var xPosition = self.translation.x
	var yPosition = self.translation.y - radius
	#check the closest row with this i know the index in the grid
	var posYGrid = round_to_dec(round_to_dec(offSetInit.y - yPosition,2),1)
	posYGrid = int(round(posYGrid/(radius*2)) - 1)
	self.translation.y = (offSetInit.y - (posYGrid * radius * 2)) - radius 
	var posXGrid = -1
	if(posYGrid % 2 == ( 0 if currentXMove == false else 1)):
		posXGrid = round_to_dec(round_to_dec(abs(offSetInit.x) + xPosition,2),1) + radius
		posXGrid = int(abs(round(posXGrid/(radius*2))))
		self.translation.x = (offSetInit.x + (posXGrid * radius * 2)) - radius
	else:
		posXGrid = round_to_dec(round_to_dec(abs(offSetInit.x) + xPosition,2),1)
		posXGrid = int(abs(round(posXGrid/(radius*2))))
		self.translation.x = (offSetInit.x + (posXGrid * radius * 2))
	globalGridPos.x = posXGrid
	globalGridPos.y = posYGrid

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

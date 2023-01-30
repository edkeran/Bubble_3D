extends Spatial

var colorEnum = preload("res://color_enum.gd").color_enum.new()
var sceneBubble = preload("res://Bubble.tscn")
var randomObj = RandomNumberGenerator.new()
var bordeBurbuja = 0.2
var bubbleShoot;
var matrPosBub = []

func _ready():
	gen_row_bubble()
	gen_bubble_shot()

func gen_bubble_shot():
	bubbleShoot = gen_bubble(0,4.2, false)
	bubbleShoot.translation.z = get_node("BubbleGun").translation.z
	get_node("BubbleGun").add_child(bubbleShoot, false)
	bubbleShoot.isShootBall = true
	bubbleShoot.connect("bubble_collide", self, "_bubble_collided")

func gen_row_bubble():
	var correFila = false
	var j = 0
	while(j <= 13.0 + bordeBurbuja):
		correFila = not correFila
		var i = -15 - bordeBurbuja
		while(i <= 17.0 + bordeBurbuja):
			randomObj.randomize()
			var bubble = gen_bubble(i,21.0 - bordeBurbuja - j, correFila)
			add_child(bubble)
			i+=2.0 + bordeBurbuja
		j+= 2.0 + bordeBurbuja

func gen_bubble(x,y,correFila):
	var pos = randomObj.randi_range(0,4)
	var bubble = sceneBubble.instance()
	var materialBubble = bubble.get_node("MeshInstance").get_surface_material(0)
	materialBubble = materialBubble.duplicate()
	materialBubble.set_shader_param("colorDefault",colorEnum.arrColor[pos])
	bubble.get_node("MeshInstance").set_surface_material(0,materialBubble)
	var newPos
	if(correFila):
		newPos = Vector3(x-1,y,0)
	else:
		newPos = Vector3(x,y,0)
	bubble.translate(newPos)
	return bubble

func _input(event):
	if event is InputEventMouseMotion:
		var posScreen = get_node("Camera").unproject_position(self.get_node("BubbleGun").translation)
		var x = event.position.x - posScreen.x
		var y =  event.position.y - posScreen.y if (event.position.y - posScreen.y) != 0 else 0.1
		var angle = rad2deg(atan(x/y)) 
		get_node("BubbleGun").rotation_degrees.z = angle
	if event.is_action_pressed("shootBubble"):
		if(bubbleShoot != null and !bubbleShoot.isMovingBall):
			get_node("BubbleGun").get_node("ShootSound").play()
			bubbleShoot.shoot_bubble()

func _bubble_collided():
	gen_bubble_shot()

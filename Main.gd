extends Spatial

var isRtxMode = false
var colorEnum = preload("res://color_enum.gd").color_enum.new()
var sceneBubble = preload("res://Bubble.tscn")
var randomObj = RandomNumberGenerator.new()
var radioBurbuja = 1.2
var bubbleShoot
#La posicion -15 representa la posicion inicial de una fila en 3D y la 24.4 representa la Y inicial en 3D
var offSet = Vector2(-16.8,24.4)
var matrPosBub = []

func _ready():
	if(isRtxMode):
		load_rtx_mode()
	fill_empty_mat()
	gen_init_game()
	gen_bubble_shot()
	
func load_rtx_mode():
	$Camera.set_projection(0)

func fill_empty_mat():
	for i in range(0,14):
		var arrY = []
		for j in range(0,15):
			arrY.append(null)
		matrPosBub.append(arrY)

func gen_init_game():
	var correFila = false
	var j=0.0
	var cantRows = 4
	var currentY = offSet.y - radioBurbuja
	while(j < cantRows):
		correFila = not correFila
		var rowBubbles = gen_row_bubble(currentY, correFila)
		matrPosBub[int(j)] = rowBubbles
		currentY-=radioBurbuja*2
		j+=1

func gen_bubble_shot():
	bubbleShoot = gen_bubble(0,4.2, false)
	bubbleShoot.translation.z = get_node("BubbleGun").translation.z
	get_node("BubbleGun").add_child(bubbleShoot, false)
	bubbleShoot.isShootBall = true
	bubbleShoot.connect("bubble_collide", self, "_bubble_collided")

func gen_row_bubble(y, correFila):
	var bubbleLstCreated = []
	var i = 0.0
	var cantCols = 15
	var currentX = 0.0
	while(i < cantCols):
		randomObj.randomize()
		var bubble = gen_bubble(currentX+offSet.x,y, correFila)
		add_child(bubble)
		currentX+=radioBurbuja*2
		bubbleLstCreated.append(bubble)
		i+=1
	return bubbleLstCreated

func gen_bubble(x,y,correFila):
	var pos = randomObj.randi_range(0,4)
	var bubble = sceneBubble.instance()
	var materialBubble = bubble.get_node("MeshInstance").get_surface_material(0)
	materialBubble = materialBubble.duplicate()
	materialBubble.set_shader_param("colorDefault",colorEnum.arrColor[pos])
	if(isRtxMode):
		materialBubble.set_shader_param("roughnessMode", 0.3)
		materialBubble.set_shader_param("specularBrigth", 0.7)
	bubble.get_node("MeshInstance").set_surface_material(0,materialBubble)
	var newPos
	if(correFila):
		newPos = Vector3(x-radioBurbuja,y,0)
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

func _bubble_collided(bubbleObj):
	#It must be added the bubble in the main bubble reference matrix
	matrPosBub[bubbleObj.globalGridPos.y][bubbleObj.globalGridPos.x] = bubbleObj
	gen_bubble_shot()

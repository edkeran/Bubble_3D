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
var correFila = false

func _ready():
	var songGame = AudioStreamPlayer.new()
	var musicGame = load("res://Assets/Sounds/SongMain.mp3")
	songGame.stream = musicGame
	self.add_child(songGame)
	songGame.play()
	if(isRtxMode):
		load_rtx_mode()
	$ScoreCount.uploadScore()
	fill_empty_mat()
	gen_init_game()
	gen_bubble_shot()

func load_rtx_mode():
	$Camera.translation.z = 37
	$Camera.set_projection(0)
	
func fill_empty_mat():
	for i in range(0,14):
		var arrY = []
		for j in range(0,15):
			arrY.append(null)
		matrPosBub.append(arrY)

func gen_init_game():
	var j=0.0
	var cantRows = 4
	var currentY = offSet.y - radioBurbuja
	while(j < cantRows):
		correFila = not correFila
		var rowBubbles = gen_row_bubble(currentY,j,correFila)
		matrPosBub[int(j)] = rowBubbles
		currentY-=radioBurbuja*2
		j+=1

func gen_bubble_shot():
	bubbleShoot = gen_bubble(0,4.2,-1,-1,false)
	bubbleShoot.translation.z = get_node("BubbleGun").translation.z
	get_node("BubbleGun").add_child(bubbleShoot, false)
	bubbleShoot.isShootBall = true
	bubbleShoot.connect("bubble_collide", self, "_bubble_collided")

func gen_row_bubble(y,j,correFila):
	var bubbleLstCreated = []
	var i = 0.0
	var cantCols = 15
	var currentX = 0.0
	while(i < cantCols):
		randomObj.randomize()
		var bubble = gen_bubble(currentX+offSet.x,y,j,i,correFila)
		add_child(bubble)
		currentX+=radioBurbuja*2
		bubbleLstCreated.append(bubble)
		i+=1
	return bubbleLstCreated

func gen_bubble(x,y,j,i,correFila):
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
	bubble.globalGridPos.y = j
	bubble.globalGridPos.x = i
	bubble.currentColor = colorEnum.arrColor[pos]
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
	if(bubbleObj.globalGridPos.y > 13 or bubbleObj.globalGridPos.x > 14):
		_game_over()
		return
	matrPosBub[bubbleObj.globalGridPos.y][bubbleObj.globalGridPos.x] = bubbleObj
	var cluster = getClusterSameColor([],bubbleObj)
	if(cluster.size() >=3):
		$ScoreCount.score+= 5 + (2 *  (cluster.size() - 3))
		$ScoreCount.uploadScore()
	removeClustersNeightbores(cluster)
	gen_bubble_shot()

func getClusterSameColor(matrixCluster, ball):
	var evenBallVert = [[0,1],[0,-1],[1,0],[-1,0],[1,1],[-1,1]]
	var oddBallVert =  [[0,1],[0,-1],[1,0],[-1,0],[-1,-1],[1,-1]]
	var selectedPosition
	if(int(ball.globalGridPos.y) % 2 == 1):
		selectedPosition = evenBallVert
	else:
		selectedPosition = oddBallVert
	for positionNeighbor in selectedPosition:
			if(positionNeighbor[0] + int(ball.globalGridPos.y) < matrPosBub.size()
			&& positionNeighbor[1] + int(ball.globalGridPos.x) < matrPosBub[0].size()
			&& positionNeighbor[0] + int(ball.globalGridPos.y) >= 0 
			&& positionNeighbor[1] + int(ball.globalGridPos.x) >= 0):
				var ballClust = matrPosBub[positionNeighbor[0] + int(ball.globalGridPos.y)][positionNeighbor[1] + int(ball.globalGridPos.x)]
				if( ballClust != null && ballClust.currentColor == ball.currentColor):
					if(!matrixCluster.has(ballClust)):
						matrixCluster.append(ballClust)
						matrixCluster = getClusterSameColor(matrixCluster,ballClust)
	return matrixCluster

func removeClustersNeightbores(cluster):
	for object in cluster:
		if(object != null && cluster.size() >= 3):
			var particuleEscene = load("res://ParticuleBub.tscn").instance()
			particuleEscene.translation.x = object.translation.x
			particuleEscene.translation.y = object.translation.y
			particuleEscene.translation.z = 0
			particuleEscene.get_children()[0].process_material.color = Color(object.currentColor.x,object.currentColor.y,object.currentColor.z,1)
			self.add_child(particuleEscene)
			self.remove_child(object)
			matrPosBub[object.globalGridPos.y][object.globalGridPos.x] = null
			var audio = load("res://Assets/Sounds/bubblePop.mp3")
			$AudioStreamPlayer3D.stream = audio
			$AudioStreamPlayer3D.play()

#Function to generate a top bubble each time
func _gen_top_row():
	move_bubbles_rows_down()
	_fills_firts_row()
	correFila = not correFila
	pass

func _fills_firts_row():
	var j=0.0
	var cantRows = 1
	var currentY = offSet.y - radioBurbuja
	while(j < cantRows):
		var rowBubbles = gen_row_bubble(currentY,j,correFila)
		matrPosBub[int(j)] = rowBubbles
		currentY-=radioBurbuja*2
		j+=1

func move_bubbles_rows_down():
	var limitCol = -1
	var limitRow = -1
	var i = 13
	var j
	while i > limitCol:
		j = 14
		while j > limitRow:
			if(matrPosBub[i][j] != null):
				matrPosBub[i][j].translation.y -= radioBurbuja * 2
				matrPosBub[i][j].globalGridPos.y = i + 1
				var bubbleCurrent = matrPosBub[i][j]
				matrPosBub[i][j] = null
				if(i+1 > 13):
					_game_over()
					return
				matrPosBub[i+1][j] = bubbleCurrent
			j-=1 
		i-=1

func _game_over():
	var scena = load("res://GameOver.tscn").instance()
	$AudioStreamPlayer3D.stop()
	get_tree().get_root().add_child(scena)
	get_tree().get_root().remove_child(self)
	self.queue_free()

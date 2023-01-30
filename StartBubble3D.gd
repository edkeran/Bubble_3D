extends Node2D

var logosRuta = ["res://Assets/StartImages/logoCompanie.svg","res://Assets/StartImages/LogoGame.svg"];
var textLogo = ["Wolfcat Studios", "Presenta:"];
var sizeImage = [[0.3,0.3],[0.6,0.6]]
var positionLabel = [92,0]
var currentIndex = 0

func _ready():
	loadImageTextCurren()
	
func loadImageTextCurren():
	$CurrentText.text = textLogo[currentIndex]
	$CurrentLogo.rect_position.y = positionLabel[currentIndex]
	$CurrentLogo.texture = ResourceLoader.load(logosRuta[currentIndex])
	$CurrentLogo.rect_scale.x = sizeImage[currentIndex][0]
	$CurrentLogo.rect_scale.y = sizeImage[currentIndex][1]
	$Animacion.interpolate_property($CurrentLogo, "modulate", 
	  Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2.0, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Animacion.interpolate_property($TextInformation, "modulate", 
	  Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2.0, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Animacion.start()


func _on_Animacion_tween_completed(object, key):
	if(object == $CurrentLogo):
		currentIndex+=1;
		if(currentIndex < logosRuta.size()):
			loadImageTextCurren()
		if(currentIndex == logosRuta.size()):
			get_tree().change_scene("res://MainMenu.tscn")

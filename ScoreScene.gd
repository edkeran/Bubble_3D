extends Control

var score = 0

func uploadScore():
	$RichTextLabel.text = "Puntaje: " + str(score)

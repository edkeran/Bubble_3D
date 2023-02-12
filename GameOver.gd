extends Control

var finalScore

func _ready():
	$FinalScore.text = str(finalScore)

func _on_BackMenu_pressed():
	var mainMenu = load("res://MainMenu.tscn").instance()
	get_tree().get_root().add_child(mainMenu)
	self.queue_free()

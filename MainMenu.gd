extends Control

var isRtxMode = false
var sceneGame = preload("res://Main.tscn")


func _on_StartButton_pressed():
	var scena = sceneGame.instance()
	scena.isRtxMode = self.isRtxMode
	get_tree().get_root().add_child(scena)
	get_tree().get_root().remove_child(self)


func _on_ExitButton_pressed():
	get_tree().quit() 


func _on_RtxMode_pressed():
	isRtxMode = not isRtxMode

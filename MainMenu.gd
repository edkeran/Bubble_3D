extends Control

var isRtxMode = true
var sceneGame = preload("res://Main.tscn")
var fullScreen = false
signal stopSong


func _on_StartButton_pressed():
	var scena = sceneGame.instance()
	scena.isRtxMode = self.isRtxMode
	get_tree().get_root().add_child(scena)
	get_tree().get_root().remove_child(self)
	self.queue_free()
	
func _on_ExitButton_pressed():
	get_tree().quit() 

func _on_RtxMode_pressed():
	isRtxMode = not isRtxMode


func _on_FullScreen_pressed():
	fullScreen = not fullScreen
	OS.window_fullscreen = fullScreen

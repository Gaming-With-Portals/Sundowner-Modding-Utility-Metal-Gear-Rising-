extends Node

var applic_name = "MGRR: Sundowner Modding Utility"
var menu_state = 0

func error(message):
	var audiohandler = AudioStreamPlayer2D.new()
	get_tree().current_scene.add_child(audiohandler)
	if randi_range(0, 100000) == 1:
		audiohandler.stream = load("res://assets/ninja.mp3")
	else:
		audiohandler.stream = load("res://assets/denied.wav")
		
	audiohandler.play()
	OS.alert(message, applic_name)

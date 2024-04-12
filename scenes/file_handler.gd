extends Control

var File_Path = null
var vBox_ref = null
var ext = "smudat"

func _ready():
	$pane000.visible = true
	$pane001.visible = false
	
		
func _build_file(filepath, vboxref):
	vBox_ref = vboxref
	File_Path = filepath
	var displayname = filepath.get_file()
	if len(displayname) > 35:
		displayname = displayname.substr(0, 35) + "..."
		print("OVERFLOW")
	$pane000/Label.text = displayname
	ext = filepath.get_extension()
	if ext == "bxm" or ext == "mot":
		$pane000/TextureRect.texture = load("res://assets/icons/animation.png")
	elif ext == "wta" or ext == "wtp":
		$pane000/TextureRect.texture = load("res://assets/icons/texture.png")
	elif ext == "wmb":
		$pane000/TextureRect.texture = load("res://assets/icons/model.png")
	elif ext == "bnk":
		$pane000/TextureRect.texture = load("res://assets/icons/bnk.png")
	elif ext == "bin":
		$pane000/TextureRect.texture = load("res://assets/icons/bin.png")
	else:
		$pane000/TextureRect.texture = load("res://assets/icons/misc.png")


func _on_info_pressed():
	$pane000.visible = false
	$pane001.visible = true


func _on_back_pressed():
	$pane000.visible = true
	$pane001.visible = false


func _on_export_pressed():
	pass # Replace with function body.


func _on_replace_pressed():
	var fd = Fileautoload.get_node("FileDialog")
	fd.file_selected.connect(_replace_file)
	fd.visible = true
	

func _on_remove_pressed():
	var output = []
	OS.execute("rm", ["-f", "-r", "-v", File_Path], output)
	if not output[0].findn("removed") == -1:
		print("Sucessfully removed!")
		vBox_ref.remove_child(self)

func _on_rename_button_down():
	pass # Replace with function body.


func _replace_file(path):
	print(path)
	OS.execute("rm", ["-f", "-r", "-v", File_Path])
	DirAccess.copy_absolute(path, File_Path)
	

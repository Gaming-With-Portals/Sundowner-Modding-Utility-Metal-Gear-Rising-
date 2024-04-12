extends Control


func _build_directory(filePath):
	print(filePath)
	filePath = filePath + "/data_dat/"
	for child in $FileList/VBoxContainer.get_children():
		$FileList/VBoxContainer.remove_child(child)
		child.queue_free()
	
	var file_list = DirAccess.get_files_at(filePath)
	var file_disp_ref = $File_Copy
	
	var file_og = load("res://scenes/file.tscn")
	var x = 0
	for file in file_list:
		x+=1
		var FileThing = file_og.instantiate()
		FileThing._build_file(filePath + file, $FileList/VBoxContainer)
		$FileList/VBoxContainer.add_child(FileThing)
		


func _on_line_edit_text_submitted(new_text):
	pass # Replace with function body.

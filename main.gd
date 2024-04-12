extends Control

# This controls literally everything for no reason

var filePath:String
var LoadedFile = null
var FileType = ""
var tools_path = null
var data_path = null
var IsDatLoaded = false
var uuid = null

var VALID_EXTENSIONS = ["dat", "dtt", "env", "eff", "eft"]

func _ready():
	
	tools_path = OS.get_executable_path().get_base_dir() + "/pmc/"
	data_path = OS.get_executable_path().get_base_dir() + "/pmc/data/"
	print("Clearing cache")
	_clear_temp_directory()

	
	print(tools_path)
	# Connect the signals
	get_tree().get_root().files_dropped.connect(_getDroppedFiles)
	
	for child in $right_pane.get_children():
		child.visible = false
	$right_pane/menu_000.visible = true
	
	if not FileAccess.file_exists(tools_path + "settings.smu"):
		print("Creating settings file")
		var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.WRITE_READ)
		settings_file.store_8(0)
		settings_file.store_8(0)
		
		settings_file.close()
	else:
		var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.READ)
		if number_to_bool(settings_file.get_8()):
			print("CFG - Force easy to read font")
		if number_to_bool(settings_file.get_8()):
			print("CFG - Force simple color interface")
			_basic_colors()
		if number_to_bool(settings_file.get_8()):
			print("CFG - Force disable VFX")

func _basic_colors():
	$bg/bg_001.visible = false
	$bg/CPUParticles2D.visible = false
	$bg/TextureRect2.visible = false
	
		
func _clear_temp_directory():
	var output = []
	for file in DirAccess.get_directories_at(data_path):
		OS.execute("rm", ["-f", "-r", "-v", data_path + file], output)
	print(output)


func _getDroppedFiles(files):
	print(files)
	if len(files) > 1:
		GlobalVariables.error( "Multiple files detected! Make sure you only drag and drop one!")
	filePath = files[0]
	var extension = filePath.get_extension()
	print(extension)
	if extension.to_lower() == "dtt" or extension.to_lower() == "dat":
		LoadedFile = FileAccess.open(filePath, FileAccess.READ)
		if LoadedFile.get_16() == 16708:
			var start_time = Time.get_ticks_msec()
			print("DAT or DTT was successfully verified")
			FileType = extension
			GlobalVariables.menu_state = 1
			var output = []
			$right_pane/menu_000/Label.text = "[center]Loading, please wait[/center]"
			await get_tree().create_timer(0.1).timeout
			Uuid._init()
			uuid = Uuid.as_string()
			print("Unpacking DAT file using Platinum_dat_tool.exe")
			DirAccess.make_dir_absolute(data_path + uuid)
			DirAccess.copy_absolute(filePath, data_path + uuid + "/data." + extension)
			OS.execute(tools_path + "platinum_dat_tool.exe", [(data_path + uuid + "/data." + extension)], output)
			
			
			get_tree().get_root().files_dropped.disconnect(_getDroppedFiles)
			_build_file_info(uuid, filePath)
			$right_pane/menu_directory_explorer.visible = true
			$right_pane/menu_directory_explorer._build_directory(data_path + uuid)
			$right_pane/menu_000.visible = false
			$toolbar/ColorRect/buttonscontainer/file.text = "SAVE TO " + extension.to_upper()
			IsDatLoaded = true
			LoadedFile.close()
			var end_time = Time.get_ticks_msec()
			print("TOTAL TIME: " + str(end_time - start_time) + "ms")
	else:
		GlobalVariables.error( "This file '." + extension + "' is not supported. Only DAT and DTT files are supported at the moment")
		

func _build_file_info(uuid, file):
	$datinfo.text = "FILE INFO:\nType:\n." + FileType + "\nName:\n" + file.get_file()
	


		
func _process(delta):
	pass


func _on_file_pressed():
	if IsDatLoaded:
		print("WRITING DAT")
		var path = (data_path + uuid + "/data_dat")
		print(path)
		var output = []
		OS.execute(tools_path + "platinum_dat_tool.exe", [path], output)
		if len(output) < 2:
			GlobalVariables.error(FileType.to_upper() + " repacking failed!\nUnkown Critical Error")
	else:
		GlobalVariables.error("You must load a DAT file before saving it")

func number_to_bool(num):
	if num == 1:
		return true
	elif num == 0:
		return false
		
func bool_to_num(inp):
	if inp:
		return 1
	else:
		return 0

func _on_settings_pressed():
	for child in $right_pane.get_children():
		child.visible = false
	$right_pane/menu_settings.visible = true
	
	var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.READ)
	# Settings stored in heirarchy order for now
	$right_pane/menu_settings/VBoxContainer/forceeasy.button_pressed = number_to_bool(settings_file.get_8())
	$right_pane/menu_settings/VBoxContainer/simplecolors.button_pressed = number_to_bool(settings_file.get_8())
	$right_pane/menu_settings/VBoxContainer/disablevfx.button_pressed = number_to_bool(settings_file.get_8())
	
	
	# Make sure this stays here so no memory leaks :D 
	settings_file.close()
	


func _on_directory_pressed():
	if IsDatLoaded:
		for child in $right_pane.get_children():
			child.visible = false
		$right_pane/menu_directory_explorer.visible = true
		$toolbar/ColorRect/view_drop_down.visible = false

func _on_view_pressed():
	if $toolbar/ColorRect/view_drop_down.visible == false:
		$toolbar/ColorRect/view_drop_down.visible = true
	else:
		$toolbar/ColorRect/view_drop_down.visible = false


func _on_save_pressed():
	print("saving")
	var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.WRITE_READ)
	# Settings stored in heirarchy order for now
	settings_file.store_8(bool_to_num($right_pane/menu_settings/VBoxContainer/forceeasy.button_pressed))
	settings_file.store_8(bool_to_num($right_pane/menu_settings/VBoxContainer/simplecolors.button_pressed))
	settings_file.store_8(bool_to_num($right_pane/menu_settings/VBoxContainer/disablevfx.button_pressed))
	
	
	# Make sure this stays here so no memory leaks :D 
	settings_file.close()

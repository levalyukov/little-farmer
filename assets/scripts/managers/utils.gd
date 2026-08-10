extends Node

# =============================================================================================
# (utils.gd)
# =============================================================================================
# Вспомогательные команды
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Не взаимодействует с самой игрой, максимум команды ОС, файловой системой и т.д.
#
# ЗАВИСИМОСТИ:
# - DirAccess - файловая система
# - OS - работа с ОС
# 
# =============================================================================================

func create_directory(file_path:String) -> void:
	var error = DirAccess.make_dir_recursive_absolute(file_path)
	if error != OK:
		push_error("Invalid error: " + str(error))

func remove_directory(file_path:String) -> void:
	var error = DirAccess.remove_absolute(file_path)
	if error != OK:
		push_error("Invalid error: " + str(error))

func delete_file(path:String) -> bool:
	var dir = DirAccess.open(path.get_base_dir())
	if dir && dir.file_exists(path.get_file()):
		return dir.remove(path.get_file())
	else:
		push_error("Target file does not exist: ", path)
		return false

func delete_files_in_folder(folder_path:String) -> void:
	var dir = DirAccess.open(folder_path)
	for file in dir.get_files():
		dir.remove(file)

func delete_folder(folder_path:String) -> bool:
	var dir = DirAccess.open(folder_path.get_base_dir())
	if dir:
		if dir.dir_exists(folder_path):
			if remove_folder_recursive(dir, folder_path):
				return true
	return false

func remove_folder_recursive(dir: DirAccess, folder_path: String) -> bool:
	if dir.change_dir(folder_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				if not remove_folder_recursive(dir, file_name):
					return false
			else:
				if dir.remove(file_name) != OK:
					return false
			file_name = dir.get_next()

		dir.list_dir_end()
		dir.change_dir("..")

		if dir.remove(folder_path) != OK:
			return false
		return true

	return false

func take_screenshot():
	var viewport = get_viewport()
	var texture = viewport.get_texture()
	var image = texture.get_image()
	var main_directory = DirAccess.open("user://game")
	var target_directory = DirAccess.open("user://game/.screenshots")
	var file_name = "user://game/.screenshots/screenshot-" + str(Time.get_date_string_from_system()) + "-" + str(Time.get_ticks_msec()) + ".png".format(Time.get_ticks_msec())
	if main_directory:
		if target_directory:
			if image.save_png(file_name) == OK:
				print("Screenshot saved: " + str(file_name), "info")
				# if notice:
				# 	notice.create_notice(
				# 		"screenshot-" + 
				# 		str(Time.get_date_string_from_system()) + "-" + str(Time.get_ticks_msec()) 
				# 		+ ".png", "photo"
				# 	)
			else:
				print("Couldn't save screenshot", "error")
		else:
			create_directory("user://game/.screenshots")
			take_screenshot()
	else:
		create_directory("user://game")
		take_screenshot()

func remove_suffix(input:String) -> String:
	var regex = RegEx.new()
	regex.compile("_[0-9]+$")
	return regex.sub(input, "")

func get_suffix_from_name(input:String) -> int:
	if input.find("_") == -1:
		return 0
	var parts = input.split("_")
	if parts.size() > 1:
		var suffix = parts[parts.size() - 1]
		return int(suffix)
	return 0

func check_probability(percent:float) -> bool:
	if randf() < percent / 100.0:
		return true
	return false

func open_url(url:String) -> void:
	OS.shell_open(url)
	print("Redirection to a website: "+url)

func open_folder_in_explorer(folder_path:String):
	var command = ""
	var arguments = []
	var real_path = ProjectSettings.globalize_path(folder_path)
	var dir = DirAccess.open(folder_path)
	if !dir:
		create_directory(folder_path)
		open_folder_in_explorer(folder_path)
	else:
		if OS.get_name() == "Windows":
			var windows_path = real_path.replace("/", "\\")
			print(windows_path)
			command = "explorer.exe"
			arguments = [windows_path]
		OS.execute(command, arguments)
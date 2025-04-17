extends Node

class_name FileSystem
class Funcs:
	static func create_directory(file_path:String) -> void:
		var error = DirAccess.make_dir_recursive_absolute(file_path)
		if error != OK:
			push_error("Invalid error: " + str(error))

	static func remove_directory(file_path:String) -> void:
		var error = DirAccess.remove_absolute(file_path)
		if error != OK:
			push_error("Invalid error: " + str(error))

	static func delete_file(path:String) -> bool:
		var dir = DirAccess.open(path.get_base_dir())
		if dir and dir.file_exists(path.get_file()):
			return dir.remove(path.get_file())
		else:
			print("Target file does not exist: ", path)
			return false

func delete_files_in_folder(folder_path:String) -> void:
	var dir = DirAccess.open(folder_path)
	for file in dir.get_files():
		dir.remove(file)

func delete_folder(folder_path:String) -> bool:
	var dir = DirAccess.open(folder_path.get_base_dir())
	if dir:
		if dir.dir_exists(folder_path):
			if _remove_folder_recursive(dir, folder_path):
				return true
	return false

func _remove_folder_recursive(dir: DirAccess, folder_path: String) -> bool:
	if dir.change_dir(folder_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if not _remove_folder_recursive(dir, file_name):
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
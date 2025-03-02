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

	static func delete_file(path: String) -> bool:
		var dir = DirAccess.open(path.get_base_dir())
		if dir and dir.file_exists(path.get_file()):
			return dir.remove(path.get_file())
		else:
			print("Target file does not exist: ", path)
			return false

	static func delete_folder(path: String) -> bool:
		var dir = DirAccess.open(path.get_base_dir())
		if dir and dir.dir_exists(path.get_file()):
			return dir.remove_recursive(path.get_file())
		else:
			print("Target folder does not exist: ", path)
			return false
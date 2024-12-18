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
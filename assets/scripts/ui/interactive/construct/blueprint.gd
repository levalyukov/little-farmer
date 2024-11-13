extends Control

@onready var main_scene = str(get_tree().root.get_child(1).name)
@onready var manager:Node2D = get_node("/root/" + main_scene)
@onready var build:Control = get_node("/root/" + main_scene + "/UI/Interactive/ConstructMenu")
@onready var icon:TextureRect = $Button/HBoxContainer/MarginContainer/Icon
@onready var caption:Label = $Button/HBoxContainer/Caption
@onready var index:int

var blueprints = Blueprints.new()

func set_data(id) -> void:
	if blueprints.content.has(id):
		self.index = id
		if blueprints.content[id].has("caption"):
			if typeof(blueprints.content[id]["caption"]) == TYPE_STRING and caption.text is String:
				caption.text = str(blueprints.content[index]["caption"])
			else:
				print_debug("\n"+str(manager.get_system_datetime()) + " ERROR: The 'caption' key has a non-string type. Variant.type: " + str(typeof(blueprints.content[id]["caption"])))
		else:
			print_debug("\n"+str(manager.get_system_datetime()) + " ERROR: The object does not have the 'caption' key.")

		if blueprints.content[id].has("icon"):
			if typeof(blueprints.content[id]["icon"]) == TYPE_OBJECT and icon.texture is CompressedTexture2D:
				icon.texture = blueprints.content[index]["icon"]
			else:
				print_debug("\n"+str(manager.get_system_datetime()) + " ERROR: The key stores a non-Compressed 2D Texture. Variant.type: " + str(typeof(blueprints.content[id]["icon"])))
		else:
			print_debug("\n"+str(manager.get_system_datetime()) + " ERROR: The object does not have the 'icon' key.")
		visible = true
	else:
		print_debug("\n"+str(manager.get_system_datetime()) + " ERROR: Invalid object index: " + str(id))
		queue_free()

func check_node(id) -> bool:
	if blueprints.content.has(id):
		return true
	return false

func _on_button_pressed() -> void:
	build.get_data(index)

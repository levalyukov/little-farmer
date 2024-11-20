extends Control

@onready var main_scene = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/" + main_scene)
@onready var build:Control = get_node("/root/" + main_scene + "/UI/Interactive/ConstructMenu")
@onready var icon:TextureRect = $Button/HBoxContainer/MarginContainer/Icon
@onready var caption:Label = $Button/HBoxContainer/Caption
@onready var index:int

var blueprints = Blueprints.new()

func set_data(id) -> void:
	if blueprints.content.has(id):
		self.index = id
		if blueprints.content[id].has("caption"):
			if blueprints.content[index]["caption"] is String:
				caption.text = str(blueprints.content[index]["caption"])
			else:
				data.debug("The 'caption' key has a non-string type.", "error")
		else:
			data.debug("The object does not have the 'caption' key.", "error")

		if blueprints.content[id].has("icon"):
			if blueprints.content[index]["icon"] is CompressedTexture2D:
				icon.texture = blueprints.content[index]["icon"]
			else:
				data.debug("The key stores a non-Compressed 2D Texture.", "error")
		else:
			data.debug("The object does not have the 'icon' key.", "error")
		visible = true
	else:
		data.debug("Invalid object index: " + str(id), "error")
		queue_free()

func check_node(id) -> bool:
	if blueprints.content.has(id):
		return true
	return false

func _on_button_pressed() -> void:
	build.get_data(index)

extends Control

@onready var main_scene = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/" + main_scene)
@onready var construct:Control = get_node("/root/" + main_scene + "/UI/Interactive/ConstructMenu")
@onready var icon:TextureRect = $Button/HBoxContainer/MarginContainer/Icon
@onready var caption:Label = $Button/HBoxContainer/Caption

var index:int
var section:String

func set_data(group:String, id:int) -> void:
	var blueprints = Blueprints.new()
	if blueprints.content.has(group):
		if blueprints.content[group].has(id):
			index = id
			section = group
			if blueprints.content[group][id].has("icon"):
				if blueprints.content[group][id]["icon"] is CompressedTexture2D:
					icon.texture = blueprints.content[group][id]["icon"]
				else:
					data.debug("["+str(id)+"] "+"The key stores a non-Compressed 2D Texture.", "warning")
			else:
				data.debug("["+str(id)+"] "+"The object does not have the 'icon' key.", "warning")

			if blueprints.content[group][id].has("caption"):
				caption.text = str(blueprints.content[group][id]["caption"])
			else:
				data.debug("["+str(id)+"] "+"The 'caption' key has a non-string type.", "warning")

func _on_button_pressed() -> void:
	construct.get_data(section, index)

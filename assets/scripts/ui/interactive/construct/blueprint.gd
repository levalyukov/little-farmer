extends Control

@onready var main_scene = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/" + main_scene)
@onready var construct:Control = get_node("/root/" + main_scene + "/UI/Interactive/ConstructMenu")
@onready var icon:TextureRect = $Button/HBoxContainer/MarginContainer/Icon
@onready var caption:Label = $Button/HBoxContainer/Caption

var index:int
var section:String

func set_data(group:String, id:int) -> void:
	var blueprints = BlueprintManager.new()
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
	if visible:
		construct.get_data(section, index)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/click.ogg')
		audio.play()

func _on_button_mouse_entered():
	if visible:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()




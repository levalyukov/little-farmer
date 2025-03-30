extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var construct:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var blueprintsShop:Control = get_node("/root/"+main+"/UI/Interactive/BlueprintsShop")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

@onready var icon:TextureRect = $Button/HBoxContainer/MarginContainer/Icon
@onready var caption:Label = $Button/HBoxContainer/Caption
@onready var button:Button = $Button

const MAX_SYMBOLS:int = 16

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
				caption.text = blueprints.content[group][id]["caption"]
			else:
				data.debug("["+str(id)+"] "+"The 'caption' key has a non-string type.", "warning")

func disabled_button(state:bool, additional_string:String):
	button.disabled = state
	if state:
		caption.modulate = Color(1, 1, 1, 0.784)
		icon.modulate = Color(1, 1, 1, 0.784)
	else:
		caption.modulate = Color(1, 1, 1)
		icon.modulate = Color(1, 1, 1)

	if additional_string != "":
		if len(caption.get_text()) > MAX_SYMBOLS:
			caption.text = caption.text.substr(0,MAX_SYMBOLS) + "... " + additional_string
		else:
			caption.text = caption.text + " " + additional_string

func _on_button_pressed() -> void:
	if visible:
		if construct:
			if construct.visible:
				construct.get_data(section, index)
		if blueprintsShop:
			if blueprintsShop.visible:
				blueprintsShop.get_data(section, index)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/click.ogg')
		audio.play()

func _on_button_mouse_entered():
	if visible:
		if !button.disabled:
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/hover.ogg')
			audio.play()
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(node) -> void:
	node.queue_free()
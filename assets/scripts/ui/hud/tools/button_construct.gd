extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var craft:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/hammer.png")
@onready var icon:TextureRect = $Main/Margin/Icon
@onready var button:Button = $Main/Button

func _ready() -> void:
	icon.texture = sprite
	if main != "Farm":
		button.disabled = true
		icon.modulate = Color(1, 1, 1, 0.686)

func _on_button_pressed() -> void:
	if !pause.paused:
		if !blur.state:
			craft.open()
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_button_mouse_entered():
	if !blur.state:
		if !pause.paused:
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/hover.ogg')
			audio.play()
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)
			if tip: tip.tooltip('Меню строительства')

func _on_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if tip: tip.tooltip()

func _on_audio_finished(node) -> void:
	node.queue_free()



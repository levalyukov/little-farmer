extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/hoe.png")
@onready var icon:TextureRect = $Main/Margin/Icon
@onready var button:Button = $Main/Button

func _ready() -> void:
	icon.texture = sprite
	if main != "Farm"\
	&& main != "Greenhouse":
		button.disabled = true
		icon.modulate = Color(1, 1, 1, 0.686)

func _on_button_pressed() -> void:
	if !pause.paused:
		if has_node("/root/"+main+"/ConstructionManager")\
		&& has_node("/root/"+main+"/ConstructionManager/Grid"):
			if !blur.state:
				grid.grid_dimensions = tools.features["hoe"][tools.hoe]["grid_dimensions"]
				grid.mode = grid.modes.FARMING
				grid.visible = true
				grid.generate_grid()
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
			if tip: tip.tooltip(tr('ui.tools.create_farmlands_button'))

func _on_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if tip: tip.tooltip()
				
func _on_audio_finished(node) -> void:
	node.queue_free()

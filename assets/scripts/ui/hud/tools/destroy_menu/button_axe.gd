extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/destroy_plant.png")
@onready var icon:TextureRect = $Main/Margin/Icon

func _ready() -> void:
	icon.texture = sprite

func _on_button_pressed() -> void:
	if !pause.paused:
		if has_node("/root/"+main+"/ConstructionManager")\
		&& has_node("/root/"+main+"/ConstructionManager/Grid"):
			if !blur.state:
				grid.grid_dimensions = tools.features["destroy"][tools.destroy]["grid_dimensions"]
				grid.mode = grid.modes.DESTROY
				grid.destroy_mode = grid.destroy.NATURE
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

func _on_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)			

func _on_audio_finished(node) -> void:
	node.queue_free()



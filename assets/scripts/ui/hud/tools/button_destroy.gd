extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud/")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/trash.png")
@onready var icon:TextureRect = $Main/Margin/Icon
@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var button:Button = $Main/Button

var destroyMode:bool = false

func _ready() -> void:
	icon.texture = sprite
	if main != "Farm"\
	&& main != "Greenhouse":
		button.disabled = true
		icon.modulate = Color(1, 1, 1, 0.686)

func _input(event):
	if !pause.paused\
	&& !hud.visible\
	&& destroyMode:
		hud.hud_all_hide()
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_RIGHT\
		&& event.is_pressed():
			destroyMode = !true
			hud.hud_all_show()

func _on_button_pressed() -> void:
	if has_node("/root/"+main+"/ConstructionManager")\
	&& has_node("/root/"+main+"/ConstructionManager/Grid"):
		if !blur.state:
			if !destroy_menu.opened:
				destroy_menu.open()
			else:
				destroy_menu.close()
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
			
func _on_audio_finished(node) -> void:
	node.queue_free()

func _on_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var crafting:Control = get_node("/root/"+main+"/UI/Interactive/Crafting")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var fps_label:MarginContainer = get_node("/root/"+main+"/UI/MarginContainer")
@onready var anim:AnimationPlayer = $AnimationHud
@onready var fpsLabel:Label = $Main/FPS

var hud:bool	
var state:bool = true

func _input(_event):
	if !pause.paused\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if Input.is_action_just_pressed("f1"):
			if state:
				hud_all_hide()
				state = false
			else:
				hud_all_show()
				state = true

func hud_all_hide() -> void:
	anim.play("hide_all")
	fps_label.visible = false
	hud = false
	
func hud_all_show() -> void:
	anim.play("show_all")
	fps_label.visible = true
	hud = true

func window() -> void:
	visible = hud

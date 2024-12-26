extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@onready var ui:CanvasLayer = get_node("/root/"+main+"/UI")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var options:Control = get_node("/root/"+main+"/UI/Interactive/Options")
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var zoom:Camera2D = get_node("/root/"+main+"/Player/Camera2D")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var version:Label = $MarginContainer/MarginContainer/container/version/version

var paused:bool
var other_menu:bool

func _ready():
	player.switch = true
	player.check_switch()
	await get_tree().create_timer(0.75).timeout
	player.switch = true
	zoom.zooming = false
	zoom.change_zoom = true
	blackout.blackout(false)
	await get_tree().create_timer(0.25).timeout
	hud.state(false, "all")
	player.switch = false
	player.check_switch()
	clock.clock_update()

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if !other_menu:
			if !paused:
				open()
			else:
				close()
	
func open() -> void:
	paused = true
	anim.play("open")
	blur.blur(true)
	hud.state(true, "all")
	player.check_switch()
	version.text = "v"+str(ProjectSettings.get_setting("application/config/version"))
	if has_node("/root/"+main+"/ConstructionManager/Grid"):
		grid.visible = false
	if destroy_menu.opened:
		destroy_menu.close()
		
func close() -> void:
	paused = false
	anim.play("close")
	blur.blur(false)
	hud.state(false, "all")
	player.check_switch()

func _check_window() -> void:
	visible = paused

extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var button_trash:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu/MarginContainer/MarginContainer/HBoxContainer/ButtonTrash")
@onready var button_axe:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu/MarginContainer/MarginContainer/HBoxContainer/ButtonAxe")
@onready var button_pickaxe:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu/MarginContainer/MarginContainer/HBoxContainer/ButtonPickaxe")
@onready var button_bomb:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyBomb")

var opened:bool = false

func _ready():
	close()

func open():
	opened = true
	animation.play("open")

func close():
	opened = false
	animation.play("close")

func _visible():
	visible = opened

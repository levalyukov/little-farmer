extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

func _process(_delta):
	if main == "Village":
		if visible:
			visible = false
	else:
		if !visible:
			visible = true

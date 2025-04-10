extends Control
 
@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var container:MarginContainer = $Container
@onready var label:Label = $Container/MarginContainer/Label

var tip:bool
var mouse_binding_global:bool = false
const threshold:int = 100

func _process(_delta):
	if tip:
		if mouse_binding_global:
			position = get_global_mouse_position()
		else:
			position = Vector2(get_global_mouse_position().x - container.size.x, get_global_mouse_position().y)

func tooltip(text:String = "") -> void:
	if text != "":
		tip = true
		label.text = text
		if !visible:
			visible = true
	else:
		tip = false
		if visible:
			visible = false

	if cursor:
		var viewport_size = get_viewport_rect().size
		var screen_width = viewport_size.x
		var node_global_pos = get_global_mouse_position()
		var node_size = get_size()
		var right_edge = node_global_pos.x + node_size.x
		if right_edge > screen_width - threshold:
			mouse_binding_global = false
		else:
			mouse_binding_global = true
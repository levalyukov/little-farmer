extends Control
 
@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

@onready var background:NinePatchRect = $Container/Background
@onready var container:MarginContainer = $Container
@onready var label:Label = $Container/MarginContainer/Label

func _process(_delta):
	if self.visible:
		var _viewport_size = get_viewport_rect().size
		var _screen_width = _viewport_size.x
		var _mouse_global_pos = get_global_mouse_position()
		var _right_edge_x = _mouse_global_pos.x
		var _right_edge_y = _mouse_global_pos.y

		var _threshold_x = background.size.x
		var _threshold_y = background.size.y

		if _right_edge_x > _screen_width - _threshold_x && !(_right_edge_y < _threshold_y):
			position = Vector2(
					get_global_mouse_position().x - container.size.x, 
					get_global_mouse_position().y
				)

		elif _right_edge_y < _threshold_y && !(_right_edge_x > _screen_width - _threshold_x):
			position = Vector2(
					get_global_mouse_position().x, 
					get_global_mouse_position().y + container.size.y + 32
				)

		elif (_right_edge_y < _threshold_y) && (_right_edge_x > _screen_width - _threshold_x):
			position = Vector2(
					get_global_mouse_position().x - container.size.x, 
					get_global_mouse_position().y + container.size.y + 32
				)
		else:
			position = get_global_mouse_position()
	else:
		set_process(false)

func tooltip(text:String = "") -> void:
	if pause:
		if !pause.paused\
		&& grid.mode == grid.modes.NOTHING\
		|| grid.mode == grid.modes.WATERING:
			if text != "":
				label.text = text
				if !visible:
					set_process(true)
					visible = true
			else:
				if visible:
					visible = false
		else:
			if visible:
				visible = false

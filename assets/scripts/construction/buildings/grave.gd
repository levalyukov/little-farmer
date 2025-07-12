extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var dialogWindow:Control = get_node("/root/"+main+"/UI/Interactive/DialogWindow")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var sprite:Sprite2D = $Sprite2D

@export var grave_index:int
@onready var dialogMenu:bool = false
var graves:Dictionary = {
	1: {
		'idle' = load('res://assets/resources/buildings/graves/grave_1/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_1/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_1/shadow.png'),
	},
	2: {
		'idle' = load('res://assets/resources/buildings/graves/grave_2/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_2/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_2/shadow.png'),
	},
	3: {
		'idle' = load('res://assets/resources/buildings/graves/grave_3/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_3/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_3/shadow.png'),
	},
	4: {
		'idle' = load('res://assets/resources/buildings/graves/grave_4/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_4/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_4/shadow.png'),
	},
	5: {
		'idle' = load('res://assets/resources/buildings/graves/grave_5/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_5/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_5/shadow.png'),
	},
	6: {
		'idle' = load('res://assets/resources/buildings/graves/grave_6/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_6/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_6/shadow.png'),
	},
	7: {
		'idle' = load('res://assets/resources/buildings/graves/grave_7/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_7/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_7/shadow.png'),
	},
	8: {
		'idle' = load('res://assets/resources/buildings/graves/grave_8/object_0.png'),
		'hovered' = load('res://assets/resources/buildings/graves/grave_8/object_1.png'),
		'shadow' = load('res://assets/resources/buildings/graves/grave_8/shadow.png'),
	},
}

func _ready():
	set_groves(grave_index)

#	func _input(event):
#		if event is InputEventMouseButton\
#		&& event.button_index == MOUSE_BUTTON_LEFT\
#		&& event.is_pressed()\
#		&& !blur.state\
#		&& grid.mode == grid.modes.NOTHING\
#		&& dialogMenu:
#			if graves.has(grave_index):
#				if graves[grave_index].has('dialog'):
#					if graves[grave_index]['dialog'].has('caption')\
#					&& graves[grave_index]['dialog'].has('mainContent')\
#					&& graves[grave_index]['dialog'].has('buttonCaptions')\
#					&& graves[grave_index]['dialog'].has('buttonFunc'):
#						if cursor: cursor.set_cursor(cursor.states.DEFAULT)
#						dialogWindow.dialogWindow(
#							graves[grave_index]['dialog']['caption'],
#							graves[grave_index]['dialog']['mainContent'],
#							graves[grave_index]['dialog']['buttonCaptions'],
#							graves[grave_index]['dialog']['buttonFunc'],
#						)
#						if graves.has(grave_index):
#							if graves[grave_index].has('idle'):
#								sprite.texture = graves[grave_index]['idle']

func set_groves(index:int) -> void:
	if graves.has(index):
		if graves[index].has('idle'):
			sprite.texture = graves[index]['idle']
		if graves[index].has('shadow'):
			if graves[index]['shadow'] is CompressedTexture2D:
				canvas.create_shadow(
					"grave_"+str(index)+"_shadow", 
					graves[index]['shadow'], 
					tilemap.local_to_map(position)
				)

func _on_area_2d_mouse_entered():
	pass
	#	if !blur.state\
	#	&& grid.mode == grid.modes.NOTHING:
	#		dialogMenu = true
	#		if graves.has(grave_index):
	#			if graves[grave_index].has('dialog'):
	#				if graves[grave_index]['dialog'].has('caption')\
	#				&& graves[grave_index]['dialog'].has('mainContent')\
	#				&& graves[grave_index]['dialog'].has('buttonCaptions')\
	#				&& graves[grave_index]['dialog'].has('buttonFunc'):
	#					if cursor: cursor.set_cursor(cursor.states.EXPLORE)
	#					if graves[grave_index].has('hovered'): sprite.texture = graves[grave_index]['hovered']

func _on_area_2d_mouse_exited():
	dialogMenu = !true
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if graves.has(grave_index):
		if graves[grave_index].has('idle'):
			sprite.texture = graves[grave_index]['idle']

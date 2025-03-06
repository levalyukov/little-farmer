extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var stoneOvenMenu:Control = get_node("/root/"+main+"/UI/Interactive/StoneOvenMenu")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D
@onready var particles:CPUParticles2D = $CPUParticles2D
@onready var timer:Timer = $Timer

var blueprint_id:int = 0
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var level:int = 1
var ore_amount:int = 0
var fuel_amount:int = 0

var stoneMenuOpen:bool = false
var inProcessed:bool = false
var value_process:float = 0.0
var ignot_done:bool = false

var object:Dictionary = {
	1: {
		"caption" = tr("Каменная плавильня"),
		"description" = tr("Позволяет переплавлять руду."),
		"default_idle" = load("res://assets/resources/buildings/stone_oven/object_0.png"),
		"hovered_idle" = load("res://assets/resources/buildings/stone_oven/hovered_0.png"),
		"delete" = load("res://assets/resources/buildings/stone_oven/object_2.png")
	}
}

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& !buttonDestroy.destroyMode\
	&& grid.mode == grid.modes.NOTHING\
	&& stoneMenuOpen:
		stoneOvenMenu.open(self)

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		buildings.remove_node(self, all_collisions)

func _on_area_2d_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if !inProcessed:
			if buttonDestroy.destroyMode:
				destroyMode = true
				if object.has(level):
					if object[level].has('delete'):
						if object[level]['delete'] is CompressedTexture2D:
							sprite.texture = object[level]['delete']
			else:
				if object.has(level):
					if object[level].has('hovered_idle'):
						if object[level]['hovered_idle'] is CompressedTexture2D:
							sprite.texture = object[level]['hovered_idle']
				if tip:
					tip.tooltip(
						str(object[level]['caption']) + "\n" + str(object[level]['description'])
					)

		if !stoneMenuOpen:
			stoneMenuOpen = true

func _on_area_2d_mouse_exited():
	if object.has(level):
		if object[level].has('default_idle'):
			if object[level]['default_idle'] is CompressedTexture2D:
				sprite.texture = object[level]['default_idle']
	if tip:
		tip.tooltip()
	if stoneMenuOpen:
		stoneMenuOpen = !true
	if destroyMode:
		destroyMode = false

func get_data() -> Dictionary:
	return {
		"level": level,
		"position": tilemap.local_to_map(position),
		"id": blueprint_id,
	}

func start_melt(ore:int, fuel:int) -> void:
	ore_amount = ore
	fuel_amount = fuel
	inProcessed = true
	timer.start()

func _on_timer_timeout():
	value_process += randf_range(0.1, 5.0)

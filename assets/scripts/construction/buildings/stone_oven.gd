extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var stoneOvenMenu:Control = get_node("/root/"+main+"/UI/Interactive/StoneOvenMenu")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var light:PointLight2D = $Light
@onready var sprite:Sprite2D = $Sprite2D
@onready var particles:CPUParticles2D = $CPUParticles2D
@onready var timer:Timer = $Timer

var items:Object = Items.new()
var blueprint_id:int = 0
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var level:int = 1
var ore_id = 0
var ore_amount:int = 0
var fuel_id = 0
var fuel_amount:int = 0
var ignot_id = 0
var ignot_amount:int = 0

var stoneMenuOpen:bool = false
var inProcessed:bool = false
var value_process:float = 0.0
var isDone:bool = false

var object:Dictionary = {
	1: {
		"caption" = tr("Каменная плавильня"),
		"description" = tr("Позволяет переплавлять руду."),
		"default_idle" = load("res://assets/resources/buildings/stone_oven/object_0.png"),
		"hovered_idle" = load("res://assets/resources/buildings/stone_oven/hovered_0.png"),
		"default_work" = load("res://assets/resources/buildings/stone_oven/object_1.png"),
		"hovered_work" = load("res://assets/resources/buildings/stone_oven/hovered_1.png"),
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

func update() -> void:
	if !inProcessed:
		if object.has(level):
			if object[level].has('default_idle'):
				if object[level]['default_idle'] is CompressedTexture2D:
					sprite.texture = object[level]['default_idle']
	else:
		if object.has(level):
			if object[level].has('default_work'):
				if object[level]['default_work'] is CompressedTexture2D:
					sprite.texture = object[level]['default_work']

func _process(_delta):
	if pause.paused:
		if particles.emitting:
			if particles.speed_scale > 0.0:
				particles.speed_scale = 0.0
	else:
		if particles.emitting:
			if particles.speed_scale == 0.0:
				particles.speed_scale = 0.5

	if !isDone:
		if inProcessed:
			if !light.visible:
				light.visible = true

			if !particles.emitting:
				particles.emitting = true

			if value_process >= 100.0:
				if items.content.has(int(ore_id)):
					value_process = 100.0
					ignot_id = items.content[int(ore_id)]['oven_result']
					ignot_amount = ore_amount / 5
					inProcessed = false
					isDone = true
					timer.stop()
					ore_id = null
					ore_amount = 0
					fuel_id = null
					fuel_amount = 0
					update()
					if stoneOvenMenu.visible:
						stoneOvenMenu.check_button_state()
	else:
		if light.visible:
			light.visible = !true
		if particles.emitting:
			particles.emitting = false

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
		else:
			if !buttonDestroy.destroyMode:
				if object.has(level):
					if object[level].has('hovered_work'):
						if object[level]['hovered_work'] is CompressedTexture2D:
							sprite.texture = object[level]['hovered_work']
				if tip:
					tip.tooltip(
						str(object[level]['caption']) + "\n" + str(object[level]['description'])
					)

		if !stoneMenuOpen:
			stoneMenuOpen = true

func _on_area_2d_mouse_exited():
	if !inProcessed:
		if object.has(level):
			if object[level].has('default_idle'):
				if object[level]['default_idle'] is CompressedTexture2D:
					sprite.texture = object[level]['default_idle']
	else:
		if object.has(level):
			if object[level].has('default_work'):
				if object[level]['default_work'] is CompressedTexture2D:
					sprite.texture = object[level]['default_work']
	if tip:
		tip.tooltip()
	if stoneMenuOpen:
		stoneMenuOpen = !true
	if destroyMode:
		destroyMode = false

func start_melt(oreID:int, oreAmount:int, fuelID:int, fuelAmount:int) -> void:
	ore_id = oreID
	fuel_id = fuelID
	ore_amount = oreAmount
	fuel_amount = fuelAmount
	inProcessed = true
	timer.wait_time = 2.5
	timer.start()
	update()

func _on_timer_timeout():
	if !pause.paused:
		if value_process <= 100.0:
			value_process += randf_range(0.01, 5)

func get_data() -> Dictionary:
	return {
		"level": level,
		"position": tilemap.local_to_map(position),
		"id": blueprint_id,
		'inProcessed': inProcessed,
		'value': value_process,
		'isDone': isDone,
		'oreID': ore_id,
		'oreAmount': ore_amount,
		'fuelID': fuel_id,
		'fuelAmount': fuel_amount,
		'ignotID': ignot_id,
		'ignotAmount': ignot_amount
	}

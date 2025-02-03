extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
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
@onready var compostMenu:Control = get_node("/root/"+main+"/UI/Interactive/ComposterMenu")
@onready var sprite:Sprite2D = $Sprite2D
@onready var timer:Timer = $Timer

var menu:bool = false
var level:int = 1
var blueprint_id:int = 0
var menuAccess:bool = false
var composting:bool = false
var composting_value:float = 99.0
var compost_items:Dictionary = {}

enum objectState {idle, inProcess, done}
var object:Dictionary = {
	1: {
		"caption" = tr("composter.caption"),
		"description" = tr("composter.description"),
		"shadow" = load("res://assets/resources/buildings/composter/shadow.png"),
		"state" = {
			"idle" = {
				"default" = preload('res://assets/resources/buildings/composter/idle_0.png'),
				"hovered" = preload('res://assets/resources/buildings/composter/idle_1.png'),
			},
			"work" = {
				"default" = preload('res://assets/resources/buildings/composter/active_0.png'),
				"hovered" = preload('res://assets/resources/buildings/composter/active_1.png'),
			}
		}
	},
}

func _ready():
	update()

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& menuAccess:
		compostMenu.open(self)
		update()

func update():
	if clock:
		if object.has(level):
			if composting:
				if object[level]["state"].has("work"):
					if object[level]["state"]['work'].has("hovered"):
						if object[level]["state"]['work']["hovered"] is CompressedTexture2D:
							sprite.texture = object[level]["state"]['work']["hovered"]
						else:
							data.debug("'"+str(self.name) + "': 'hovered' is not a CompressedTexture2D.", "error")
					else:
						data.debug("'"+str(self.name) + "': There is no 'hovered' key.", "error")
				else:
					data.debug("'"+str(self.name) + "': There is no 'work' key.", "error")
			else:
				if object[level].has("state"):
					if object[level]["state"].has("idle"):
						if object[level]["state"]["idle"].has("idle_0"):
							if object[level]["state"]["idle"]["idle_0"] is CompressedTexture2D:
								sprite.texture = object[level]["idle"]["idle_0"]
								self.set_position(tilemap.map_to_local(Vector2i(18,2)))
							else:
								data.debug("'"+str(self.name) + "': 'idle' is not a CompressedTexture2D.", "error")
					else:
						data.debug("'"+str(self.name) + "': There is no 'idle' key.", "error")
		else:
			data.debug("'"+str(self.name) + "': Index " + str(level) + " is not in the dictionary.", "error")

func get_data() -> Dictionary:
	if object.has(level):
		return {
			"level": level,
			'value': composting_value
			}
	return {}

func set_level_obj(obj_level:int) -> void:
	level = obj_level
	update()

func _on_area_2d_mouse_entered() -> void:
	menuAccess = true
	if !blur.state:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < building.max_distance:
			if object.has(level):
				if object[level].has("state"):
					if composting:
						if object[level]["state"].has("work"):
							if object[level]["state"]['work'].has("hovered"):
								if object[level]["state"]['work']["hovered"] is CompressedTexture2D:
									sprite.texture = object[level]["state"]['work']["hovered"]
								else:
									data.debug("'"+str(self.name) + "': 'hovered' is not a CompressedTexture2D.", "error")
							else:
								data.debug("'"+str(self.name) + "': There is no 'hovered' key.", "error")
						else:
							data.debug("'"+str(self.name) + "': There is no 'work' key.", "error")
					else:
						if object[level]["state"].has("idle"):
							if object[level]["state"]['idle'].has("hovered"):
								if object[level]["state"]['idle']["hovered"] is CompressedTexture2D:
									sprite.texture = object[level]["state"]['idle']["hovered"]
								else:
									data.debug("'"+str(self.name) + "': 'hovered' is not a CompressedTexture2D.", "error")
							else:
								data.debug("'"+str(self.name) + "': There is no 'hovered' key.", "error")
						else:
							data.debug("'"+str(self.name) + "': There is no 'idle' key.", "error")
			if tip:
				tip.tooltip(str(object[level]["caption"]) + "\n" +str(object[level]["description"]))

func _on_area_2d_mouse_exited() -> void:
	menuAccess = false
	if object.has(level):
		if object[level].has("state"):
			if composting:
				if object[level]["state"].has("work"):
					if object[level]["state"]['work'].has("default"):
						if object[level]["state"]['work']["default"] is CompressedTexture2D:
							sprite.texture = object[level]["state"]['work']["default"]
						else:
							data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
					else:
						data.debug("'"+str(self.name) + "': There is no 'default' key.", "error")
				else:
					data.debug("'"+str(self.name) + "': There is no 'work' key.", "error")
			else:
				if object[level]["state"].has("idle"):
					if object[level]["state"]['idle'].has("default"):
						if object[level]["state"]['idle']["default"] is CompressedTexture2D:
							sprite.texture = object[level]["state"]['idle']["default"]
						else:
							data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
					else:
						data.debug("'"+str(self.name) + "': There is no 'default' key.", "error")
				else:
					data.debug("'"+str(self.name) + "': There is no 'work' key.", "error")
	if tip:
		tip.tooltip()

func start_compost(time_value:float) -> void:
	timer.start()
	timer.wait_time = time_value

func stop_compost() -> void:
	timer.stop()

func _on_timer_timeout():
	composting_value += randf_range(0.01, 5.0)
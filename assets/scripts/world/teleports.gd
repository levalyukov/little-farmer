extends Node2D

@onready var main:String = GameData.main
@onready var data:Node = get_node("/root/"+main)
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")
@onready var grid:Node2D = get_node("/root/"+main+ "/ConstructionManager/Grid")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var tablet:Node2D = get_node("/root/"+main+"/ConstructionManager/tablet")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
var teleporting:bool

func _input(event) -> void:
	if tablet:
		var distance = round(tablet.global_position.distance_to(player.global_position))
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed()\
		&& teleporting\
		&& grid.mode == grid.modes.NOTHING\
		&& distance < 100:
			teleport()

func teleport() -> void:
	blackout.blackout(true)
	match main:
		"Farm":
			var path:String = "res://levels/village.tscn"
			data.gamesave()
			GameLoader.mode = false
			blackout.change_scene(path)
		"Village":
			var path:String = "res://levels/farm.tscn"
			GameLoader.mode = true
			data.file_save(data.paths.world, "nature")
			data.file_save(data.paths.player, "player")
			data.file_save(data.paths.inventory, "inventory")
			blackout.change_scene(path)
		_:
			data.debug("Unknown name of the game scene: "+str(main), "error")

func _on_area_2d_mouse_entered():
	teleporting = true

func _on_area_2d_mouse_exited():
	teleporting = false

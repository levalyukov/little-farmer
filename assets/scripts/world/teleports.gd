extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")
@onready var grid:Node2D = get_node("/root/"+main+ "/ConstructionManager/Grid")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var tablet:Node2D = get_node("/root/"+main+"/ConstructionManager/tablet")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
var teleporting:bool

func _input(event) -> void:
	if tablet:
		var distance = round(tablet.global_position.distance_to(player.global_position))
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed()\
		&& teleporting\
		&& grid.mode == grid.modes.NOTHING\
		&& !blur.state\
		&& distance < 100:
			teleport()

func teleport() -> void:
	match main:
		"Farm":
			var scene:String = "res://levels/village.tscn"
			data.gamesave()
			GameLoader.mode = false
			get_farm_plants_status()
			blackout.blackout(true)
			blackout.change_scene(scene)
		"Village":
			var scene:String = "res://levels/farm.tscn"
			GameLoader.mode = true
			data.file_save([data.path.data], data.file.world, data.get_dictionary_content("world"))
			data.file_save([data.path.player], data.file.player, data.get_dictionary_content("player"))
			data.file_save([data.path.player], data.file.inventory, data.get_dictionary_content("inventory"))
			get_farm_plants_status()
			blackout.blackout(true)
			blackout.change_scene(scene)
		"Greenhouse":
			if GameLoader.greenhouse_caption != "":
				var scene:String = "res://levels/farm.tscn"
				data.file_save(
					["user://.game/data/farm/greenhouses"],
					"user://.game/data/farm/greenhouses/" + str(GameLoader.greenhouse_caption) + ".json",
					data.get_greenhouse_data()
				)
				data.file_save([data.path.data], data.file.world, data.get_dictionary_content("world"))
				data.file_save([data.path.player], data.file.player, data.get_dictionary_content("player"))
				data.file_save([data.path.player], data.file.inventory, data.get_dictionary_content("inventory"))
				blackout.blackout(true)
				GameLoader.mode = true
				#	GameLoader.get_plants_status()
				GameLoader.greenhouse_caption = ""
				blackout.change_scene(scene)
		_:
			data.debug("Unknown name of the game scene: "+str(main), "error")

func _on_area_2d_mouse_entered():
	if !blur.state:
		teleporting = true

func _on_area_2d_mouse_exited():
	if !blur.state:
		teleporting = false

func get_farm_plants_status():
	match main:
		"Farm":
			var plants = {}
			if farming.get_children() != []:
				for i in farming.get_children():
					if data.remove_suffix(i.name) == 'plant':
						plants[i.name] = {}
						plants[i.name]['timer_left'] = i.timer.get_time_left()
			GameLoader.farm_plants = plants
			GameLoader.timer_plant_start()
		"Village":
			GameLoader.timer_plant_stop()

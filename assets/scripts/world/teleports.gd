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
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
var teleporting:bool

func teleport() -> void:
	match main:
		"Farm":
			var scene:String = "res://levels/village.tscn"
			data.gamesave()
			GameLoader.mode = false
			blackout.blackout(true)
			blackout.change_scene(scene)
			
		"Village":
			var scene:String = "res://levels/farm.tscn"
			GameLoader.mode = true
			data.file_save([data.path.data], data.file.world, data.get_dictionary_content("world"))
			data.file_save([data.path.player], data.file.player, data.get_dictionary_content("player"))
			data.file_save([data.path.player], data.file.blueprints, data.get_dictionary_content("blueprints"))
			data.file_save([data.path.player], data.file.inventory, data.get_dictionary_content("inventory"))
			data.file_save([data.path.player], data.file.mailbox, data.get_dictionary_content("mailbox"))
			blackout.blackout(true)
			blackout.change_scene(scene)
			
		"Greenhouse":
			var scene:String = "res://levels/farm.tscn"
			data.file_save([data.path.data], data.file.world, data.get_dictionary_content("world"))
			data.file_save([data.path.player], data.file.player, data.get_dictionary_content("player"))
			data.file_save([data.path.player], data.file.inventory, data.get_dictionary_content("inventory"))
			data.file_save([data.path.player], data.file.blueprints, data.get_dictionary_content("blueprints"))
			data.file_save([data.path.player], data.file.mailbox, data.get_dictionary_content("mailbox"))
			blackout.blackout(true)
			GameLoader.mode = true
			blackout.change_scene(scene)

func _on_area_2d_body_entered(_body:Node2D):
	if !blur.state && grid.mode == grid.modes.NOTHING:
		teleport()

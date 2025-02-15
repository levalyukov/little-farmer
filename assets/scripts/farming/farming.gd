extends Node2D

@onready var main:String = GameData.main
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var node:PackedScene = load("res://assets/nodes/farming/plant.tscn")

var crops:Object = Crops.new()
var season:bool = false

func create_plant(id:int, vector:Vector2i) -> void:
	var plant = node.instantiate()
	var atlas_coords = Vector2i(0,3)
	var source_id = 0
	
	if collision.check_cell(vector, collision.farmland_layer):
		tilemap.set_cell(collision.crops_layer,vector,source_id,atlas_coords)
		plant.set_position(tilemap.map_to_local(vector))
		add_child(plant)
		plant.z_index = 2
		plant.name = "plant_1"
		plant.plant(id)
		plant.check(vector)

func plant_destroy(vector:Vector2i) -> void:
	for child in get_children():
		if vector == tilemap.local_to_map(child.position):
			remove_child(child)

func check_season(id:int) -> bool:
	var crop_season = crops.crops[id]["season"]
	for i in crop_season:
		if i == clock.get_season():
			return true
	return false

func get_all_plants() -> Dictionary:
	var data_dict = {}
	for plant in get_children():
		if plant.has_method("get_data"):
			var child_data = plant.get_data()
			data_dict[plant.name] = child_data
	return data_dict

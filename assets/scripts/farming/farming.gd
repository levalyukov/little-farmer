extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var plant_node:PackedScene = load("res://assets/nodes/farming/plant.tscn")
@onready var fertilizer_node:PackedScene = load("res://assets/nodes/farming/fertilizer.tscn")

var items:Object = Items.new()
var crops:Object = Crops.new()
var season:bool = false

var atlas_coords = Vector2i(0,3)
var source_id = 0

var plant_check_watering = crops.crops['check_watering']

func create_plant(plant_id:int, vector:Vector2i) -> void:
	var plant = plant_node.instantiate()

	if collision.check_cell(vector, collision.farmland_layer):
		var plant_caption = crops.crops[plant_id]['caption'] if crops.crops[plant_id].has('caption') && crops.crops[plant_id]['caption'] is String else null
		var plant_growth_rate = crops.crops[plant_id]['growth_rate'] if crops.crops[plant_id].has('growth_rate') && crops.crops[plant_id]['growth_rate'] is float else null
		var plant_growth_level = crops.crops[plant_id]['growth_level'] if crops.crops[plant_id].has('growth_level') && crops.crops[plant_id]['growth_level'] is int else null
		var plant_mortality = crops.crops[plant_id]['mortality'] if crops.crops[plant_id].has('mortality') && crops.crops[plant_id]['mortality'] is int else null
		var plant_seasons = crops.crops[plant_id]['season'] if crops.crops[plant_id].has('season') && crops.crops[plant_id]['season'] is Array else null
		var plant_rect_x = crops.crops[plant_id]['X'] if crops.crops[plant_id].has('X') && crops.crops[plant_id]['X'] is int else null
		var plant_rect_y = crops.crops[plant_id]['Y'] if crops.crops[plant_id].has('Y') && crops.crops[plant_id]['Y'] is int else null

		tilemap.set_cell(collision.crops_layer,vector,source_id,atlas_coords)
		plant.set_position(tilemap.map_to_local(vector))
		add_child(plant)
		plant.z_index = 2
		plant.name = "plant_1"
		plant.plant(
			plant_id,
			plant_caption,
			plant_growth_rate,
			plant_check_watering,
			plant_growth_level,
			plant_mortality,
			plant_seasons,
			plant_rect_x,
			plant_rect_y
		)
		plant.check(vector)

func plant_destroy(vector:Vector2i) -> void:
	for child in get_children():
		if vector == tilemap.local_to_map(child.position):
			if data.remove_suffix(child.name) == "plant"\
			|| data.remove_suffix(child.name) == "fertilizer":
				remove_child(child)
				child.queue_free()

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

# fertilizer
func create_fertilizer(id:int, vector:Vector2i) -> void:
	if items.content.has(id):
		if items.content[id].has('item_type'):
			if items.content[id]['item_type'] == 'fertilizer':
				var fertilizer = fertilizer_node.instantiate()
				add_child(fertilizer)
				fertilizer.name = "fertilizer_1"
				fertilizer.z_index = 2
				fertilizer.set_fertilizer(id)
				fertilizer.set_position(tilemap.map_to_local(vector))
				

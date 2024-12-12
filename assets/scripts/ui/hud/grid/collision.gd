extends Node2D

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var default:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/grid/default.png")
@onready var error:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/grid/error.png")

var crops = Crops.new()

const can_place_seed_custom_data:String = "can_place_seeds"
const can_place_dirt_custom_data:String = "can_place_dirt"
const can_place_watering_custom_data:String = "can_watering_dirt"

const ground_layer:int = 0
const road_layer:int = 1
const nature_layer:int = 2
const farmland_layer:int = 3
const watering_layer:int = 4
const crops_layer:int = 5
const building_layer:int = 6

const farming_terrain_set:int = 0
const watering_terrain_set:int = 1
const ground_terrain_set:int = 2
const coast_terrain_set:int = 3
const terrain:int = 0

func collisions_detect(collision_layer:int) -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if !check_cell(grid_position, collision_layer):
			grids.texture = default
		else:
			grids.texture = error

func collisions_check() -> bool:
	for grids in get_children():
		if grids.texture == error:
			return false
	return true

func destroy_collision_check(mode:int):
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		match mode:
			1:
				for node in nature.get_children():
					if check_cell(grid_position, nature_layer):
						if grid_position == tilemap.local_to_map(node.position):
							if data.remove_suffix(node.name) == "weed":
								grids.texture = default
							else:
								grids.texture = error
					else:
						if check_cell(grid_position, farmland_layer)\
						&& !check_cell(grid_position, watering_layer)\
						&& !check_cell(grid_position, crops_layer):
							grids.texture = default
						if check_cell(grid_position, farmland_layer)\
						&& check_cell(grid_position, watering_layer)\
						&& !check_cell(grid_position, crops_layer):
							grids.texture = default
						if check_cell(grid_position, farmland_layer)\
						&& check_cell(grid_position, watering_layer)\
						&& check_cell(grid_position, crops_layer):
							grids.texture = default
						else:
							grids.texture = error
			2:
				for node in nature.get_children():
					if check_cell(grid_position, nature_layer):
						if grid_position == tilemap.local_to_map(node.position):
							if data.remove_suffix(node.name) == "tree":
								grids.texture = default
							else:
								grids.texture = error
					else:
						grids.texture = error
			3:
				for node in nature.get_children():
					if check_cell(grid_position, nature_layer):
						if grid_position == tilemap.local_to_map(node.position):
							if data.remove_suffix(node.name) == "stone":
								grids.texture = default
							else:
								grids.texture = error
					else:
						grids.texture = error
			4:
				print("BUILDING")
			_:
				pass
		
func farming_collision_check() -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if check_custom_data(grid_position, can_place_dirt_custom_data, road_layer)\
		and !check_cell(grid_position, farmland_layer):
			grids.texture = default
		else:
			grids.texture = error
		
func watering_collision_check() -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if check_custom_data(grid_position, can_place_seed_custom_data, farmland_layer)\
		and !check_cell(grid_position, watering_layer):
			grids.texture = default
		else:
			grids.texture = error

func planting_collision_check() -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if check_cell(grid_position, farmland_layer)\
		and !check_cell(grid_position, watering_layer)\
		and !check_cell(grid_position, crops_layer):
			grids.texture = default
		elif check_cell(grid_position, farmland_layer)\
		and check_cell(grid_position, watering_layer)\
		and !check_cell(grid_position, crops_layer):
			grids.texture = default
		else:
			grids.texture = error
		
func harvest_check() -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if check_cell(grid_position, crops_layer)\
		&& get_harvest(grid_position):
			grids.texture = default
		else:
			grids.texture = error

func terrain_collision_check(terrain_layer:int) -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if !check_cell(grid_position, terrain_layer):
				grids.texture = default
		else:
			grids.texture = error

func building_collision_check() -> void:
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if !check_cell(grid_position, building_layer)\
		&& !check_cell(grid_position, nature_layer)\
		&& !check_cell(grid_position, farmland_layer)\
		&& !check_cell(grid_position, watering_layer) :
			grids.texture = default
		else:
			grids.texture = error

func get_nature(vector:Vector2i):
	for node in nature.get_children():
		if vector == tilemap.local_to_map(node.position):
			if node != null:
				return node
	return

func get_nature_name(vector:Vector2i) -> String:
	for node in nature.get_children():
		if vector == tilemap.local_to_map(node.position):
			if node != null:
				return node.name
	return ""

func get_building(vector:Vector2i):
	for node in buildings.get_children():
		#if data.remove_suffix(node.name) in buildings.all_buildings:
		print(data.remove_suffix(node.name))
		if tilemap.local_to_map(vector) == tilemap.local_to_map(node.position)\
		&& node.name != grid.name:
			return node

func get_shadow(vector:Vector2i):
	for shadow in shadows.get_children():
		if tilemap.local_to_map(vector) == tilemap.local_to_map(shadow.position):
			return shadow

func get_harvest(vector:Vector2i) -> bool:
	for plant in farming.get_children():
		if vector == tilemap.local_to_map(plant.position):
			if plant.condition == plant.phases.GROWED:
				return true
	return false

func get_harvest_id(vector:Vector2i):
	for plant in farming.get_children():
		if vector == tilemap.local_to_map(plant.position):
			return plant.plantID

func check_custom_data(vector:Vector2, custom_data_layer:String, layer:int) -> bool:
	var tiledata = tilemap.get_cell_tile_data(layer, vector)
	if tiledata:
		return tiledata.get_custom_data(custom_data_layer)
	return false

func check_cell(vector:Vector2, current_tile:int) -> bool:
	if tilemap.get_cell_source_id(current_tile, vector) == -1:
		return false
	return true

func get_used_cells(layer:int) -> Array:
	return tilemap.get_used_cells(layer)

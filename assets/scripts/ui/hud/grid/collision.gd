extends Node2D

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var default:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/grid/default.png")
@onready var error:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/grid/error.png")

var items = Items.new()
var crops = Crops.new()

const can_place_seed_custom_data:String = "can_place_seeds"
const can_place_dirt_custom_data:String = "can_place_dirt"
const can_place_watering_custom_data:String = "can_watering_dirt"

const ground_layer:int = 0
const road_layer:int = 1
const nature_layer:int = 2
const coast_layer:int = 3
const aquatic_layer:int = 4
const water_layer:int = 5
const farmland_layer:int = 6
const watering_layer:int = 7
const crops_layer:int = 8
const building_layer:int = 9
const collision_scene:int = 10
const border_collisions:int = 11

const terrain_set:int = 0
const roads_terrain:int = 0
const farming_terrain:int = 1
const watering_terrain:int = 2
const coast_terrain:int = 3
const water_terrain:int = 4

func collisions_detect(collision_layer:int) -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if !check_cell(grid_position, collision_layer):
				grids.texture = default
			else:
				grids.texture = error

func collisions_check() -> bool:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			if grids.texture == error:
				return false
	return true

func nature_check():
	# ?
	for grids in get_children():
		var grid_position = tilemap.local_to_map(grids.get_global_position())
		if !check_cell(grid_position, border_collisions):
			for node in nature.get_children():
				if grid_position == tilemap.local_to_map(node.get_global_position()):
					match data.remove_suffix(node.name):
						'tree':
							grids.texture = default
							return 1
						'weed':
							grids.texture = default
							return 2
						'stone':
							grids.texture = default
							return 3
			for plant in farming.get_children():
				if data.remove_suffix(plant.name) == 'plant':
					var plant_data = farming.plants_map[plant.name]
					if grid_position == tilemap.local_to_map(plant_data['position']):
						grids.texture = default
						return 4
		grids.texture = error

func terrain_check():
	if main == "Farm":\
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if check_cell(grid_position, road_layer)\
			&& !check_cell(grid_position, farmland_layer)\
			&& !check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, border_collisions):
				grids.texture = default
				return 0
			elif check_cell(grid_position, farmland_layer)\
			&& !check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, border_collisions):
				grids.texture = default
				return 1
			elif check_cell(grid_position, farmland_layer)\
			&& check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, border_collisions):
				grids.texture = default
				return 2
			elif check_cell(grid_position, coast_layer)\
			&& check_cell(grid_position, water_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, border_collisions):
				grids.texture = default
				return 3
			else:
				grids.texture = error
				return -1
	if main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if check_cell(grid_position, farmland_layer)\
			&& !check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer):
				grids.texture = default
				return 1
			elif check_cell(grid_position, farmland_layer)\
			&& check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer):
				grids.texture = default
				return 2
			elif check_cell(grid_position, coast_layer)\
			&& check_cell(grid_position, water_layer):
				grids.texture = default
				return 3
			else:
				grids.texture = error
				return -1
		
func farming_collision_check() -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if check_custom_data(grid_position, can_place_dirt_custom_data, road_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, farmland_layer):
				grids.texture = default
			else:
				grids.texture = error
		
func watering_collision_check() -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if check_custom_data(grid_position, can_place_seed_custom_data, farmland_layer)\
			&& !check_cell(grid_position, watering_layer)\
			&& tools.water_can > 0:
				grids.texture = default
			else:
				grids.texture = error

func planting_collision_check() -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if check_cell(grid_position, farmland_layer)\
			&& !check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer):
				grids.texture = default
			elif check_cell(grid_position, farmland_layer)\
			&& check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, crops_layer):
				grids.texture = default
			else:
				grids.texture = error
		
func harvest_check() -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			if check_cell(grid_position, crops_layer):
				grids.texture = default
			else:
				grids.texture = error

func terrain_collision_check(terrain_layer:Array) -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var local_position = tilemap.to_local(grids.get_global_position())
			var grid_position = tilemap.local_to_map(local_position)
			var collision_found = false
			if !check_cell(grid_position, border_collisions)\
			&& !check_cell(grid_position, building_layer):
				for i in terrain_layer:
					if check_cell(grid_position, i)\
					|| !check_cell(grid_position, ground_layer):
						collision_found = true
						break
				if collision_found:
					grids.texture = error
				else:
					grids.texture = default
			else:
				grids.texture = error

func building_collision_check() -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			var texture = error
			if check_cell(grid_position, ground_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, nature_layer)\
			&& !check_cell(grid_position, farmland_layer)\
			&& !check_cell(grid_position, watering_layer)\
			&& !check_cell(grid_position, coast_layer)\
			&& !check_cell(grid_position, water_layer)\
			&& !check_cell(grid_position, building_layer)\
			&& !check_cell(grid_position, border_collisions):
				grids.texture = default
			else:
				grids.texture = error

func check_fertilizer_cell() -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for grids in get_children():
			var grid_position = tilemap.local_to_map(grids.get_global_position())
			var texture = error
			if check_cell(grid_position, farmland_layer)\
			&& !check_fertilizer(grid_position)\
			&& !get_plant(grid_position):
				grids.texture = default
			else:
				grids.texture = error

func check_fertilizer(vector:Vector2i) -> bool:
	if farming.get_children().size() > 0:
		for i in farming.get_children():
			if data.remove_suffix(i.name) == "fertilizer":
				if vector == tilemap.local_to_map(i.position):
					return true
	return false

func get_fertilizer_percent(vector:Vector2i) -> float:
	var fertilizer_percent = 0.0
	if farming.get_children().size() > 0:
		for f in farming.get_children():
			if data.remove_suffix(f.name) == "fertilizer":
				if vector == tilemap.local_to_map(f.position):
					fertilizer_percent = f._percent
	return fertilizer_percent

func get_fertilizer_id(vector:Vector2i) -> float:
	var fertilizer_id = 0.0
	if farming.get_children().size() > 0:
		for f in farming.get_children():
			if data.remove_suffix(f.name) == "fertilizer":
				if vector == tilemap.local_to_map(f.position):
					fertilizer_id = f._id
	return fertilizer_id

func get_shadow(vector:Vector2i) -> Node2D:
	if main == "Farm"\
	|| main == "Greenhouse":
		for shadow in shadows.get_children():
			if tilemap.local_to_map(vector) == tilemap.local_to_map(shadow.position):
				return shadow
	return null

func get_plant(vector:Vector2i) -> bool:
	if main == "Farm"\
	|| main == "Greenhouse":
		for plant in farming.get_children():
			if data.remove_suffix(plant.name) == "plant":
				if vector == tilemap.local_to_map(plant.position):
					return true
	return false

func get_harvest(vector:Vector2i) -> bool:
	if main == "Farm"\
	|| main == "Greenhouse":
		for plant in farming.get_children():
			if data.remove_suffix(plant.name) == "plant":
				if vector == tilemap.local_to_map(plant.position):
					if '_condition' in plant && 'PHASES' in plant:
						if plant._condition == plant.PHASES.GROWED:
							return true
	return false

func get_harvest_id(vector:Vector2i) -> int:
	if main == "Farm"\
	|| main == "Greenhouse":
		for plant in farming.get_children():
			if data.remove_suffix(plant.name) == "plant":
				if vector == tilemap.local_to_map(plant.position)\
				&& '_plant_id' in plant:
					return plant._plant_id
	return 0

func get_harvest_condition(vector:Vector2i) -> int:
	if main == "Farm"\
	|| main == "Greenhouse":
		for plant in farming.get_children():
			if data.remove_suffix(plant.name) == "plant":
				if vector == tilemap.local_to_map(plant.position)\
				&& '_condition' in plant:
					return plant._condition
	return 0

func get_harvest_level(vector:Vector2i) -> int:
	if main == "Farm"\
	|| main == "Greenhouse":
		for plant in farming.get_children():
			if data.remove_suffix(plant.name) == "plant":
				if vector == tilemap.local_to_map(plant.position)\
				&& '_level' in plant:
					return plant._level
	return 0

func get_harvest_level_max(vector:Vector2i) -> int:
	if main == "Farm"\
	|| main == "Greenhouse":
		for plant in farming.get_children():
			if data.remove_suffix(plant.name) == "plant":
				if vector == tilemap.local_to_map(plant.position)\
				&& '_growth_max' in plant:
					return plant._growth_max
	return 0

func check_custom_data(vector:Vector2, custom_data_layer:String, layer:int) -> bool:
	if main == "Farm"\
	|| main == "Greenhouse":
		var tiledata = tilemap.get_cell_tile_data(layer, vector)
		if tiledata:
			return tiledata.get_custom_data(custom_data_layer)
	return false

func check_cell(vector:Vector2, current_tile:int) -> bool:
	if main == "Farm"\
	|| main == "Greenhouse":
		if tilemap.get_cell_source_id(current_tile, vector) == -1:
			return false
	return true

func get_used_cells(layer:int) -> Array:
	if main == "Farm"\
	|| main == "Greenhouse":
		return tilemap.get_used_cells(layer)
	return []

func get_position_children(parent:Node2D) -> Array:
	if main == "Farm"\
	|| main == "Greenhouse":
		var children = parent.get_children()
		var coordinates = []
		for child in children:
			if child is Node2D:
				if data.remove_suffix(child.name) == 'plant':
					coordinates.append(tilemap.local_to_map(child.global_position))
		return coordinates
	return []

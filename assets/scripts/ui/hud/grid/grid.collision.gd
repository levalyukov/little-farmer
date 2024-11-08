extends Area2D

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

var crops = Crops.new()

const can_place_seed_custom_data:String = "can_place_seeds"
const can_place_dirt_custom_data:String = "can_place_dirt"
const can_place_watering_custom_data:String = "can_watering_dirt"

const ground_layer:int = 0
const road_layer:int = 1
const farmland_layer:int = 2
const watering_layer:int = 3
const crops_layer:int = 4
const building_layer:int = 5
const shadow_layer:int = 6

const farming_terrain_set:int = 0
const watering_terrain_set:int = 1
const ground_terrain_set:int = 2
const terrain:int = 0

func destroy_collision_check() -> int:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if check_cell(tile_mouse_pos, farmland_layer)\
	and !check_cell(tile_mouse_pos, watering_layer)\
	and !check_cell(tile_mouse_pos, crops_layer):
		grid.change_sprite(false)
		return 1
	elif check_cell(tile_mouse_pos, farmland_layer)\
	and check_cell(tile_mouse_pos, watering_layer)\
	and !check_cell(tile_mouse_pos, crops_layer):
		grid.change_sprite(false)
		return 2
	elif check_cell(tile_mouse_pos, farmland_layer)\
	and check_cell(tile_mouse_pos, watering_layer)\
	and check_cell(tile_mouse_pos, crops_layer):
		grid.change_sprite(false)
		return 3
	elif check_cell(tile_mouse_pos, farmland_layer)\
	and !check_cell(tile_mouse_pos, watering_layer)\
	and check_cell(tile_mouse_pos, crops_layer):
		grid.change_sprite(false)
		return 4
	elif check_cell(tile_mouse_pos, building_layer-1):
		grid.change_sprite(false)
		return 5
	else:
		grid.change_sprite(true)
		return -1
		
func farming_collision_check() -> bool:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if check_custom_data(tile_mouse_pos, can_place_dirt_custom_data, road_layer)\
	and !check_cell(tile_mouse_pos, farmland_layer):
		grid.change_sprite(false)
		return true
	else:
		grid.change_sprite(true)
		return false
		
func watering_collision_check() -> bool:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if check_custom_data(tile_mouse_pos, can_place_seed_custom_data, farmland_layer)\
	and !check_cell(tile_mouse_pos, watering_layer):
		grid.change_sprite(false)
		return true
	else:
		grid.change_sprite(true)
		return false

func planting_collision_check() -> bool:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if check_cell(tile_mouse_pos, farmland_layer)\
	and !check_cell(tile_mouse_pos, watering_layer)\
	and !check_cell(tile_mouse_pos, crops_layer):
		grid.change_sprite(false)
		return true
	elif check_cell(tile_mouse_pos, farmland_layer)\
	and check_cell(tile_mouse_pos, watering_layer)\
	and !check_cell(tile_mouse_pos, crops_layer):
		grid.change_sprite(false)
		return true
	else:
		grid.change_sprite(true)
		return false
	
func harvesting_collision_check() -> bool:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if check_cell(tile_mouse_pos, crops_layer)\
	&& get_plant(tile_mouse_pos):
		grid.change_sprite(false)
		return true
	else:
		grid.change_sprite(true)
		return false

func terrain_collision_check(terrain_layer) -> bool:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if !check_cell(tile_mouse_pos, terrain_layer):
		grid.change_sprite(false)
		return true
	else:
		grid.change_sprite(true)
		return false

func building_collision_check() -> bool:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
	if check_cell(tile_mouse_pos, building_layer-1):
		grid.change_sprite(true)
		return true
	elif check_cell(tile_mouse_pos, farmland_layer):
		grid.change_sprite(true)
		return true
	else:
		grid.change_sprite(false)
		return false


func get_building(mouse_position:Vector2i):
	for node in buildings.get_children():
		if data.remove_suffix(node.name) in buildings.all_buildings:
			if tilemap.local_to_map(mouse_position) == tilemap.local_to_map(node.position):
				return node

func get_shadow(mouse_position:Vector2i):
	for shadow in shadows.get_children():
		if tilemap.local_to_map(mouse_position) == tilemap.local_to_map(shadow.position):
			return shadow

func get_plant(mouse_position:Vector2i) -> bool:
	for plant in farming.get_children():
		if mouse_position == tilemap.local_to_map(plant.position):
			if plant.condition == plant.phases.GROWED:
				return true
	return false

func get_plant_id(mouse_position:Vector2i) -> int:
	for plant in farming.get_children():
		if tilemap.local_to_map(mouse_position) == tilemap.local_to_map(plant.position):
			return plant.plantID
	return 0

func check_custom_data(tile_mouse:Vector2, custom_data_layer:String, layer:int) -> bool:
	var tiledata = tilemap.get_cell_tile_data(layer, tile_mouse)
	if tiledata:
		return tiledata.get_custom_data(custom_data_layer)
	return false

func check_cell(mouse:Vector2, current_tile:int) -> bool:
	if tilemap.get_cell_source_id(current_tile, mouse) == -1:
		return false
	return true

func get_used_cells(layer:int) -> Array:
	return tilemap.get_used_cells(layer)

extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var notifications:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var collision:Node2D = $GridParent

var items = Items.new()
var crops = Crops.new()
var blueprints = Blueprints.new()
var materials = BuildingMaterials.new()

const grid_size:Vector2 = Vector2(16, 16)
var grid_dimensions:Vector2i = Vector2i(1,1)
var check:bool = false
var mode:int = modes.NOTHING
enum modes {
	NOTHING, 
	DESTROY, 
	FARMING, 
	PLANTING, 
	WATERING, 
	HARVESTING, 
	BUILD, 
	TERRAIN_SET, 
	UPGRADE
}

# plant config
var plantID
var crop_growed:bool
var inventory_item

# construct config
var node_id:int
var node_source:PackedScene
var node_shadow
var terrain_set:int
var node_upgrade

func _process(_delta):
	if visible\
	&& !blur.state\
	&& mode != modes.NOTHING:
		if destroy_menu.opened:
			destroy_menu.close()
		var mouse_pos:Vector2 = get_global_mouse_position()
		var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
		var ground_tile_position = []
		var farming_tile_position = []
		var watering_tile_position = []
		var building_tile_position = []
		match mode:
			modes.DESTROY:
				collision.destroy_collision_check()
				if check:
					if collision.collisions_check():
						match collision.destroy_collision_check():
							0:
								var remove_terrain = []
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
									remove_terrain.append(grid_position)
								tilemap.set_cells_terrain_connect(collision.road_layer,remove_terrain,collision.ground_terrain_set,-1)
							1:
								var remove_terrain = []
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
									remove_terrain.append(grid_position)
								tilemap.set_cells_terrain_connect(collision.farmland_layer,remove_terrain,collision.farming_terrain_set,-1)
							2:
								var remove_terrain = []
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
									remove_terrain.append(grid_position)
								tilemap.set_cells_terrain_connect(collision.watering_layer,remove_terrain,collision.watering_terrain_set,-1)
							3:
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
									tilemap.erase_cell(collision.crops_layer,grid_position)
									farming.plant_destroy(tilemap.map_to_local(grid_position))
							4:
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
									tilemap.erase_cell(collision.crops_layer,grid_position)
									farming.plant_destroy(tilemap.map_to_local(grid_position))
							5:
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
								#building.remove_child(collision.get_building(tilemap.map_to_local(tile_mouse_pos)))
								#shadows.remove_child(collision.get_shadow(tilemap.map_to_local(tile_mouse_pos)))
								#tilemap.erase_cell(collision.building_layer, tile_mouse_pos)
							6:
								for i in collision.get_children():
									var grid_position = tilemap.local_to_map(i.get_global_position())
									nature.remove_child(collision.get_nature(grid_position))
									shadows.remove_child(collision.get_shadow(tilemap.map_to_local(grid_position)))
									tilemap.erase_cell(collision.nature_layer, grid_position)
									inventory.add_item(1, randi_range(3,10))
				check = false
				
			modes.FARMING:
				collision.farming_collision_check()
				if check:
					if collision.collisions_check():
						for i in collision.get_children():
							var grid_position = tilemap.local_to_map(i.get_global_position())
							farming_tile_position.append(grid_position)
						tilemap.set_cells_terrain_connect(collision.farmland_layer,farming_tile_position,collision.farming_terrain_set,collision.terrain)
				check = false
				
			modes.WATERING:
				collision.watering_collision_check()
				if check:
					if collision.collisions_check():
						for i in collision.get_children():
							var grid_position = tilemap.local_to_map(i.get_global_position())
							watering_tile_position.append(grid_position)
						tilemap.set_cells_terrain_connect(collision.watering_layer,watering_tile_position,collision.watering_terrain_set,collision.terrain)
				check = false
				
			modes.PLANTING:
				collision.planting_collision_check()
				if inventory.check_item_amount(inventory_item):
					if inventory.get_item_amount(inventory_item) >= collision.get_children().size():
						for i in collision.get_children():
							var grid_position = tilemap.local_to_map(i.get_global_position())
							if check:
								if collision.collisions_check():
									if crops.crops.has(plantID):
										inventory.subject_item(inventory_item, 1)
										farming.create_plant(plantID, grid_position)
									else:
										data.debug("The numerical ID (" + str(plantID) + ") of this crop is missing in the main file crops.gd", "error")
					else:
						grid_dimensions = Vector2i(1,1)
						generate_grid()
				else:
					hud.state(false, "all")
					mode = modes.NOTHING
					visible = false
				check = false

			modes.HARVESTING:
				collision.harvesting_collision_check()
				if check:
					if collision.collisions_check():
						for i in collision.get_children(): 
							var plant_id = collision.get_plant_id(tilemap.map_to_local(tile_mouse_pos))
							if crops.crops.has(plant_id):
								if storage.object[storage.level]["slots"] - inventory.get_all_items() != 0:
									var crop_item:int = crops.crops[plant_id]["item"]
									var crop_productivity:Array = crops.crops[plant_id]["productivity"]
									var target_productivity:int = randi_range(crop_productivity[0], crop_productivity[1])
									tilemap.erase_cell(collision.crops_layer, tile_mouse_pos)
									farming.plant_destroy(tilemap.map_to_local(tile_mouse_pos))
									inventory.add_item(crop_item, target_productivity)
								else:
									notifications.create_notice("error")
							else:
								data.debug("Index ", plant_id, " does not exist in the main 'crops' dictionary", "error")
				check = false

			modes.BUILD:
				var data_resources = {}
				collision.building_collision_check()
				if blueprints.content[node_id].has("resource"):
					for resource in blueprints.content[node_id]["resource"]:
						var required_amount = blueprints.content[node_id]["resource"][resource]
						var available_amount = inventory.get_item_amount(materials.resources[resource])
						if available_amount >= required_amount:
								building_tile_position.append(tile_mouse_pos)
								data_resources[resource] = {}
								data_resources[resource]["amount"] = blueprints.content[node_id]["resource"][resource]
						else:
							hud.state(false, "all")
							mode = modes.NOTHING
							visible = false
							check = false
				if check:
					if collision.collisions_check():
						if blueprints.content.has(node_id):
							var node_name:String = "build"
							if blueprints.content[node_id].has("type")\
							&& blueprints.content[node_id]["type"].has("node")\
							&& blueprints.content[node_id]["type"]["node"].has("name")\
							&& blueprints.content[node_id]["type"]["node"]["name"] is String:
								node_name = blueprints.content[node_id]["type"]["node"]["name"]
							building.construct(node_name, node_source, node_shadow, tile_mouse_pos)

						if blueprints.content[node_id].has("resource"):
							inventory.subject_item(data_resources)
				check = false

			modes.TERRAIN_SET:
				collision.terrain_collision_check(collision.road_layer)
				if check:
					if collision.collisions_check():
						if collision.get_children().size() > 1:
							for i in collision.get_children():
								var grid_position = tilemap.local_to_map(i.get_global_position())
								ground_tile_position.append(grid_position)
							tilemap.set_cells_terrain_connect(collision.road_layer,ground_tile_position,terrain_set,collision.terrain)
						else:
							ground_tile_position.append(tile_mouse_pos)
							tilemap.set_cells_terrain_connect(collision.road_layer,ground_tile_position,terrain_set,collision.terrain)	
				check = false

			modes.UPGRADE:
				check = false
	else:
		visible = false
		check = false

func _input(event):
	if visible\
	&& mode != modes.NOTHING:
		hud.state(true, "all")
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed():
			if collision.collisions_check():
				check = true

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_RIGHT\
	&& event.is_pressed()\
	&& visible\
	&& mode != modes.NOTHING:
		hud.state(false, "all")
		mode = modes.NOTHING
		visible = false
		check = false

func generate_grid():
	for child in collision.get_children():
		child.queue_free()

	for x in range(grid_dimensions.x):
		for y in range(grid_dimensions.y):
			var sprite = Sprite2D.new()
			sprite.texture = preload("res://assets/resources/ui/interactive/hud/grid/default.png")
			sprite.position = Vector2(x * grid_size.x, y * grid_size.y)
			collision.add_child(sprite)

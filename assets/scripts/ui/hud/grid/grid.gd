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
var natural_resources = NaturalResources.new()

const SIZE:Vector2 = Vector2(16, 16)
var grid_dimensions:Vector2i = Vector2i(1,1)
var check:bool = false
var mode:int = modes.NOTHING
var destroy_mode:int = destroy.NOTHING
enum modes {NOTHING, DESTROY, FARMING, PLANTING, WATERING, HARVESTING, BUILD, TERRAIN_SET, UPGRADE}
enum destroy {NOTHING, TRASH, AXE, PICKAXE, BOMB}

# plant config
var plantID
var crop_growed:bool
var inventory_item

# construct config
var id:int
var group:String
var terrain_set:Array = []
var terrain_required_layer:Array = []
var terrain_blocking_layer:Array = []

func _process(_delta):
	if visible\
	&& !blur.state\
	&& mode != modes.NOTHING:
		if destroy_menu.opened:
			destroy_menu.close()
		var mouse_pos:Vector2 = get_global_mouse_position()
		var tile_mouse_pos = tilemap.local_to_map(mouse_pos)
		match mode:
			modes.DESTROY:
				collision.destroy_collision_check(destroy_mode)
				if destroy_mode == destroy.TRASH\
				|| destroy_mode == destroy.AXE\
				|| destroy_mode == destroy.PICKAXE:
					grid_dimensions = Vector2i(1,1)
					for i in collision.get_children():
						var grid_position = tilemap.local_to_map(i.get_global_position())
						var natural_node = collision.get_nature(grid_position)
						var natural_node_name = data.remove_suffix(collision.get_nature_name(grid_position))
						if i.texture != collision.error:
							if natural_node != null:
								if natural_node.health > 0:
									if check:
										natural_node.health -= 1
								else:
									if natural_resources.content.has(natural_node_name):
										if natural_resources.content[natural_node_name].has("item_id")\
										&& natural_resources.content[natural_node_name].has("item_count"):
											var item_amount = natural_resources.content[natural_node_name]["item_count"]
											inventory.add_item(
												natural_resources.content[natural_node_name]["item_id"], 
												randi_range(item_amount[0], item_amount[1])
												)
									nature.remove_child(collision.get_nature(grid_position))
									shadows.remove_child(collision.get_shadow(tilemap.map_to_local(grid_position)))
									tilemap.erase_cell(collision.nature_layer, grid_position)	
							if collision.check_cell(grid_position, collision.crops_layer):
								if check:
									tilemap.erase_cell(collision.crops_layer, grid_position)
									farming.plant_destroy(grid_position)
				else:
					match destroy_mode:
						destroy.BOMB:
							for i in collision.get_children():
								var grid_position = tilemap.local_to_map(i.get_global_position())
								if i.texture != collision.error:
									if check:
										if collision.check_cell(grid_position, collision.road_layer):
											tilemap.set_cells_terrain_connect(collision.road_layer, [grid_position], collision.roads_terrain_set, -1)
										if collision.check_cell(grid_position, collision.water_layer)\
										&& collision.check_cell(grid_position, collision.coast_layer):
											tilemap.set_cells_terrain_connect(collision.water_layer, [grid_position], collision.water_terrain_set, -1)
											tilemap.set_cells_terrain_connect(collision.coast_layer, [grid_position], collision.coast_terrain_set, -1)
				check = false
				
			modes.FARMING:
				collision.farming_collision_check()
				if check:
					var farming_tile_position = []
					for i in collision.get_children():
						var grid_position = tilemap.local_to_map(i.get_global_position())
						if collision.check_cell(grid_position, collision.road_layer)\
						&& collision.check_custom_data(grid_position, collision.can_place_dirt_custom_data, collision.road_layer):
							farming_tile_position.append(grid_position)
					tilemap.set_cells_terrain_connect(collision.farmland_layer,farming_tile_position,collision.farming_terrain_set, 0)
					#tilemap.set_cells_terrain_connect(collision.farmland_layer,farming_tile_position,collision.coast_terrain_set,0)
				check = false
				
			modes.WATERING:
				collision.watering_collision_check()
				if check:
					for i in collision.get_children():
						var grid_position = tilemap.local_to_map(i.get_global_position())
						if collision.check_cell(grid_position, collision.farmland_layer)\
						&& !collision.check_cell(grid_position, collision.watering_layer)\
						&& collision.check_custom_data(grid_position, collision.can_place_watering_custom_data, collision.farmland_layer):
							if tools.water_can > 0:
								tools.water_can -= 1
							else:
								tools.water_can = 0
							tilemap.set_cells_terrain_connect(collision.watering_layer,[grid_position],collision.watering_terrain_set,0)
				check = false
				
			modes.PLANTING:
				collision.planting_collision_check()
				if inventory.check_item_amount(inventory_item):
					if inventory.get_item_amount(inventory_item) >= collision.get_children().size():
						for i in collision.get_children():
							var grid_position = tilemap.local_to_map(i.get_global_position())
							if check:
								if crops.crops.has(plantID):
									if collision.check_cell(grid_position, collision.farmland_layer)\
									&& !collision.check_cell(grid_position, collision.crops_layer)\
									&& collision.check_custom_data(grid_position, collision.can_place_seed_custom_data, collision.farmland_layer):
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
				collision.harvest_check()
				if check:
					for i in collision.get_children(): 
						var grid_position = tilemap.local_to_map(i.get_global_position())
						var harvest = collision.get_harvest_id(grid_position)
						if crops.crops.has(harvest) && harvest != 0:
							if storage.object[storage.level]["slots"] - inventory.get_all_items() != 0:
								if collision.get_harvest(grid_position):
									var crop_item:int = crops.crops[harvest]["item"]
									var crop_productivity:Array = crops.crops[harvest]["productivity"]
									var target_productivity:int = randi_range(crop_productivity[0], crop_productivity[1])
									tilemap.erase_cell(collision.crops_layer, grid_position)
									farming.plant_destroy(grid_position)
									inventory.add_item(crop_item, target_productivity)
							else:
								notifications.create_notice(tr("full_inventory.error"))
						else:
							if harvest != null:
								data.debug("Index " + str(harvest) + " does not exist in the main 'crops' dictionary", "error")
				check = false

			modes.BUILD:
				var data_resources = {}
				collision.building_collision_check()
				if blueprints.content[group][id]["config"].has("resources"):
					for resource in blueprints.content[group][id]["config"]["resources"]:
						var required_amount = blueprints.content[group][id]["config"]["resources"][resource]["amount"]
						var available_amount = inventory.get_item_amount(resource)
						if available_amount >= required_amount:
							data_resources[resource] = {}
							data_resources[resource]["amount"] = blueprints.content[group][id]["config"]["resources"][resource]["amount"]
						else:
							hud.state(false, "all")
							mode = modes.NOTHING
							visible = false
							check = false
				if check:
					if collision.collisions_check():
						if blueprints.content.has(group):
							if blueprints.content[group].has(id):
								building.create_node(id, tile_mouse_pos)
								if data_resources != {}:
									inventory.subject_item(data_resources)
				check = false

			modes.TERRAIN_SET:
				collision.terrain_collision_check(terrain_blocking_layer)
				if check:
					var positions = []
					for i in collision.get_children():
						var local_position = tilemap.to_local(i.get_global_position())
						var grid_position = tilemap.local_to_map(local_position)
						if i.texture != collision.error:
							positions.append(grid_position)
					for index in range(len(terrain_required_layer)):
						if index < terrain_set.size():
							if positions != []:
								var layer = terrain_required_layer[index]
								var terrain = terrain_set[index]
								tilemap.set_cells_terrain_connect(layer, positions, terrain, 0)
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
			check = true

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_RIGHT\
	&& event.is_pressed()\
	&& visible\
	&& mode != modes.NOTHING:
		hud.state(false, "all")
		mode = modes.NOTHING
		check = false
		destroy_mode = destroy.NOTHING
		for child in collision.get_children():
			child.queue_free()

func generate_grid():
	if grid_dimensions.x <= tools.max_grid_dimensions\
	&& grid_dimensions.y <= tools.max_grid_dimensions:
		for child in collision.get_children():
			child.queue_free()
	
		for x in range(grid_dimensions.x):
			for y in range(grid_dimensions.y):
				var sprite = Sprite2D.new()
				sprite.texture = preload("res://assets/resources/ui/interactive/hud/grid/default.png")
				sprite.position = Vector2(x * SIZE.x, y * SIZE.y)
				collision.add_child(sprite)
	else:
		grid_dimensions = Vector2i(tools.max_grid_dimensions,tools.max_grid_dimensions)
		generate_grid()

extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var notifications:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var collision:Node2D = $GridParent

var items = Items.new()
var crops = Crops.new()
var blueprints = Blueprints.new()
var natural_resources = NaturalResources.new()

const SIZE:Vector2 = Vector2(16, 16)
var grid_dimensions:Vector2i = Vector2i(1,1)
var check:bool = false
var mode:int = modes.NOTHING
var destroy_mode:int = destroy.NOTHING
enum modes {NOTHING, DESTROY, FARMING, PLANTING, WATERING, HARVESTING, FERTILIZER, BUILD, TERRAIN_SET, UPGRADE}
enum destroy {NOTHING, TERRAINS, NATURE}

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
				match destroy_mode:
					destroy.TERRAINS:
						collision.terrain_check()
						if check:
							for i in collision.get_children():
								var grid_position = tilemap.local_to_map(i.get_global_position())
								match collision.terrain_check():
									0:
										tilemap.set_cells_terrain_connect(collision.road_layer,[grid_position],0,-1)
									1:
										tilemap.set_cells_terrain_connect(collision.farmland_layer,[grid_position],0,-1)
									2:
										tilemap.set_cells_terrain_connect(collision.watering_layer,[grid_position],0,-1)
									3:
										tilemap.set_cells_terrain_connect(collision.coast_layer,[grid_position],0,-1)
										tilemap.set_cells_terrain_connect(collision.water_layer,[grid_position],0,-1)
					destroy.NATURE:
						collision.nature_check()
						if check:
							for i in collision.get_children():
								var grid_position = tilemap.local_to_map(i.get_global_position())
								match collision.nature_check():
									1: # tree
										for a in nature.get_children():
											if grid_position == tilemap.local_to_map(a.position):
												nature.remove_child(a)
										for b in shadows.get_children():
											if grid_position == tilemap.local_to_map(b.position):
												shadows.remove_child(b)
										tilemap.erase_cell(collision.nature_layer, grid_position) 
										inventory.add_item(1, randi_range(1,5))
									2: # weed
										for a in nature.get_children():
											if grid_position == tilemap.local_to_map(a.position):
												nature.remove_child(a)
										for b in shadows.get_children():
											if grid_position == tilemap.local_to_map(b.position):
												shadows.remove_child(b)
										tilemap.erase_cell(collision.nature_layer, grid_position)
									3: # stone
										for a in nature.get_children():
											if grid_position == tilemap.local_to_map(a.position):
												nature.remove_child(a)
										for b in shadows.get_children():
											if grid_position == tilemap.local_to_map(b.position):
												shadows.remove_child(b)
										tilemap.erase_cell(collision.nature_layer, grid_position) 
										inventory.add_item(3, randi_range(1,10))
										if data.check_probability(15):
											inventory.add_item(5, randi_range(1,2))
									4: # plant
										tilemap.erase_cell(collision.crops_layer, grid_position)
										farming.plant_destroy(grid_position)
									_:
										pass
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
					tilemap.set_cells_terrain_connect(
						collision.farmland_layer,
						farming_tile_position,
						collision.terrain_set, 
						collision.farming_terrain
					)
					#tilemap.set_cells_terrain_connect(collision.farmland_layer,farming_tile_position,collision.coast_terrain_set,0)
				check = false
				
			modes.WATERING:
				collision.watering_collision_check()
				tip.tooltip('Вода в лейке:\n' + str(tools.water_can) + "/" + str(tools.water_can_max))
				if check:
					for i in collision.get_children():
						var grid_position = tilemap.local_to_map(i.get_global_position())
						if collision.check_cell(grid_position, collision.farmland_layer)\
						&& !collision.check_cell(grid_position, collision.watering_layer)\
						&& collision.check_custom_data(
							grid_position, 
							collision.can_place_watering_custom_data, 
							collision.farmland_layer
						):
							if tools.water_can > 0:
								tools.water_can -= 1
							else:
								tools.water_can = 0
							tilemap.set_cells_terrain_connect(
								collision.watering_layer,
								[grid_position],
								collision.terrain_set,
								collision.watering_terrain
							)
				check = false
				
			modes.PLANTING:
				collision.planting_collision_check()
				if inventory.check_item_amount(inventory_item):
					if inventory.get_item_amount(inventory_item) >= collision.get_children().size():
						for i in collision.get_children():
							var grid_position = tilemap.local_to_map(i.get_global_position())
							if check:
								if main == "Farm":
									if farming.check_season(plantID):
										if crops.crops.has(plantID):
											if collision.check_cell(grid_position, collision.farmland_layer)\
											&& !collision.check_cell(grid_position, collision.crops_layer)\
											&& collision.check_custom_data(
												grid_position, 
												collision.can_place_seed_custom_data, 
												collision.farmland_layer
											):
												inventory.subject_item(inventory_item, 1)
												farming.create_plant(plantID, grid_position)
										else:
											data.debug(
												"The numerical ID ("+ 
												str(plantID) 
												+") of this crop is missing in the main file crops.gd", 
												"error"
											)
								else:
									if crops.crops.has(plantID):
										if collision.check_cell(grid_position, collision.farmland_layer)\
										&& !collision.check_cell(grid_position, collision.crops_layer)\
										&& collision.check_custom_data(
											grid_position, 
											collision.can_place_seed_custom_data, 
											collision.farmland_layer
										):
											inventory.subject_item(inventory_item, 1)
											farming.create_plant(plantID, grid_position)
									else:
										data.debug(
											"The numerical ID ("+ 
											str(plantID) 
											+") of this crop is missing in the main file crops.gd", 
											"error"
										)
					else:
						grid_dimensions = Vector2i(1,1)
						generate_grid()
				else:
					hud.hud_all_show()
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
									if data.check_probability(5):
										var crop_spoilage = crops.crops[harvest]["spoilage"]
										var crop_productivity:Array = crops.crops[harvest]["productivity"]
										var target_productivity:int = randi_range(crop_productivity[0], crop_productivity[1])
										tilemap.erase_cell(collision.crops_layer, grid_position)
										farming.plant_destroy(grid_position)
										inventory.add_item(crop_spoilage, target_productivity)
									else:
										var crop_item:int = crops.crops[harvest]["item"]
										var crop_productivity:Array = crops.crops[harvest]["productivity"]
										var target_productivity:int = randi_range(crop_productivity[0], crop_productivity[1])
										tilemap.erase_cell(collision.crops_layer, grid_position)
										farming.plant_destroy(grid_position)
										inventory.add_item(crop_item, target_productivity)
							else:
								notifications.create_notice(tr("full_inventory.error"))
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
							hud.hud_all_show()
							mode = modes.NOTHING
							visible = false
							check = false
				if check:
					if collision.collisions_check():
						if blueprints.content.has(group):
							if blueprints.content[group].has(id):
								building.create_node(
									id, 
									tile_mouse_pos,
									blueprints.content[group][id]['config']['name']
								)
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
								tilemap.set_cells_terrain_connect(layer, positions, 0, terrain)
					check = false

			modes.UPGRADE:
				check = false

			modes.FERTILIZER:
				collision.check_fertilizer_grid()
				if check:
					for i in collision.get_children():
						var local_position = tilemap.to_local(i.get_global_position())
						var grid_position = tilemap.local_to_map(local_position)
						if i.texture != collision.error:
							farming.create_fertilizer(inventory_item, grid_position)
							inventory.subject_item(inventory_item, 1)
				check = false
	else:
		visible = false
		check = false

func _input(event):
	if visible\
	&& mode != modes.NOTHING:
		hud.hud_all_hide()
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed():
			check = true

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_RIGHT\
	&& event.is_pressed()\
	&& visible\
	&& mode != modes.NOTHING:
		hud.hud_all_show()
		mode = modes.NOTHING
		check = false
		destroy_mode = destroy.NOTHING
		tip.tooltip()
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

extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var notifications:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")

@onready var grid:Sprite2D = $Sprite2D
@onready var collision:Area2D = $GridCollision
@onready var default:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/grid/default.png")
@onready var error:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/grid/error.png")

var check:bool = false
var mode:int = modes.NOTHING
enum modes {NOTHING, DESTROY, FARMING, PLANTING, WATERING, HARVESTING, BUILD, TERRAIN_SET, UPGRADE}

var items = Items.new()
var crops = Crops.new()

var inventory_item
var plantID
var building_id
var building_node
var building_shadow:CompressedTexture2D
var terrain_set:int
var upgrade

var crop_growed:bool

func _ready():
	z_index = 10
	grid.texture = default
	visible = false
	
func _input(event):
	if !blur.state\
	&& mode != modes.NOTHING:
		hud.state(true, "all")
		if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_LEFT\
		and event.is_pressed()\
		and visible:
			check = true

		if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_RIGHT\
		and event.is_pressed()\
		and visible:
			_reset_grid()
			check = false

func _process(_delta):
	if !blur.state\
	&& visible\
	&& mode != modes.NOTHING:
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
					match collision.destroy_collision_check():
						1:
							tilemap.set_cells_terrain_connect(collision.farmland_layer,[tile_mouse_pos],collision.farming_terrain_set,-1)
						2:
							tilemap.set_cells_terrain_connect(collision.watering_layer,[tile_mouse_pos],collision.watering_terrain_set,-1)
						3:
							tilemap.erase_cell(collision.crops_layer,tile_mouse_pos)
							farming.plant_destroy(tilemap.map_to_local(tile_mouse_pos))
						4:
							tilemap.erase_cell(collision.crops_layer,tile_mouse_pos)
							farming.plant_destroy(tilemap.map_to_local(tile_mouse_pos))
				check = false

			modes.FARMING:
				collision.farming_collision_check()
				if check:
					if collision.farming_collision_check():
						farming_tile_position.append(tile_mouse_pos)
						tilemap.set_cells_terrain_connect(collision.farmland_layer,farming_tile_position,collision.farming_terrain_set,collision.terrain)
				check = false

			modes.WATERING:
				collision.watering_collision_check()
				if check:
					if collision.watering_collision_check():
						watering_tile_position.append(tile_mouse_pos)
						tilemap.set_cells_terrain_connect(collision.watering_layer,watering_tile_position,collision.watering_terrain_set,collision.terrain)
				check = false

			modes.PLANTING:
				collision.planting_collision_check()
				if inventory.check_item_amount(inventory_item):
					if check:
						if inventory.get_item_amount(inventory_item) > 0:
							if collision.planting_collision_check():
								if crops.crops.has(plantID):
									inventory.subject_item(inventory_item, 1)
									farming.create_plant(plantID, tile_mouse_pos)
								else:
									data.debug("The numerical ID (" + str(plantID) + ") of this crop is missing in the main file crops.gd", "error")
				else:
					_reset_grid()
				check = false

			modes.HARVESTING:
				collision.harvesting_collision_check()
				if check:
					if grid.texture != error:
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
				var blueprint = Blueprints.new()
				var materials = BuildingMaterials.new()
				var data_resources = {}
				collision.building_collision_check()
				if blueprint.content[building_id].has("resource"):
					for resource in blueprint.content[building_id]["resource"]:
						var required_amount = blueprint.content[building_id]["resource"][resource]
						var available_amount = inventory.get_item_amount(materials.resources[resource])
						if available_amount >= required_amount:
								building_tile_position.append(tile_mouse_pos)
								data_resources[resource] = {}
								data_resources[resource]["amount"] = blueprint.content[building_id]["resource"][resource]
						else:
							_reset_grid()
				if check:
					if grid.texture != error:
						if blueprint.content.has(building_id):
							var build_name = "build"
							if blueprint.content[building_id].has("type"):
								if blueprint.content[building_id]["type"].has("node"):
									if blueprint.content[building_id]["type"]["node"].has("name"):
										build_name = blueprint.content[building_id]["type"]["node"]["name"]
							building.construct(build_name, building_node, building_shadow, tile_mouse_pos)

							if blueprint.content[building_id].has("resource"):
								inventory.subject_item(data_resources)
				check = false

			modes.TERRAIN_SET:
				collision.terrain_collision_check(collision.road_layer)
				if check:
					if collision.terrain_collision_check(collision.road_layer):
						ground_tile_position.append(tile_mouse_pos)
						tilemap.set_cells_terrain_connect(collision.road_layer,ground_tile_position,terrain_set,collision.terrain)
				check = false

			modes.UPGRADE:
			#	collision.upgrade_collision_check()
				if check:
					print("upgrade!")
				check = false
	else:
		mode = modes.NOTHING
		visible = false
		check = false

func _reset_grid() -> void:
	hud.state(false, "all")
	mode = modes.NOTHING
	visible = false

func change_sprite(sprite:bool):
	if sprite:
		grid.texture = error
	else:
		grid.texture = default

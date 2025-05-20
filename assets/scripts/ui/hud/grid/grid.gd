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
@onready var buildManager:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var farmingManager:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var mail:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var collision:Node2D = $GridParent

var crops = Crops.new()
var blueprints = BlueprintManager.new()
var natural_resources = NaturalResources.new()

const SIZE:Vector2 = Vector2(16, 16)
var grid_dimensions:Vector2i = Vector2i(1,1)

var mode:int = modes.NOTHING
var destroy_mode:int = destroy.NOTHING
enum modes {NOTHING, DESTROY, FARMING, PLANTING, WATERING, HARVESTING, FERTILIZER, BUILD, TERRAIN_SET, UPGRADE}
enum destroy {NOTHING, TERRAINS, NATURE}

# plant config
var plantID
var inventory_item

# construct config
var id:int
var group:String
var terrain_set:Array = []
var terrain_required_layer:Array = []
var terrain_blocking_layer:Array = []

func _ready():
	set_process(false)

func _process(_delta):
	movement_grid()
	match mode:
		modes.DESTROY:
			match destroy_mode:
				destroy.TERRAINS:
					collision.terrain_check()
				destroy.NATURE:
					collision.nature_check()
		modes.FARMING:
			collision.farming_collision_check()
		modes.PLANTING:
			collision.planting_collision_check()
		modes.WATERING:
			collision.watering_collision_check()
			if tools\
			&& tip:
				if tools.water_can <= tools.water_can_max\
				&& tools.water_can != 0:
					tip.tooltip(
						tr('tooltip.water_can') 
						+':\n' + 
						str(tools.water_can) 
						+ "/" + 
						str(tools.water_can_max)
					)
				else:
					tip.tooltip(tr('tooltip.empty_water_can') + "!")
					if !GameLoader.first_empty_water_can:
						GameLoader.first_empty_water_can = true
						mail.letter(
							'letter.public_well_announcement_header',
							'letter.public_well_announcement_content',
							'letter.korney_korneich.signature'
						)
		modes.HARVESTING:
			collision.harvest_check()
		modes.FERTILIZER:
			collision.check_fertilizer_cell()
		modes.BUILD:
			collision.building_collision_check()
		modes.TERRAIN_SET:
			collision.terrain_collision_check(terrain_blocking_layer)
		modes.UPGRADE:
			return # in next update...

func _input(event):
	if visible\
	&& mode != modes.NOTHING:
		hud.hud_all_hide()
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed():
			if visible\
			&& !blur.state\
			&& mode != modes.NOTHING:
				if destroy_menu.opened: destroy_menu.close()
				match mode:
					modes.DESTROY:
						match destroy_mode:
							destroy.TERRAINS:
								destroy_terrains()
							destroy.NATURE:
								destroy_nature()

					modes.FARMING:
						farming()

					modes.WATERING:
						watering()

					modes.PLANTING:
						planting()

					modes.HARVESTING:
						harvesting()

					modes.BUILD:
						var global_mouse_position = get_global_mouse_position()
						var tile_position = tilemap.local_to_map(global_mouse_position)
						building(tile_position)

					modes.TERRAIN_SET:
						terrain()

					modes.UPGRADE:
						upgrade()

					modes.FERTILIZER:
						fertilizer()
			else:
				disabled_grid()

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_RIGHT\
	&& event.is_pressed()\
	&& visible\
	&& mode != modes.NOTHING:
		disabled_grid()
		for child in collision.get_children():
			child.queue_free()

func upgrade() -> void:
	return

func destroy_terrains() -> void:
	for c in collision.get_children():
		var grid_position = tilemap.local_to_map(c.get_global_position())
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

func destroy_nature() -> void:
	for i in collision.get_children():
		var grid_position = tilemap.local_to_map(i.get_global_position())
		match collision.nature_check():
			1:
				for a in nature.get_children():
					if grid_position == tilemap.local_to_map(a.position):
						nature.remove_child(a)
						a.queue_free()
				for b in shadows.get_children():
					if grid_position == tilemap.local_to_map(b.position):
						shadows.remove_child(b)
						b.queue_free()
				tilemap.erase_cell(collision.nature_layer, grid_position) 
				inventory.add_item(1, randi_range(1,5))
				play_sound('farming/tree_destroy')
			2:
				for a in nature.get_children():
					if grid_position == tilemap.local_to_map(a.position):
						nature.remove_child(a)
						a.queue_free()
				for b in shadows.get_children():
					if grid_position == tilemap.local_to_map(b.position):
						shadows.remove_child(b)
						b.queue_free()
				tilemap.erase_cell(collision.nature_layer, grid_position)
				play_sound('farming/weed_destroy')
			3:
				for a in nature.get_children():
					if grid_position == tilemap.local_to_map(a.position):
						nature.remove_child(a)
						a.queue_free()
				for b in shadows.get_children():
					if grid_position == tilemap.local_to_map(b.position):
						shadows.remove_child(b)
						b.queue_free()
				tilemap.erase_cell(collision.nature_layer, grid_position) 
				inventory.add_item(3, randi_range(1,5))
				if data.check_probability(15):
					inventory.add_item(5, randi_range(1,2))
				play_sound('farming/stone_destroy')
			4:
				tilemap.erase_cell(collision.crops_layer, grid_position)
				farmingManager.plant_destroy(grid_position)
				play_sound('farming/plant_destroy')

func farming() -> void:
	var farming_tile_position = []
	var collisions_detect = true
	for i in collision.get_children():
		var grid_position = tilemap.local_to_map(i.get_global_position())
		if collision.check_cell(grid_position, collision.road_layer)\
		&& collision.check_custom_data(grid_position, collision.can_place_dirt_custom_data, collision.road_layer):
			farming_tile_position.append(grid_position)
		if i.texture != collision.error:
			collisions_detect = false
			break
	if farming_tile_position.size() > 0:
		if !collisions_detect:
			tilemap.set_cells_terrain_connect(
				collision.farmland_layer,
				farming_tile_position,
				collision.terrain_set, 
				collision.farming_terrain
			)
			play_sound('farming/farming')

func watering() -> void:
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
				tilemap.set_cells_terrain_connect(
					collision.watering_layer,
					[grid_position],
					collision.terrain_set,
					collision.watering_terrain
				)
				play_sound('farming/watering_plant')

func planting() -> void:
	if inventory.check_item_amount(inventory_item):
		if inventory.get_item_amount(inventory_item) >= collision.get_children().size():
			for i in collision.get_children():
				var grid_position = tilemap.local_to_map(i.get_global_position())
				if main == "Farm":
					if farmingManager.check_season(plantID):
						if crops.crops.has(plantID):
							if collision.check_cell(grid_position, collision.farmland_layer)\
							&& !collision.check_cell(grid_position, collision.crops_layer)\
							&& collision.check_custom_data(
								grid_position, 
								collision.can_place_seed_custom_data, 
								collision.farmland_layer
							):
								inventory.subject_item(inventory_item, 1)
								farmingManager.create_plant(plantID, grid_position)
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
							farmingManager.create_plant(plantID, grid_position)
				play_sound('farming/planting')
		else:
			grid_dimensions.x = 1
			grid_dimensions.y = 1
			generate_grid()
	else:
		disabled_grid()

func harvesting() -> void:
	collision.harvest_check()
	for i in collision.get_children(): 
		var grid_position = tilemap.local_to_map(i.get_global_position())
		var harvest = collision.get_harvest_id(grid_position)
		if crops.crops.has(harvest) && harvest != 0:
			if storage.object[storage.level]["slots"] - inventory.get_all_items() != 0:
				if collision.get_harvest(grid_position):
					var crop_item:int = 0
					var crop_productivity:Array[int] = []
					var target_productivity:int = 0
					if data.check_probability(5):
						crop_item = crops.crops[harvest]["spoilage"]
						crop_productivity = crops.crops[harvest]["productivity"]
						target_productivity = randi_range(crop_productivity[0], crop_productivity[1])
					else:
						crop_item = crops.crops[harvest]["item"]
						crop_productivity = crops.crops[harvest]["productivity"]
						target_productivity = randi_range(crop_productivity[0], crop_productivity[1])
					inventory.add_item(crop_item, target_productivity)
					tilemap.erase_cell(collision.crops_layer, grid_position)
					farmingManager.plant_destroy(grid_position)
					play_sound('farming/harvesting')
			else:
				notifications.create_notice(tr("grid.harvesting.error.inventory_full"))

func building(mouse_position:Vector2i) -> void:
	var data_resources = {}
	if blueprints.content[group][id]["config"].has("resources"):
		for resource in blueprints.content[group][id]["config"]["resources"]:
			var required_amount = blueprints.content[group][id]["config"]["resources"][resource]["amount"]
			var available_amount = inventory.get_item_amount(resource)
			if available_amount >= required_amount:
				data_resources[resource] = {}
				data_resources[resource]["amount"] = required_amount
			else:
				disabled_grid()
	if collision.collisions_check():
		if blueprints.content.has(group):
			if blueprints.content[group].has(id):
				var node_name = blueprints.content[group][id]['config']['name']
				buildManager.create_node(id, mouse_position, node_name)
				play_sound('buildings/build')
				if data_resources.keys().size() > 0:
					for r in data_resources:
						inventory.subject_item(r, data_resources[r]['amount'])
				if blueprints.content[group][id]["config"].has('onlyInstance'):
					if blueprints.content[group][id]["config"]['onlyInstance']:
						disabled_grid()

func terrain() -> void:
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
				var terrain_index = terrain_set[index]
				tilemap.set_cells_terrain_connect(layer, positions, 0, terrain_index)

func fertilizer() -> void:
	if inventory.get_item_amount(inventory_item) >= collision.get_children().size():
		for i in collision.get_children():
			var local_position = tilemap.to_local(i.get_global_position())
			var grid_position = tilemap.local_to_map(local_position)
			if i.texture != collision.error:
				farmingManager.create_fertilizer(int(inventory_item), grid_position)
				inventory.subject_item(inventory_item, 1)
	else:
		disabled_grid()

func disabled_grid() -> void:
	hud.hud_all_show()
	mode = modes.NOTHING
	visible = false
	set_process(false)
	destroy_mode = destroy.NOTHING
	tip.tooltip()
	plantID = null
	inventory_item = null
	id = 0
	group = ''
	terrain_set = []
	terrain_required_layer = []
	terrain_blocking_layer = []

func generate_grid() -> void:
	set_process(true)
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
		grid_dimensions = Vector2i(
			tools.max_grid_dimensions,
			tools.max_grid_dimensions
		)
		generate_grid()

func movement_grid() -> void:
	var mouse_position = tilemap.get_global_mouse_position()
	var local_to_map = tilemap.local_to_map(mouse_position)
	var target_position = tilemap.map_to_local(local_to_map)
	self.set_position(target_position)

func play_sound(ogg_name:String) -> void:
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/'+ogg_name+'.ogg')
	audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()

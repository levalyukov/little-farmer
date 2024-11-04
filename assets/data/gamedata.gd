extends Node

@onready var main = str(get_tree().root.get_child(1).name)
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var cycle:Node2D = get_node("/root/"+main+"/Day-Night Cycle")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:Node2D = get_node("/root/"+main+"/Player")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var craft:Control = get_node("/root/"+main+"/UI/Interactive/Crafting")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Area2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridCollision")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var plant:PackedScene = load("res://assets/nodes/farming/plant.tscn")
@onready var language:Control = get_node("/root/"+main+"/UI/Interactive/Options/Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language")

var object_count:int
const paths:Dictionary = {
	game = "user://game.json",
	farm = "user://farm.json",
	world = "user://world.json",
	player = "user://player.json",
	buildings = "user://buildings.json",
	vectors = "user://vectors.json",
	crafting = "user://crafting.json",
	inventory = "user://inventory.json",
	mailbox = "user://letters.json",
}

func _ready():
	if main == "Farm":
		if GameLoader.mode:
			gameload()
			GameLoader.loading(false)
		else:
			pass
	else:
		time_load()
		balance_load()
		inventory_load()
		buildings_load()

func gamesave() -> void:
	file_save(paths.game, "settings")
	file_save(paths.farm, "farm")
	file_save(paths.world, "nature")
	file_save(paths.player, "player")
	file_save(paths.buildings, "buildings")
	file_save(paths.vectors, "vectors")
	file_save(paths.crafting, "craft")
	file_save(paths.inventory, "inventory")
	file_save(paths.mailbox, "mailbox")

func gameload() -> void:
	remove_all_child(farming)
	terrains_remove()
	plant_load()

	time_load()
	balance_load()
	buildings_load()
	inventory_load()
	craft_load()
	mailbox_load()
	
func file_save(path_file, content) -> void:
	var json_string = JSON.stringify(get_content(content), "\t")
	var file = FileAccess.open(path_file,FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
func file_load(path_file) -> Dictionary:
	var file = FileAccess.open(path_file,FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var parse_result = JSON.parse_string(json_string)
		return parse_result
	else:
		debug("ERROR: file not found: " + str(path_file), "ERROR")
		return {}
		
func get_key(path_file:String, key:String, group:String = ""):
	var file = file_load(path_file)
	if group != "":
		if file.has(str(group))\
		and typeof(file[str(group)]) == TYPE_DICTIONARY:
			var container = file[str(group)]
			if container.has(str(key)):
				return container[str(key)]
			return {}
	else:
		if file.has(str(key)):
			return file[str(key)]
		return {}

func create_terrain(index:int, layer:int, path_file:String, key:String, terrain_set:int, terrain:int):
	match index:
		0:
			var string_array = get_key(path_file, key)
			var vector_array = []
			
			for string in string_array:
				var cleaned_str = string.replace("(", "").replace(")", "")
				var components = cleaned_str.split(",")
				var x = components[0].to_float()
				var y = components[1].to_float()
				vector_array.append(Vector2(x, y))
				
				tilemap.set_cells_terrain_connect(layer, vector_array, terrain_set, terrain)
		1:
			var string_array = get_key(path_file, key)
			var vector_array = []

			for string in string_array:
				var cleaned_str = string.replace("(", "").replace(")", "")
				var components = cleaned_str.split(",")
				var x = components[0].to_float()
				var y = components[1].to_float()
				vector_array.append(Vector2(x, y))
			
			for vector in vector_array:
					tilemap.set_cell(layer, vector, 0, Vector2i(0,3))
		2: 
			var string_array = get_key(path_file, key)
			var vector_array = []
			for string in string_array:
				var cleaned_str = string.replace("(", "").replace(")", "")
				var components = cleaned_str.split(",")
				var x = components[0].to_float()
				var y = components[1].to_float()
				vector_array.append(Vector2(x, y))
				
			for vector in vector_array:
				return vector_array

func get_position_children(parent:Node2D) -> Array:
	var children = parent.get_children()
	var coordinates = []
	for child in children:
		if child is Node2D:
			coordinates.append(tilemap.local_to_map(child.global_position))
	return coordinates

func create_nodes(parent:Node2D, node:PackedScene, positions) -> void:
	if positions != null:
		for position in positions:
			var object = node.instantiate()
			if position is Vector2:
				object_count +=1
				object.name = "plant_" + str(object_count)
				var object_name = "plant_" + str(object_count)
				object.global_position = tilemap.map_to_local(position)
				object.z_index = 6
				if object.has_method("check_node"):
					parent.add_child(object)
					farm_load(object, object_name, position)
				else:
					debug("Cannot load node.", "error")
			else:
				debug("Variable position is not of type Vector2.", "error")

func remove_all_child(parent: Node):
	erase_cells(collision.crops_layer)
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	object_count = 0
	
func erase_cells(layer: int) -> void:
	var used_cells = tilemap.get_used_cells(layer)
	for cell in used_cells:
		tilemap.erase_cell(layer, cell)
	
func get_children_data(parent: Node) -> Dictionary:
	var data_dict = {}
	for child in parent.get_children():
		if child.has_method("get_data"):
			var child_data = child.get_data()
			data_dict[child.name] = child_data
	return data_dict

func plant_load():
	create_terrain(0, collision.road_layer, paths.vectors, "road", collision.ground_terrain_set, collision.terrain)
	create_terrain(0, collision.farmland_layer, paths.vectors, "farmlands", collision.farming_terrain_set, collision.terrain)
	create_terrain(0, collision.watering_layer, paths.vectors, "waterings", collision.watering_terrain_set, collision.terrain)
	create_terrain(1, collision.crops_layer, paths.vectors, "plants", 0, 0)
	create_nodes(farming, plant, create_terrain(2, collision.crops_layer, paths.vectors, "plants", -1, -1))

func farm_load(object:Node2D, object_name:String, position:Vector2i):
	var id = get_key(paths.farm, "plantID", object_name)
	var condition = get_key(paths.farm, "condition", object_name)
	var degree = get_key(paths.farm, "degree", object_name)
	var fertilizer = get_key(paths.farm, "fertilizer", object_name)
	var rect_x = get_key(paths.farm, "region_rect.x", object_name)
	var rect_y = get_key(paths.farm, "region_rect.y", object_name)
	var growth_level = get_key(paths.farm, "growth_level", object_name)

	if id != null\
	&& condition != null\
	&& degree != null\
	&& fertilizer != null\
	&& rect_x != null\
	&& rect_y != null\
	&& growth_level != null:
		object.set_data(id, condition, degree, fertilizer, rect_x, rect_y, growth_level, position)
	else:
		debug("Data missing for node: " + str(object_name), "error")

func terrains_remove() -> void:
	if collision.get_used_cells(collision.road_layer) != []:
		tilemap.set_cells_terrain_connect(
			collision.road_layer,
			collision.get_used_cells(collision.road_layer),
			collision.ground_terrain_set,
			-1
		)
		
	if collision.get_used_cells(collision.farmland_layer) != []:
		tilemap.set_cells_terrain_connect(
			collision.farmland_layer,
			collision.get_used_cells(collision.farmland_layer),
			collision.farming_terrain_set,
			-1
		)
		
	if collision.get_used_cells(collision.watering_layer) != []:
		tilemap.set_cells_terrain_connect(
			collision.watering_layer,
			collision.get_used_cells(collision.watering_layer),
			collision.watering_terrain_set,
			-1
		)

func time_load() -> void:
	clock.set_clock_value(
		get_key(paths.world, "year", "time"),
		get_key(paths.world, "month", "time"),
		get_key(paths.world, "week", "time"),
		get_key(paths.world, "day", "time"),
		get_key(paths.world, "hour", "time"),
		get_key(paths.world, "minute", "time")
	)
	cycle.set_cycle_value(get_key(paths.world, ".cycle", "time"), get_key(paths.world, ".passed", "time"))

func balance_load() -> void:
	balance.money = get_key(paths.player, "balance")
	balance.update_balance()

func inventory_load() -> void:
	inventory.load_content(file_load(paths.inventory))

func craft_load() -> void:
	craft.blueprints_clear()
	for i in get_key(paths.crafting, "blueprints"):
		craft.blueprints_load(int(i))

func mailbox_load() -> void:
	mailbox.letters_load(file_load(paths.mailbox))

func buildings_load() -> void:
	for content in file_load(paths.buildings):
		if file_load(paths.buildings)[content].has("level"):
			buildings.build_content(content, file_load(paths.buildings)[content]["level"])

func debug(content:String, type:String = "INFO") -> void:
	var system_datetime = Time.get_datetime_dict_from_system()
	var datetime:String = "["+str(system_datetime["year"])+"-"+str(system_datetime["month"])+"-"+str(system_datetime["day"])+" "+str(system_datetime["hour"])+":"+str(system_datetime["minute"])+":"+str(system_datetime["second"])+"]"
	match type.to_lower():
		"info":
			print(str(datetime) + " INFO: " + str(content))
		"error":
			print(str(datetime) + " ERROR: " + str(content))
		"warning":
			print(str(datetime) + " WARNING: " + str(content))
		_:
			print(str(datetime) + " " + str(content))

func get_content(content:String) -> Dictionary:
	match content:
		"settings": 
			return {
				"version": ProjectSettings.get_setting("application/config/version"),
				"language": language.lang,
			}

		"player":
			return {
				"balance": balance.money,
			}
			
		"nature":
			return {
				"time": {
					"year": clock.year,
					"month": clock.month,
					"week": clock.week,
					"day": clock.day,
					"hour": clock.hour,
					"minute": clock.minute,
					".cycle": cycle.get_cycle_value(),
					".passed": cycle.time_passed
				}
			}
			
		"vectors":
			return {
				"road": collision.get_used_cells(collision.road_layer),
				"farmlands": collision.get_used_cells(collision.farmland_layer),
				"waterings": collision.get_used_cells(collision.watering_layer),	
				"plants": get_position_children(farming),
			}
			
		"farm":
			return get_children_data(farming)
			
		"buildings":
			return buildings.get_buildings()

		"inventory":
			return inventory.get_items()

		"craft":
			return {
				"blueprints": craft.get_blueprints()
			}
			
		"mailbox":
			return mailbox.get_letters()

		_:
			return {}

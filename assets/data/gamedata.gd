extends Node

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var cycle:Node2D = get_node("/root/"+main+"/Day-Night Cycle")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:Node2D = get_node("/root/"+main+"/Player")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var craft:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var language:Control = get_node("/root/"+main+"/UI/Interactive/Options/Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language")
@onready var plant:PackedScene = load("res://assets/nodes/farming/plant.tscn")

var object_count:int
const path:Dictionary = {
	main = "user://.game",
	data = "user://.game/data",
	player = "user://.game/data/player",
	farm = "user://.game/data/farm",
	vectors = "user://.game/data/farm/vectors",
}

const file:Dictionary = {
	config = "user://.game/config.json",
	farm = "user://.game/data/farm/farm.json",
	world = "user://.game/data/world.json",
	nature = "user://.game/data/nature.json",
	player = "user://.game/data/player/player.json",
	buildings = "user://.game/data/player/buildings.json",
	crafting = "user://.game/data/player/crafting.json",
	inventory = "user://.game/data/player/inventory.json",
	mailbox = "user://.game/data/player/letters.json",
	# vectors
	vctr_roads = "user://.game/data/farm/vectors/roads.json",
	vctr_farmlands = "user://.game/data/farm/vectors/farmlands.json",
	vctr_waterings = "user://.game/data/farm/vectors/waterings.json",
	vctr_plants = "user://.game/data/farm/vectors/plants.json",
	vctr_coast = "user://.game/data/farm/vectors/coast.json",
	vctr_water = "user://.game/data/farm/vectors/water.json",
}

func _ready():
	gameload()
	if main == "Farm":
		if GameLoader.mode:
			gameload()
			GameLoader.loading(false)
		if GameLoader.start:
			nature.create_start_nature()
	else:
		time_load()
		balance_load()
		inventory_load()
		buildings_load()

func gamesave() -> void:
	file_save([path.main], file.config, get_dictionary_content("config"))
	# main data
	file_save([path.data], file.world, get_dictionary_content("world"))
	file_save([path.data], file.nature, get_dictionary_content("nature"))
	file_save([path.player], file.player, get_dictionary_content("player"))
	file_save([path.player], file.buildings, get_dictionary_content("buildings"))
	file_save([path.player], file.crafting, get_dictionary_content("craft"))
	file_save([path.player], file.inventory, get_dictionary_content("inventory"))
	file_save([path.player], file.mailbox, get_dictionary_content("mailbox"))
	# vectors
	file_save([path.vectors], file.farm, get_dictionary_content("farm"))
	file_save([path.vectors], file.vctr_roads, get_dictionary_content("vectors", "roads"))
	file_save([path.vectors], file.vctr_farmlands, get_dictionary_content("vectors", "farmlands"))
	file_save([path.vectors], file.vctr_waterings, get_dictionary_content("vectors", "waterings"))
	file_save([path.vectors], file.vctr_plants, get_dictionary_content("vectors", "plants"))
	file_save([path.vectors], file.vctr_coast, get_dictionary_content("vectors", "coast"))
	file_save([path.vectors], file.vctr_water, get_dictionary_content("vectors", "water"))

func gameload() -> void:
	remove_all_child(farming)
	terrains_remove()
	plant_load()
	vectors_load()

	load_nature_nodes()

	#time_load()
	#balance_load()
	#buildings_load()
	#inventory_load()
	#craft_load()
	#mailbox_load()
	
func file_save(_path:Array[String], _file:String, _content:Dictionary) -> void:
	if _path != []:
		for i in _path:
			var target_path = DirAccess.open(i)
			var target_file = FileAccess.open(_file, FileAccess.WRITE)
			if target_path:
				target_file.store_string(JSON.stringify(_content, "\t"))
				target_file.close()
			else:
				FileSystem.new().Funcs.create_directory(i)
				file_save(_path, _file, _content)
	
func file_load(path_file:String) -> Dictionary:
	var target_file = FileAccess.open(path_file,FileAccess.READ)
	if target_file:
		var result = JSON.parse_string(target_file.get_as_text())
		target_file.close()
		return result
	else:
		debug("file not found: " + str(path_file), "ERROR")
		return {}
		
func get_key(path_file:String, key:String, group:String = ""):
	var target_file = file_load(path_file)
	if group != "":
		if target_file.has(group)\
		&& typeof(target_file[group]) == TYPE_DICTIONARY:
			var container = target_file[group]
			if container.has(key):
				return container[key]
			return {}
	else:
		if target_file.has(key):
			return target_file[key]
		return {}

func get_vector_array(path_file:String, key:String) -> Array[Vector2i]:
	var string_array = get_key(path_file, key)
	var vector_array:Array[Vector2i] = []
	for string in string_array:
		var cleaned_str = string.replace("(", "").replace(")", "")
		var components = cleaned_str.split(",")
		var x = components[0].to_float()
		var y = components[1].to_float()
		vector_array.append(Vector2i(x, y))
	return vector_array

func string_to_vector(vector_string:String) -> Vector2i:
	var cleaned_str = vector_string.replace("(", "").replace(")", "")
	var components = cleaned_str.split(",")
	if components.size() < 2:
		debug("Invalid vector format: " + vector_string, "error")
		return Vector2i()
	var x = components[0].to_int()
	var y = components[1].to_int()
	return Vector2i(x, y)

func create_nodes(parent:Node2D, node:PackedScene, positions:Array[Vector2i]) -> void:
	if positions != null:
		for position in positions:
			var object = node.instantiate()
			if position is Vector2i:
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

func plant_load():
	#create_terrains(collision.road_layer, get_vector_array(file.vctr_roads, "roads"), collision.roads_terrain_set, 0)
	pass

func load_nature_nodes():
	var natures = file_load(file.nature)
	if natures != {}:
		for i in natures:
			match natures[i]["type"]:
				"stone":
					nature.load_natural_obj(
						nature.stone_node, 
						str(i), 
						nature.stones[natures[i]["sprite_index"]], 
						natures[i]["sprite_index"],
						string_to_vector(natures[i]["position"]),
						natures[i]["health"],
						nature.stones_shadow[natures[i]["sprite_index"]],
					)
					tilemap.set_cell(
						collision.nature_layer, 
						string_to_vector(
							natures[i]["position"]
							), 
						0, 
						Vector2i(0, 3)
					)
				"tree":
					nature.load_natural_obj(
						nature.tree_node, 
						str(i), 
						nature.trees[natures[i]["sprite_index"]], 
						natures[i]["sprite_index"],
						string_to_vector(natures[i]["position"]),
						natures[i]["health"],
						nature.trees_shadow[natures[i]["sprite_index"]],
					)
					tilemap.set_cell(
						collision.nature_layer, 
						string_to_vector(
							natures[i]["position"]
							), 
						0, 
						Vector2i(0, 3)
					)
				"weed":
					nature.load_natural_obj(
						nature.weed_node, 
						str(i), 
						nature.weeds[natures[i]["sprite_index"]], 
						natures[i]["sprite_index"],
						string_to_vector(natures[i]["position"]),
						natures[i]["health"],
						nature.weeds_shadow[natures[i]["sprite_index"]],
					)
					tilemap.set_cell(
						collision.nature_layer, 
						string_to_vector(
							natures[i]["position"]
							), 
						0, 
						Vector2i(0, 3)
					)
				_:
					pass

func vectors_load():
	create_terrains(collision.road_layer, get_vector_array(file.vctr_roads, "roads"), collision.roads_terrain_set, 0)
	create_terrains(collision.farmland_layer, get_vector_array(file.vctr_roads, "farmlands"), collision.farming_terrain_set, 0)
	create_terrains(collision.watering_layer, get_vector_array(file.vctr_roads, "watering"), collision.watering_terrain_set, 0)
	create_terrains(collision.coast_layer, get_vector_array(file.vctr_roads, "coast"), collision.coast_terrain_set, 0)
	create_terrains(collision.water_layer, get_vector_array(file.vctr_roads, "water"), collision.water_terrain_set, 0)

func create_terrains(layer:int, vectors:Array[Vector2i], terrain_set:int, terrain:int):
	tilemap.set_cells_terrain_connect(layer, vectors, terrain_set, terrain)

func farm_load(object:Node2D, object_name:String, position:Vector2i):
	var id = get_key(file.farm, "plantID", object_name)
	var condition = get_key(file.farm, "condition", object_name)
	var degree = get_key(file.farm, "degree", object_name)
	var fertilizer = get_key(file.farm, "fertilizer", object_name)
	var rect_x = get_key(file.farm, "region_rect.x", object_name)
	var rect_y = get_key(file.farm, "region_rect.y", object_name)
	var growth_level = get_key(file.farm, "growth_level", object_name)

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
			collision.roads_terrain_set,
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
		get_key(file.world, "year", "time"),
		get_key(file.world, "month", "time"),
		get_key(file.world, "week", "time"),
		get_key(file.world, "day", "time"),
		get_key(file.world, "hour", "time"),
		get_key(file.world, "minute", "time")
	)
	cycle.set_cycle_value(get_key(file.world, ".cycle", "time"), get_key(file.world, ".passed", "time"))

func balance_load() -> void:
	balance.money = get_key(file.player, "balance")
	balance.update_balance()

func inventory_load() -> void:
	inventory.load_content(file_load(file.inventory))

func craft_load() -> void:
	craft.blueprints_clear()
	for i in get_key(file.crafting, "blueprints"):
		craft.blueprints_load(int(i))

func mailbox_load() -> void:
	mailbox.letters_load(file_load(file.mailbox))

func buildings_load() -> void:
	if file_load(file.buildings) != {}:
		for content in file_load(file.buildings):
			if buildings.all_buildings.has(remove_suffix(content)):
				if file_load(file.buildings)[content].has("position"):
					buildings.construct_load(content, buildings.all_buildings[remove_suffix(content)], string_to_vector(file_load(file.buildings)[content]["position"]))
				if file_load(file.buildings)[content].has("TextureRect_sprite"):
					buildings.construct_load_sprites(content, file_load(file.buildings)[content]["TextureRect_sprite"])
	else:
		debug("building_load(): Empty dictionary.", "error")

func remove_suffix(input:String) -> String:
	var regex = RegEx.new()
	regex.compile("_[0-9]+$")
	return regex.sub(input, "")

func debug(content:String, type:String = "info") -> void:
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

func get_dictionary_content(content:String, group:String = "") -> Dictionary:
	match content:
		"config": 
			return {
				"version": ProjectSettings.get_setting("application/config/version"),
				"language": language.lang,
			}

		"player":
			return {
				"balance": balance.money,
			}
			
		"nature":
			return nature.get_all_nature()

		"world":
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
			match group.to_lower():
				"roads":	
					return {
						"roads": collision.get_used_cells(collision.road_layer)
					}
				"farmlands":
					return {
						"farmlands": collision.get_used_cells(collision.farmland_layer)
					}
				"waterings":
					return {
						"waterings": collision.get_used_cells(collision.watering_layer)
					}
				"plants":
					return {
						"plants": collision.get_position_children(farming)
					}
				"coast":
					return {
						"coast": collision.get_used_cells(collision.coast_layer)
					}
				"water":
					return {
						"water": collision.get_used_cells(collision.water_layer)
					}
				_:
					return {}
			
		"farm":
			return farming.get_all_plants()

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

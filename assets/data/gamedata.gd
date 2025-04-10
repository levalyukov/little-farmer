extends Node

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var cycle:Node2D = get_node("/root/"+main+"/Day-Night Cycle")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:Node2D = get_node("/root/"+main+"/Player")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var craft:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var teleport:Node2D = get_node('/root/'+main+'Teleports/Village')
@onready var plant:PackedScene = load("res://assets/nodes/farming/plant.tscn")

var music:AudioStreamPlayer = AudioStreamPlayer.new()
var music_cooldown:Timer = Timer.new()
var global_index_audio = -1

const path:Dictionary = {
	main = "user://game",
	data = "user://game/data",
	player = "user://game/data/player",
	farm = "user://game/data/farm",
	vectors = "user://game/data/farm/vectors",
}

const file:Dictionary = {
	# files
	config = "user://game/config.json",
	farm = "user://game/data/farm/farm.json",
	world = "user://game/data/world.json",
	nature = "user://game/data/nature.json",
	buildings = "user://game/data/farm/buildings.json",
	player = "user://game/data/player/player.json",
	blueprints = "user://game/data/player/blueprints.json",
	inventory = "user://game/data/player/inventory.json",
	mailbox = "user://game/data/player/mailbox.json",
	# vectors
	vctr_roads = "user://game/data/farm/vectors/roads.json",
	vctr_farmlands = "user://game/data/farm/vectors/farmlands.json",
	vctr_waterings = "user://game/data/farm/vectors/waterings.json",
	vctr_plants = "user://game/data/farm/vectors/plants.json",
	vctr_coast = "user://game/data/farm/vectors/coast.json",
	vctr_water = "user://game/data/farm/vectors/water.json",
}

var music_playlist:Dictionary = {
	'spring' = [
		'res://assets/sounds/music/flp/spring/test_music_track.mp3',
		'res://assets/sounds/music/flp/spring/music_2.mp3',
		'res://assets/sounds/music/flp/spring/music_3.mp3',
	],
	'summer' = [
		'res://assets/sounds/music/flp/summer/music_1.mp3',
		'res://assets/sounds/music/flp/summer/music_2.mp3',
	],
	'autumn' = [
		'res://assets/sounds/music/flp/autumn/music_1.mp3',
		'res://assets/sounds/music/flp/autumn/music_2.mp3',
	],
	'winter' = [
		'res://assets/sounds/music/flp/winter/music_1.mp3',
		'res://assets/sounds/music/flp/winter/music_2.mp3',
	],
}

func _ready():
	# timer (cooldown)
	self.add_child(music_cooldown)
	music_cooldown.name = 'MusicCooldownTimer'
	music_cooldown.connect("timeout", Callable(self, "_on_timer_timeout").bind())
	# audio stream player
	self.add_child(music)
	music.name = 'MusicPlayer'
	music.bus = 'Music'
	music.connect("finished", Callable(self, "_on_music_stream_player_finished").bind())
	play_music(music_playlist)
	if main == "Farm":
		# Game Load
		if GameLoader.mode\
		&& !GameLoader.start:
			gameload()
			GameLoader.mode = false
			if file_load(file.world):
				if file_load(file.world).has('greenhouse_data'):
					if file_load(file.world)['greenhouse_data']:
						if file_load(file.world)['greenhouse_data'] != {}:
							GameLoader.greenhouse_plants = file_load(file.world)['greenhouse_data']
							GameLoader.create_timers()
			if file_load(file.player):
				if file_load(file.player).has('tools_level'):
					if file_load(file.player)['tools_level'].has('water_can'):
						tools.water_can = file_load(file.player)['tools_level']['water_can']
		# New Game
		if !GameLoader.mode\
		&& GameLoader.start:
			start_newgame()
			GameLoader.start = false
	else:
		if main != "MainMenu":
			load_time()
			load_balance()
			load_inventory()
			load_blueprints()
			load_mailbox()
			config_load()
			if main == "Farm": load_buildings()
			if main == "Greenhouse": greenhouse_get_data(GameLoader.greenhouse_caption)
			if file_load(file.player):
				if file_load(file.player).has('tools_level'):
					if file_load(file.player)['tools_level'].has('water_can'):
						tools.water_can = file_load(file.player)['tools_level']['water_can']

func gamesave() -> void:
	# main data
	file_save([path.data], file.world, get_dictionary_content("world"))
	file_save([path.data], file.nature, get_dictionary_content("nature"))
	file_save([path.player], file.player, get_dictionary_content("player"))
	file_save([path.farm], file.buildings, get_dictionary_content("buildings"))
	file_save([path.player], file.blueprints, get_dictionary_content("blueprints"))
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
	# config
	config_save()

func gameload() -> void:
	# Player
	load_time()
	load_balance()
	load_buildings()
	load_inventory()
	load_blueprints()
	load_mailbox()
	# Scene
	remove_all_child(farming)
	remove_all_terrains()
	vectors_load()
	load_nature_nodes()
	plant_load()
	# Config
	config_load()
	
func file_save(_path:Array, _file:String, _content:Dictionary) -> void:
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

func file_load_sort(path_file:String) -> Dictionary:
	var target_file = FileAccess.open(path_file, FileAccess.READ)
	if target_file:
		var file_content = target_file.get_as_text()
		target_file.close()
		var json_parser = JSON.new()
		var parsed_data = json_parser.parse(file_content)
		if parsed_data:
			if parsed_data.result.type == TYPE_DICTIONARY:
				var sorted_keys = parsed_data.result.keys().map(func(key): int(key))
				sorted_keys.sort()
				var sorted_dict = {}
				for key in sorted_keys:
					sorted_dict[str(key)] = parsed_data.result[str(key)]
				return sorted_dict
	return {}
		
func get_key(path_file:String, key:String, group:String = ""):
	var target_file = file_load(path_file)
	if group != "":
		if target_file.has(group)\
		&& typeof(target_file[group]) == TYPE_DICTIONARY:
			var container = target_file[group]
			if container.has(key):
				return container[key]
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

func remove_all_child(parent: Node):
	erase_cells(collision.crops_layer)
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func erase_cells(layer: int) -> void:
	var used_cells = tilemap.get_used_cells(layer)
	for cell in used_cells:
		tilemap.erase_cell(layer, cell)

func plant_load():
	create_cell(get_vector_array(file.vctr_plants, "plants"))
	load_plant(file.farm)

func load_plant(content_path:String, group:String = ""):
	if group == "":
		for i in file_load(content_path):
			if remove_suffix(i) == 'plant':
				var node = plant.instantiate()
				farming.add_child(node)
				if GameLoader.tracking_plants:
					GameLoader.timer_farm_plant_stop()
					if file_load(content_path)[i]["time_left"]-GameLoader.time_left > 0.0\
					&& file_load(content_path)[i]["condition"] == 1:
						node.set_data(
							file_load(content_path)[i]["plantID"],
							file_load(content_path)[i]["condition"],
							file_load(content_path)[i]["degree"],
							file_load(content_path)[i]["fertilizer"],
							file_load(content_path)[i]["region_rect.x"],
							file_load(content_path)[i]["region_rect.y"],
							file_load(content_path)[i]["growth_level"],
							string_to_vector(file_load(content_path)[i]["position"]),
							2,
							i,
							file_load(content_path)[i]["time_left"]-GameLoader.time_left,
						)
					else:
						if file_load(content_path)[i]["condition"] == 1:
							node.set_data(
								file_load(content_path)[i]["plantID"],
								file_load(content_path)[i]["condition"],
								file_load(content_path)[i]["degree"],
								file_load(content_path)[i]["fertilizer"],
								file_load(content_path)[i]["region_rect.x"],
								file_load(content_path)[i]["region_rect.y"],
								file_load(content_path)[i]["growth_level"],
								string_to_vector(file_load(content_path)[i]["position"]),
								2,
								i,
								0,
							)
							node.check_water(
								tilemap.map_to_local(string_to_vector(file_load(content_path)[i]["position"]))
							)
							node.increase_growth()
						else:
							node.set_data(
								file_load(content_path)[i]["plantID"],
								file_load(content_path)[i]["condition"],
								file_load(content_path)[i]["degree"],
								file_load(content_path)[i]["fertilizer"],
								file_load(content_path)[i]["region_rect.x"],
								file_load(content_path)[i]["region_rect.y"],
								file_load(content_path)[i]["growth_level"],
								string_to_vector(file_load(content_path)[i]["position"]),
								2,
								i,
								0,
							)
				else:
					node.set_data(
						file_load(content_path)[i]["plantID"],
						file_load(content_path)[i]["condition"],
						file_load(content_path)[i]["degree"],
						file_load(content_path)[i]["fertilizer"],
						file_load(content_path)[i]["region_rect.x"],
						file_load(content_path)[i]["region_rect.y"],
						file_load(content_path)[i]["growth_level"],
						string_to_vector(file_load(content_path)[i]["position"]),
						2,
						i,
						file_load(content_path)[i]["time_left"],
					)
			if remove_suffix(i) == 'fertilizer':
				farming.create_fertilizer(
					file_load(content_path)[i]["fertilizerID"],
					string_to_vector(file_load(content_path)[i]["position"])
				)
		if GameLoader.tracking_plants:
			GameLoader.tracking_plants = !true
	else:
		if file_load(content_path).has(group):
			for i in file_load(content_path)[group]:
				if remove_suffix(i) == 'plant':
					var node = plant.instantiate()
					farming.add_child(node)
					if GameLoader.greenhouse_plants != {}:
						if GameLoader.greenhouse_plants.has(GameLoader.greenhouse_caption):
							if GameLoader.greenhouse_plants[GameLoader.greenhouse_caption].has('time_left'):
								if GameLoader.greenhouse_plants[GameLoader.greenhouse_caption]['time_left'] > 0:
									if file_load(content_path)[group][i]["time_left"]-GameLoader.greenhouse_plants[GameLoader.greenhouse_caption]['time_left'] > 0.0\
									&& file_load(content_path)[group][i]["condition"] == 1:
										GameLoader.timer_greenhouse_plant_stop()
										node.set_data(
											file_load(content_path)[group][i]["plantID"],
											file_load(content_path)[group][i]["condition"],
											file_load(content_path)[group][i]["degree"],
											file_load(content_path)[group][i]["fertilizer"],
											file_load(content_path)[group][i]["region_rect.x"],
											file_load(content_path)[group][i]["region_rect.y"],
											file_load(content_path)[group][i]["growth_level"],
											string_to_vector(file_load(content_path)[group][i]["position"]),
											2,
											i,
											file_load(content_path)[group][i]["time_left"]-GameLoader.greenhouse_plants[GameLoader.greenhouse_caption]['time_left']
										)
									else:
										if file_load(content_path)[group][i]["condition"] == 1:
											node.set_data(
												file_load(content_path)[group][i]["plantID"],
												file_load(content_path)[group][i]["condition"],
												file_load(content_path)[group][i]["degree"],
												file_load(content_path)[group][i]["fertilizer"],
												file_load(content_path)[group][i]["region_rect.x"],
												file_load(content_path)[group][i]["region_rect.y"],
												file_load(content_path)[group][i]["growth_level"],
												string_to_vector(file_load(content_path)[group][i]["position"]),
												2,
												i,
												file_load(content_path)[group][i]["time_left"]
											)
											node.check_water(
												tilemap.map_to_local(string_to_vector(file_load(content_path)[group][i]["position"]))
											)
											node.increase_growth()
										else:
											node.set_data(
												file_load(content_path)[group][i]["plantID"],
												file_load(content_path)[group][i]["condition"],
												file_load(content_path)[group][i]["degree"],
												file_load(content_path)[group][i]["fertilizer"],
												file_load(content_path)[group][i]["region_rect.x"],
												file_load(content_path)[group][i]["region_rect.y"],
												file_load(content_path)[group][i]["growth_level"],
												string_to_vector(file_load(content_path)[group][i]["position"]),
												2,
												i,
												file_load(content_path)[group][i]["time_left"]
											)
								else:
									node.set_data(
										file_load(content_path)[group][i]["plantID"],
										file_load(content_path)[group][i]["condition"],
										file_load(content_path)[group][i]["degree"],
										file_load(content_path)[group][i]["fertilizer"],
										file_load(content_path)[group][i]["region_rect.x"],
										file_load(content_path)[group][i]["region_rect.y"],
										file_load(content_path)[group][i]["growth_level"],
										string_to_vector(file_load(content_path)[group][i]["position"]),
										2,
										i,
										file_load(content_path)[group][i]["time_left"]
									)
							else:
								node.set_data(
									file_load(content_path)[group][i]["plantID"],
									file_load(content_path)[group][i]["condition"],
									file_load(content_path)[group][i]["degree"],
									file_load(content_path)[group][i]["fertilizer"],
									file_load(content_path)[group][i]["region_rect.x"],
									file_load(content_path)[group][i]["region_rect.y"],
									file_load(content_path)[group][i]["growth_level"],
									string_to_vector(file_load(content_path)[group][i]["position"]),
									2,
									i,
									file_load(content_path)[group][i]["time_left"]
								)
						else:
							node.set_data(
								file_load(content_path)[group][i]["plantID"],
								file_load(content_path)[group][i]["condition"],
								file_load(content_path)[group][i]["degree"],
								file_load(content_path)[group][i]["fertilizer"],
								file_load(content_path)[group][i]["region_rect.x"],
								file_load(content_path)[group][i]["region_rect.y"],
								file_load(content_path)[group][i]["growth_level"],
								string_to_vector(file_load(content_path)[group][i]["position"]),
								2,
								i,
								file_load(content_path)[group][i]["time_left"]
							)
					else:
						node.set_data(
							file_load(content_path)[group][i]["plantID"],
							file_load(content_path)[group][i]["condition"],
							file_load(content_path)[group][i]["degree"],
							file_load(content_path)[group][i]["fertilizer"],
							file_load(content_path)[group][i]["region_rect.x"],
							file_load(content_path)[group][i]["region_rect.y"],
							file_load(content_path)[group][i]["growth_level"],
							string_to_vector(file_load(content_path)[group][i]["position"]),
							2,
							i,
							file_load(content_path)[group][i]["time_left"]
						)

				if remove_suffix(i) == 'fertilizer':
					farming.create_fertilizer(
						file_load(content_path)[group][i]["fertilizerID"],
						string_to_vector(file_load(content_path)[group][i]["position"])
					)
			GameLoader.greenhouse_plants[GameLoader.greenhouse_caption]['time_left'] = 0.0
			
func load_nature_nodes():
	nature.clear_all_arrays()
	nature.new_texture()
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
	create_terrains(
		collision.road_layer, 
		get_vector_array(file.vctr_roads, "roads"), 
		collision.terrain_set, 
		collision.roads_terrain
	)
	create_terrains(
		collision.farmland_layer, 
		get_vector_array(file.vctr_farmlands, "farmlands"), 
		collision.terrain_set, 
		collision.farming_terrain
	)
	create_terrains(
		collision.watering_layer, 
		get_vector_array(file.vctr_waterings, "waterings"), 
		collision.terrain_set, 
		collision.watering_terrain
	)
	create_terrains(
		collision.coast_layer, 
		get_vector_array(file.vctr_coast, "coast"), 
		collision.terrain_set, 
		collision.coast_terrain
	)
	create_terrains(
		collision.water_layer, 
		get_vector_array(file.vctr_water, "water"), 
		collision.terrain_set, 
		collision.water_terrain
	)

func create_terrains(layer:int, vectors:Array[Vector2i], terrain_set:int, terrain:int):
	tilemap.set_cells_terrain_connect(layer, vectors, terrain_set, terrain)

func create_cell(vectors:Array[Vector2i]):
	for i in vectors:
		tilemap.set_cell(collision.crops_layer, i, 0,Vector2i(0,3))

func remove_all_terrains() -> void:
	if collision.get_used_cells(collision.road_layer) != []:
		tilemap.set_cells_terrain_connect(
			collision.road_layer,
			collision.get_used_cells(collision.road_layer),
			collision.terrain_set,
			-1
		)
		
	if collision.get_used_cells(collision.farmland_layer) != []:
		tilemap.set_cells_terrain_connect(
			collision.farmland_layer,
			collision.get_used_cells(collision.farmland_layer),
			collision.terrain_set,
			-1
		)
		
	if collision.get_used_cells(collision.watering_layer) != []:
		tilemap.set_cells_terrain_connect(
			collision.watering_layer,
			collision.get_used_cells(collision.watering_layer),
			collision.terrain_set,
			-1
		)

func load_time() -> void:
	clock.set_clock_value(
		get_key(file.world, "season_id", "time"),
		get_key(file.world, "year", "time"),
		get_key(file.world, "week", "time"),
		get_key(file.world, "day", "time"),
		get_key(file.world, "hour", "time"),
		get_key(file.world, "minute", "time")
	)
	cycle.set_cycle_value(get_key(file.world, "hour", "time"))

func load_balance() -> void:
	balance.money = get_key(file.player, "balance")
	balance.update_balance()

func load_inventory() -> void:
	inventory.load_content(file_load(file.inventory))

func load_blueprints() -> void:
	craft.clear_blueprints()
	var terrains_blueprints:Array[int] = []
	var node_blueprints:Array[int] = []
	var upgrade_blueprints:Array[int] = []
	for i in get_key(file.blueprints, "terrains_blueprints"):
		terrains_blueprints.append(int(i))
	for i in get_key(file.blueprints, "node_blueprints"):
		node_blueprints.append(int(i))
	for i in get_key(file.blueprints, "upgrade_blueprints"):
		upgrade_blueprints.append(int(i))
	craft.load_blueprints(terrains_blueprints, node_blueprints, upgrade_blueprints)

func load_mailbox() -> void:
	mailbox.letters_load(file_load(file.mailbox))

func load_buildings() -> void:
	if file_load(file.buildings) != {}:
		for i in file_load(file.buildings):
			if file_load(file.buildings)[i].has("id"):
				buildings.create_node(
					file_load(file.buildings)[i]["id"], 
					string_to_vector(file_load(file.buildings)[i]["position"]),
					i
				)
				if file_load(file.buildings)[i].has("level"):
					for node in buildings.get_children():
						if i == node.name:
							node.level = file_load(file.buildings)[i]["level"]
					
				if file_load(file.buildings)[i].has("sprite_id"):
					for node in buildings.get_children():
						if i == node.name:
							var sprite_id = file_load(file.buildings)[i]["sprite_id"]
							node.set_sign_sprite(int(sprite_id))

				if file_load(file.buildings)[i].has("all_collisions"):
					for node in buildings.get_children():
						if i == node.name:
							var target_vectors:Array[Vector2i] = []	
							for a in file_load(file.buildings)[i]['all_collisions']:
								target_vectors.append(string_to_vector(a))
							node.all_collisions = target_vectors

				if file_load(file.buildings)[i].has("value"):
					for node in buildings.get_children():
						if i == node.name:
							match remove_suffix(i):
								"composter":
									if file_load(file.buildings)[i].has("total_items")\
									&& file_load(file.buildings)[i].has("state"):
										node.composting = file_load(file.buildings)[i]['state']
										node.composting_value = file_load(file.buildings)[i]['value']
										node.update()
										node.start_compost(file_load(file.buildings)[i]['total_items'])
								"lamp_post":
									node.light.visible = file_load(file.buildings)[i]['value']
									node.update()
								"forge":
									if file_load(file.buildings)[i].has("value")\
									&& file_load(file.buildings)[i].has("inProcessed")\
									&& file_load(file.buildings)[i].has("isDone")\
									&& file_load(file.buildings)[i].has("oreID")\
									&& file_load(file.buildings)[i].has("oreAmount")\
									&& file_load(file.buildings)[i].has("fuelID")\
									&& file_load(file.buildings)[i].has("fuelAmount")\
									&& file_load(file.buildings)[i].has("ignotID")\
									&& file_load(file.buildings)[i].has("ignotAmount"):
										if file_load(file.buildings)[i]['inProcessed']:
											node.value_process = file_load(file.buildings)[i]['value']
											node.start_melt(
												file_load(file.buildings)[i]['oreID'],
												file_load(file.buildings)[i]['oreAmount'],
												file_load(file.buildings)[i]['fuelID'],
												file_load(file.buildings)[i]['fuelAmount']
											)
										elif file_load(file.buildings)[i]['isDone']:
											node.isDone = file_load(file.buildings)[i]['isDone']
											node.ignot_id = file_load(file.buildings)[i]['ignotID']
											node.ignot_amount = file_load(file.buildings)[i]['ignotAmount']
								_:
									pass
	else:
		debug("load_buildings(): Empty dictionary.", "error")

func get_dictionary_content(content:String, group:String = "") -> Dictionary:
	match content:
		"player":
			return {
				'indicator_mailbox': GameLoader.mailbox_indicator,
				"balance": balance.money,
				"tools_level": {
					"water_can_max": tools.water_can_max,
					"water_can": tools.water_can,
					"hoe": tools.hoe,
					"watering_can": tools.watering_can,
					"sickle": tools.sickle,
					"planting": tools.planting,
					"axe": tools.axe,
					"pickaxe": tools.pickaxe,
					"destroy": tools.destroy,
				}
			}
			
		"nature":
			return nature.get_all_nature()

		"world":
			return {
				'greenhouse_data': GameLoader.greenhouse_plants,
				"time": {
					"season_id": clock.season,
					"year": clock.year,
					"week": clock.week,
					"day": clock.day,
					"hour": clock.hour,
					"minute": clock.minute,
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

		"blueprints":
			return craft.get_blueprints()
			
		"mailbox":
			return mailbox.get_letters()

		_:
			return {}

func _input(_event):
	if Input.is_action_just_pressed("f2"):
		take_screenshot()

func take_screenshot():
	var viewport = get_viewport()
	var texture = viewport.get_texture()
	var image = texture.get_image()
	var main_directory = DirAccess.open("user://game")
	var target_directory = DirAccess.open("user://game/.screenshots")
	var file_name = "user://game/.screenshots/screenshot-" + str(Time.get_date_string_from_system()) + "-" + str(Time.get_ticks_msec()) + ".png".format(Time.get_ticks_msec())
	if main_directory:
		if target_directory:
			if image.save_png(file_name) == OK:
				debug("Screenshot saved: " + str(file_name), "info")
				notice.create_notice(tr("Скриншот сохранен") + ": " + "screenshot-" + str(Time.get_date_string_from_system()) + "-" + str(Time.get_ticks_msec()) + ".png", "photo")
			else:
				debug("Couldn't save screenshot", "error")
		else:
			FileSystem.new().Funcs.create_directory("user://game/.screenshots")
			take_screenshot()
	else:
		FileSystem.new().Funcs.create_directory("user://game")
		take_screenshot()

func remove_suffix(input:String) -> String:
	var regex = RegEx.new()
	regex.compile("_[0-9]+$")
	return regex.sub(input, "")

func get_suffix_from_name(input:String) -> int:
	var underscore_index = input.find("_")
	if underscore_index == -1:
		return 0
	var parts = input.split("_")
	if parts.size() > 1:
		var suffix = parts[parts.size() - 1]
		return int(suffix)
	return 0

func check_probability(percent:float) -> bool:
	var probability = percent / 100.0
	var random_value = randf() 
	if random_value < probability:
		return true
	return false

func open_url(url:String) -> void:
	var target_url = ""
	if !url.begins_with("https://"):
		target_url = "https://" + url
	else:
		target_url = url
	OS.shell_open(target_url)
	debug("Redirection to a website: "+target_url)

func debug(content:String = "", type:String = "info") -> void:
	if content != "":
		var system_datetime = Time.get_datetime_dict_from_system()
		var datetime:String = "["+str(system_datetime["year"])+"-"+str(system_datetime["month"])+"-"+str(system_datetime["day"])+" "+str(system_datetime["hour"])+":"+str(system_datetime["minute"])+":"+str(system_datetime["second"])+"]"
		match type.to_lower():
			"info":
				print(str(datetime) + " INFO: " + str(content))
			"warning":
				print(str(datetime) + " WARNING: " + str(content))
			"error":
				print(str(datetime) + " ERROR: " + str(content))
			"fatal":
				print(str(datetime) + " FATAL ERROR: " + str(content))
				get_tree().quit()
			_:
				print(str(datetime) + " " + str(content))

# Game Settings
func config_new() -> void:
	var target_path = DirAccess.open(path.main)
	var target_file = FileAccess.open(file.config, FileAccess.READ)
	var config = {
		"graphic": {
			"v-sync": false,
			"fullscreen": true,
			"fps_limit": 1
		},
		"sounds": {
			"general": 100,
			"music": 50,
			"nature": 50,
			"radio": 75,
		},
	}
	if target_path:
		if !target_file:
			file_save([path.main], file.config, config)
	else:
		FileSystem.new().Funcs.create_directory(path.main)
		file_save([path.main], file.config, config)

func config_save() -> void:
	var target_path = DirAccess.open(path.main)
	if target_path:
		var config = {
			"graphic": {
				"v-sync": GameConfig.vsync,
				"fullscreen": GameConfig.fullscreen,
				"fps_limit": GameConfig.fps_limit
			},
			"sounds": {
				"general": GameConfig.general,
				"music": GameConfig.music,
				"nature": GameConfig.nature,
				"radio": GameConfig.radio,
			},
		}
		file_save([path.main], file.config, config)
	else:
		var config = {
			"graphic": {
				"v-sync": false,
				"fullscreen": true,
				"fps_limit": 1
			},
			"sounds": {
				"general": 100,
				"music": 50,
				"nature": 50,
				"radio": 75,
			},
		}
		FileSystem.new().Funcs.create_directory(path.main)
		file_save([path.main], file.config, config)

func config_load() -> void:
	if get_node("/root/"+main+"/UI/Interactive/Options"):
		get_node("/root/"+main+"/UI/Interactive/Options").set_values(file_load(file.config))
	if get_node("/root/"+main+"/Menu/Options"):
		get_node("/root/"+main+"/Menu/Options").set_values(file_load(file.config))

func start_newgame() -> void:

	nature.create_start_nature()
	config_new()
	config_load()
	mailbox.letter(
		# 	Header
		"Письмо новому фермеру",
		# 	Description
		"Приветствую тебя в нашем сообществе фермеров-садоводов!

		Меня зовут Корней Корнеич — мэр и по совместительству профессиональный садовод города Заречье. Хочу поздравить тебя с началом нового этапа жизни на нашей земле.

		В честь этого события я решил сделать тебе скромный подарок для первых шагов.

		Желаю успехов и богатого урожая! В ближайшее время напишу ещё.
		",	
		# 	Author
		"С уважением,\nКорней Корнеич",
		#	Money
		500,
		#	Items
		{
			13:{"amount":42},
		}
	)

	remove_game_files()

func remove_game_files() -> void:
	FileSystem.new().delete_folder("user://game/data")

func open_folder_in_explorer(folder_path:String):
	var command = ""
	var arguments = []
	var real_path = ProjectSettings.globalize_path(folder_path)
	var dir = DirAccess.open(folder_path)
	if !dir:
		FileSystem.new().Funcs.create_directory(folder_path)
		open_folder_in_explorer(folder_path)
	else:
		if OS.get_name() == "Windows":
			var windows_path = real_path.replace("/", "\\")
			print(windows_path)
			command = "explorer.exe"
			arguments = [windows_path]
		OS.execute(command, arguments)

# Greenhouse
func greenhouse_get_data(greenhouseNodeName:String) -> void:
	GameLoader.greenhouse_caption = greenhouseNodeName
	var target_path = DirAccess.open("user://game/data/farm/greenhouses")
	var target_file_read = FileAccess.open("user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json", FileAccess.READ)
	if target_path:
		if !target_file_read:
			if greenhouseNodeName != "":
				file_save(
					["user://game/data/farm/greenhouses"],
					"user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json",
					get_greenhouse_data()
				)
		else:
			var greenhouse_data = file_load("user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json")
			if greenhouse_data.has("farmlands"):
				if greenhouse_data['farmlands'] != []:
					create_terrains(
						collision.farmland_layer,
						get_vector_array(
							"user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json",
							"farmlands"
						),
						collision.terrain_set,
						collision.farming_terrain
					)
			if greenhouse_data.has("waterings"):
				if greenhouse_data['waterings'] != []:
					create_terrains(
						collision.watering_layer,
						get_vector_array(
							"user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json",
							"waterings"
						),
						collision.terrain_set,
						collision.watering_terrain
					)
			if greenhouse_data.has("plants_collisions"):
				if greenhouse_data['plants_collisions'] != []:
					create_cell(
						get_vector_array(
							"user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json",
							"plants_collisions"
						),
					)

			if greenhouse_data.has("plants"):
				if greenhouse_data['plants'] != {}:
					load_plant("user://game/data/farm/greenhouses/" + str(greenhouseNodeName) + ".json", "plants")
	else:
		FileSystem.new().Funcs.create_directory("user://game/data/farm/greenhouses")
		greenhouse_get_data(greenhouseNodeName)

func get_greenhouse_data() -> Dictionary:
	return {
		'plants': farming.get_all_plants(),
		'plants_collisions': collision.get_position_children(farming),
		'farmlands': collision.get_used_cells(collision.farmland_layer),
		'waterings': collision.get_used_cells(collision.watering_layer),
	}

func play_music(dictionary) -> void:
	if clock and dictionary.has(clock.get_season()):
		var season_sounds = dictionary[clock.get_season()]
		if season_sounds is Array and season_sounds.size() > 0:
			var index_audio = get_random_audio_index(season_sounds)
			if index_audio != -1:
				music.stop()
				music.stream = ResourceLoader.load(season_sounds[index_audio])
				music.play()

func get_random_audio_index(sounds_array):
	if sounds_array.size() == 0:
		return -1
	var new_index = randi() % sounds_array.size()
	if sounds_array.size() == 1:
		if is_valid_sound(sounds_array[0]):
			return 0
		else:
			return -1
	while true:
		new_index = randi() % sounds_array.size()
		if new_index != global_index_audio and is_valid_sound(sounds_array[new_index]):
			break
	global_index_audio = new_index
	return new_index

func is_valid_sound(sound_path) -> bool:
	if sound_path is String and sound_path.length() > 0:
		var file_exists = ResourceLoader.exists(sound_path, "AudioStream")
		return file_exists
	return false

func _on_timer_timeout() -> void:
	music_cooldown.stop()
	play_music(music_playlist)

func _on_music_stream_player_finished():
	if music_cooldown:
		var wait_time = randf_range(60.0,120.0)
		music_cooldown.set_wait_time(wait_time) 
		music_cooldown.start()
extends Node2D

# =============================================================================================
# (farming_manager.gd)
# =============================================================================================
# Центральный менеджер растениеводства
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# -
# -
# -
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# -
# -
# -
#
# ЗАВИСИМОСТИ:
# - TileMap (получение сетки и занятых клеток)
# -
# -
#
# =============================================================================================

@onready var scene: String = str(get_tree().root.get_child(3).name)
@onready var pause: Control = get_node("/root/" + scene + "/UI/Interactive/Pause")
@onready var gamedata: Node = get_node("/root/" + scene)
@onready var tilemap: TileMap = get_node("/root/" + scene + "/Tilemap")
@onready var clock: Control = get_node("/root/" + scene + "/UI/HUD/GameHud/Main/Bars/Clock")
@onready var collision: Node2D = get_node("/root/" + scene + "/ConstructionManager/Grid/GridParent")

# const PLANT:PackedScene 				= preload("res://assets/nodes/farming/plant.tscn")
# const FERTILIZER:PackedScene 			= preload("res://assets/nodes/farming/fertilizer.tscn")
# const DEAD_PLANT:CompressedTexture2D 	= preload('res://assets/resources/farming/crops.png')

# const ATLAS_COORDS = Vector2i(0,3)
# const COORDS_TILE_ID:int = 0
# const TILE_SIZE:int = 16
# const GROWTH_SPEED:int = 1

# const BEEHIVE_SPRING_MAX:int = 120
# const BEEHIVE_SUMMER_MAX:int = 30
# const BEEHIVE_AUTUMN_MAX:int = 90

# var items:Items = Items.new()
# var crops:Crops = Crops.new()

# var plants_map:Dictionary = {}
# var plant_timer:Timer

# var beehives_map:Dictionary = {}
# var beehive_timer:Timer

# func _ready() -> void:
# 	init_plant()
# 	init_beehive()

# 	GameLoader.farm_time_left = gamedata.file_load(gamedata.FILES.WORLD)['plants_map'] if gamedata.file_load(gamedata.FILES.WORLD).has('plants_map') else 0
# 	GameLoader.greenhouses = gamedata.file_load(gamedata.FILES.WORLD)['greenhouses'] if gamedata.file_load(gamedata.FILES.WORLD).has('greenhouses') else {}

# 	match scene:
# 		'Farm':
# 			if !GameLoader.greenhouses.is_empty()\
# 			&& !GameLoader.check_timer():
# 				GameLoader.create_outside_timer(scene)
# 		_:
# 			if !GameLoader.greenhouses.is_empty()\
# 			&& !GameLoader.farm.is_empty()\
# 			&& !GameLoader.check_timer():
# 				GameLoader.create_outside_timer(scene)

# func init_plant() -> void:
# 	plant_timer = Timer.new()
# 	plant_timer.set_autostart(true)
# 	plant_timer.wait_time = GROWTH_SPEED
# 	plant_timer.connect('timeout', Callable(self, '_growth_timeout').bind())
# 	add_child(plant_timer)

# func init_beehive() -> void:
# 	beehive_timer = Timer.new()
# 	beehive_timer.set_autostart(true)
# 	beehive_timer.wait_time = GROWTH_SPEED
# 	beehive_timer.connect('timeout', Callable(self, '_beehive_timeout').bind())
# 	add_child(beehive_timer)

# func plant_create(plant_id:int, mouse_position:Vector2i) -> void:
# 	var node = PLANT.instantiate()

# 	if collision.check_cell(mouse_position, collision.farmland_layer):
# 		var plant_position = tilemap.map_to_local(mouse_position)
# 		var plant_fertilize_percent = 0

# 		if collision.check_fertilizer(tilemap.local_to_map(plant_position)):
# 			plant_fertilize_percent = collision.get_fertilizer_percent(tilemap.local_to_map(plant_position))

# 		tilemap.set_cell(collision.crops_layer, mouse_position, COORDS_TILE_ID, ATLAS_COORDS)
# 		add_child(node)
# 		node.z_index = 2
# 		node.name = "plant_1"
# 		node.plant(
# 			plant_id, crops.crops[plant_id]['caption'],
# 			crops.crops[plant_id]['growth_rate'],
# 			crops.crops[plant_id]['growth_level'],
# 			crops.crops[plant_id]['mortality'],
# 			crops.crops[plant_id]['season'],
# 			crops.crops[plant_id]['X'],
# 			crops.crops[plant_id]['Y'],
# 			0, 0, 0, plant_position,
# 			plant_fertilize_percent)
# 		add_plant(node, plant_position)

# func load_plant(
# 	plant_node_name:String, plant_id:int, plant_caption:String, plant_growth_value:int,
# 	plant_growth_rate:float, plant_growth_level_max:int, plant_mortality:int, plant_seasons:Array,
# 	plant_rect_x:int, plant_rect_y:int, plant_condition:int, plant_growth_level:int,
# 	plant_degree:int, plant_position:Vector2i, plant_fertilize_percent:int,
# ) -> void:
# 	var node = PLANT.instantiate()

# 	tilemap.set_cell(collision.crops_layer, tilemap.local_to_map(plant_position), COORDS_TILE_ID, ATLAS_COORDS)
# 	add_child(node)
# 	node.z_index = 2
# 	node.name = plant_node_name
# 	node.plant(
# 		plant_id, plant_caption, plant_growth_rate, plant_growth_level_max,
# 		plant_mortality, plant_seasons, plant_rect_x, plant_rect_y,
# 		plant_condition,plant_growth_level,plant_degree,plant_position,
# 		plant_fertilize_percent, plant_growth_value)
# 	add_plant(node, plant_position)

# func add_plant(plant:Node2D, plant_position:Vector2i) -> void:
# 	if !plant:
# 		return

# 	plants_map[plant.name] = {}
# 	plants_map[plant.name]['node'] = plant
# 	plants_map[plant.name]['position'] = plant_position

# func add_beehive(_beehive:Node2D, _position:Vector2i) -> void:
# 	if !_beehive: return
# 	beehives_map[_beehive.name] = {}
# 	beehives_map[_beehive.name]['node'] = _beehive
# 	beehives_map[_beehive.name]['position'] = _position

# func change_beehive_state(beehive_name:String, new_value:int, honey:bool) -> void:
# 	if beehives_map.has(beehive_name):
# 		var new_beehive = beehives_map[beehive_name]
# 		new_beehive['node'].value = new_value
# 		new_beehive['node'].honeyReady = honey

# func remove_beehive(beehive_name:String) -> void:
# 	if beehives_map.has(beehive_name):
# 		beehives_map.erase(beehive_name)

# func plant_destroy(grid_position:Vector2i) -> void:
# 	var plant_for_delete = []
# 	var fertilize_for_delete = []
# 	var plant_data = {}

# 	if !plants_map.is_empty():
# 		for node in get_children():
# 			# Само растение
# 			if Utils.remove_suffix(node.name) == 'plant':
# 				plant_data = plants_map[node.name]
# 				if plant_data.has('position'):
# 					if grid_position == tilemap.local_to_map(plant_data['position']):
# 						plant_for_delete.append(node)
# 			# Удобрение по координатам растения
# 			if Utils.remove_suffix(node.name) == 'fertilizer':
# 				if grid_position == tilemap.local_to_map(node.global_position):
# 					fertilize_for_delete.append(node)

# 	if !plant_for_delete.is_empty():
# 		for node in plant_for_delete:
# 			remove_child(node)
# 			node.queue_free()
# 			plants_map.erase(node.name)

# 	if !fertilize_for_delete.is_empty():
# 		for node in fertilize_for_delete:
# 			remove_child(node)
# 			node.queue_free()

# # fertilizer
# func create_fertilizer(_fertilize_id:int, _fertilize_percent:int, _position:Vector2i) -> void:
# 	var fertilizer = FERTILIZER.instantiate()
# 	if items.content.has(_fertilize_id):
# 		add_child(fertilizer)
# 		fertilizer.name = "fertilizer_1"
# 		fertilizer.z_index = 2
# 		fertilizer.set_fertilizer(
# 			_fertilize_id,
# 			_fertilize_percent
# 		)
# 		fertilizer.set_position(
# 			tilemap.map_to_local(_position)
# 		)

# func _growth_timeout() -> void:
# 	if !pause.paused:
# 		if !plants_map.is_empty():
# 			for plant_id in plants_map.keys():
# 				var plant = plants_map[plant_id]
# 				var current_season = clock.get_season()
# 				# Если сезон сменится - растение погибает вне зависимости от состояния.
# 				if _plant_seasons(plant['node'], current_season):
# 					# Если в ячейке, где находится культура, есть вода - счетчик будет сброшен,
# 					# а растение продолжит свой рост с учетом удобрения
# 					if plant['node']._condition == plant['node'].PHASES.REQUIRES_WATERING\
# 					&& collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
# 						plant['node']._condition = plant['node'].PHASES.GROWING
# 						plant['node']._growth_value = plant['node']._growth_rate - (plant['node']._fertilize / 100.0) * plant['node']._growth_rate
# 						_update_watering_indicator(plant['node'], false)
# 						plant['node']._degree = 0

# 					# Если в ячейке, где находится культура, отсутствует вода - культура будет умирать
# 					if plant['node']._condition == plant['node'].PHASES.REQUIRES_WATERING\
# 					&& !collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
# 						plant['node']._degree = min(plant['node']._degree + GROWTH_SPEED, plant['node']._mortality)
# 						if !_check_watering_indicator(plant['node']):
# 							_update_watering_indicator(plant['node'], true)

# 						if plant['node']._degree == plant['node']._mortality:
# 							plant['node']._condition = plant['node'].PHASES.DEAD
# 							_update_watering_indicator(plant['node'], false)

# 					# Если игрок посадил в уже политую ячейку - сразу переключаем состояние узла на "растет"
# 					if plant['node']._condition == plant['node'].PHASES.PLANTED\
# 					&& collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
# 						plant['node']._degree = 0
# 						plant['node']._condition = plant['node'].PHASES.GROWING

# 					# Когда растение только посажено - идет проверка: есть ли вода на определенной ячейке или нет
# 					if plant['node']._condition == plant['node'].PHASES.PLANTED\
# 					&& !collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
# 						plant['node']._degree = min(plant['node']._degree + GROWTH_SPEED, plant['node']._mortality)
# 						if plant['node']._degree == plant['node']._mortality:
# 							plant['node']._condition = plant['node'].PHASES.DEAD
# 							_update_watering_indicator(plant['node'], false)

# 					# Процесс роста растения
# 					if plant['node']._condition == plant['node'].PHASES.GROWING\
# 					&& collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
# 						if plant['node']._growth_value != 0:
# 							plant['node']._growth_value = max(plant['node']._growth_value - GROWTH_SPEED, 0.0)
# 						else:
# 							# Если время роста ровна 0.0 - вызываем функцию у узла, чтобы он "подрос"
# 							plant['node'].growth()
# 							# Если текущий уровень роста равен или больше максимального уровня роста -
# 							# Прерываем проверку и меняем состояние растения на "вырос"
# 							if plant['node']._level >= plant['node']._growth_max:
# 								plant['node']._condition = plant['node'].PHASES.GROWED
# 								tilemap.set_cells_terrain_connect(
# 									collision.watering_layer,
# 									[tilemap.local_to_map(plant['position'])],
# 									0,
# 									-1
# 								)
# 							else:
# 								plant['node']._condition = plant['node'].PHASES.REQUIRES_WATERING
# 								_update_watering_indicator(plant['node'], true)
# 								tilemap.set_cells_terrain_connect(
# 									collision.watering_layer,
# 									[tilemap.local_to_map(plant['position'])],
# 									0,
# 									-1
# 								)
# 				else:
# 					plant['node'].sprite.texture = DEAD_PLANT
# 					plant['node'].dead()

# func _beehive_timeout() -> void:
# 	if !pause.paused:
# 		if !beehives_map.is_empty():
# 			for beehive_id in beehives_map.keys():
# 				var _current_season = clock.get_season()
# 				var _beehive = beehives_map[beehive_id]
# 				var BEEHIVE_VALUE_MAX:int = 0

# 				# Пчелы не активны зимой
# 				if _current_season != "winter":
# 					# В зависимости от сезона пчелы будут продуктивнее делать мед.
# 					if BEEHIVE_VALUE_MAX == 0:
# 						match _current_season:
# 							"spring": BEEHIVE_VALUE_MAX = BEEHIVE_SPRING_MAX
# 							"summer": BEEHIVE_VALUE_MAX = BEEHIVE_SUMMER_MAX
# 							"autumn": BEEHIVE_VALUE_MAX = BEEHIVE_AUTUMN_MAX

# 					if !_beehive['node'].honeyReady && min(_beehive['node'].value + GROWTH_SPEED, BEEHIVE_VALUE_MAX) < BEEHIVE_VALUE_MAX:
# 							_beehive['node'].value = min(_beehive['node'].value + GROWTH_SPEED, BEEHIVE_VALUE_MAX)
# 					else:
# 						if !_beehive['node'].honeyReady:
# 							_beehive['node'].honeyReady = true
# 							_beehive['node'].value = 0
# 							_beehive['node']._update_indicator()
# 				else:
# 					_beehive['node']._update_sound()

# func _plant_seasons(_node:Node2D, _season:String) -> bool:
# 	for _plant_season in _node._seasons:
# 		if scene != "Greenhouse":
# 			if _plant_season == _season:
# 				return true
# 		else: return true
# 	return false

# func _update_watering_indicator(_node:Node2D, _state:bool) -> void:
# 	if !_node: return

# 	if !_state:
# 		if _node.indicator.visible:
# 			_node.indicator.visible = !true
# 			if _node.anim.is_playing():
# 				_node.anim.stop()
# 	else:
# 		if !_node.indicator.visible:
# 			_node.indicator.visible = true
# 			if !_node.anim.is_playing():
# 				_node.anim.play('bubble')

# func _check_watering_indicator(_node:Node2D) -> bool:
# 	if !_node:
# 		return false
# 	if _node.indicator.visible:
# 		return true
# 	return false

# func get_all_plants() -> Dictionary:
# 	var data_dict = {}
# 	for plant in get_children():
# 		if plant.has_method("get_data"):
# 			var child_data = plant.get_data()
# 			data_dict[plant.name] = child_data
# 	return data_dict

# func _exit_tree() -> void:
# 	GameLoader.farm = plants_map
# 	if GameLoader.check_timer():
# 		GameLoader.remove_timer()

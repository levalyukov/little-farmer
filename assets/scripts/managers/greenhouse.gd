extends Node2D

# @onready var main: String = str(get_tree().root.get_child(2).name)
# @onready var data: Node2D = get_node("/root/" + main + "/")
# @onready var farming: Node2D = get_node("/root/" + main + "/FarmingManager")
# @onready var collision: Node2D = get_node("/root/" + main + "/ConstructionManager/Grid/GridParent")
# @onready var tilemap: TileMap = get_node("/root/" + main + "/Tilemap")

# var _greenhouse_name: String
# var _greenhouse_data: Dictionary


# func _ready():
# 	_set_name()
# 	_set_data()


# func _set_name() -> void:
# 	if GameLoader.current_greenhouse == "":
# 		return
# 	_greenhouse_name = GameLoader.current_greenhouse


# func _set_data() -> void:
# 	var _path = DirAccess.open("user://game/data/farm/greenhouses")
# 	var _path_file_read = FileAccess.open(
# 		"user://game/data/farm/greenhouses/" + str(_greenhouse_name) + ".json", FileAccess.READ
# 	)
# 	_greenhouse_data = data.file_load("user://game/data/farm/greenhouses/" + str(_greenhouse_name) + ".json")

# 	if !_path:
# 		Utils.create_directory("user://game/data/farm/greenhouses")
# 		_set_data()
# 		return

# 	if !_path_file_read:
# 		data.file_save(
# 			["user://game/data/farm/greenhouses"],
# 			"user://game/data/farm/greenhouses/" + str(_greenhouse_name) + ".json",
# 			{}
# 		)
# 		return
# 	_load_all_data()


# func _load_all_data() -> void:
# 	var _path = DirAccess.open("user://game/data/farm/greenhouses")
# 	var _path_file_read = FileAccess.open(
# 		"user://game/data/farm/greenhouses/" + str(_greenhouse_name) + ".json", FileAccess.READ
# 	)
# 	_greenhouse_data = data.file_load("user://game/data/farm/greenhouses/" + str(_greenhouse_name) + ".json")

# 	if !_path:
# 		Utils.create_directory("user://game/data/farm/greenhouses")
# 		_set_data()
# 		return

# 	if !_path_file_read:
# 		return

# 	_load_farmlands(_greenhouse_data["farmlands"])
# 	_load_waterings(_greenhouse_data["waterings"])
# 	_load_fertilizers(_greenhouse_data["fertilizers"])
# 	_load_plants(_greenhouse_data["plants"])


# # Загрузка данных
# func _load_farmlands(_vectors_data: Array) -> void:
# 	var _vectors = []
# 	for v in _vectors_data:
# 		_vectors.append(data.string_to_vector(v))

# 	if _vectors.size() > 0:
# 		for v in _vectors:
# 			tilemap.set_cells_terrain_connect(
# 				collision.farmland_layer, [v], collision.terrain_set, collision.farming_terrain
# 			)


# func _load_waterings(_vectors_data: Array) -> void:
# 	var _vectors = []
# 	for v in _vectors_data:
# 		_vectors.append(data.string_to_vector(v))

# 	if _vectors.size() > 0:
# 		for v in _vectors:
# 			tilemap.set_cells_terrain_connect(
# 				collision.watering_layer, [v], collision.terrain_set, collision.watering_terrain
# 			)


# func _load_fertilizers(_fertilizer_data: Dictionary) -> void:
# 	if _fertilizer_data.is_empty():
# 		return

# 	if farming:
# 		for fertilizer in _fertilizer_data:
# 			var _data = _fertilizer_data[fertilizer]

# 			var _id = _data["id"]
# 			var _percent = _data["percent"]
# 			var _position = data.string_to_vector(_data["position"])
# 			farming.create_fertilizer(_id, _percent, _position)


# func _load_plants(_plant_data: Dictionary) -> void:
# 	if _plant_data.is_empty():
# 		return

# 	if farming:
# 		for plant in _plant_data:
# 			var _data = _plant_data[plant]

# 			var _id = _data["plant_id"]
# 			var _caption = _data["caption"]
# 			var _growth_rate = _data["growth_rate"]
# 			var _level_max = _data["level_max"]
# 			var _mortality = _data["mortality"]
# 			var _seasons = _data["seasons"]
# 			var _rect_x = _data["rect_x"]
# 			var _rect_y = _data["rect_y"]
# 			var _condition = _data["condition"]
# 			var _level = _data["level"]
# 			var _degree = _data["degree"]
# 			var _position = data.string_to_vector(_data["position"])
# 			var _fertilizer_percent = _data["fertilizer_percent"]
# 			var _growth_value = _data["growth_value"]

# 			var _greenhouse_value = (
# 				GameLoader.greenhouses[_greenhouse_name]["time_left"]
# 				if (
# 					GameLoader.greenhouses.has(_greenhouse_name)
# 					&& GameLoader.greenhouses[_greenhouse_name].has("time_left")
# 				)
# 				else 0
# 			)
# 			farming.load_plant(
# 				plant,
# 				_id,
# 				_caption,
# 				max(_growth_value - _greenhouse_value, 1),
# 				_growth_rate,
# 				_level_max,
# 				_mortality,
# 				_seasons,
# 				_rect_x,
# 				_rect_y,
# 				_condition,
# 				_level,
# 				_degree,
# 				_position,
# 				_fertilizer_percent
# 			)

# 	GameLoader.greenhouses[_greenhouse_name]["time_left"] = 0


# # Сохранение данных теплицы
# func _save_all_data() -> void:
# 	var _path = DirAccess.open("user://game/data/farm/greenhouses")
# 	if !_path:
# 		Utils.create_directory("user://game/data/farm/greenhouses")
# 		_save_all_data()
# 		return

# 	(
# 		data
# 		. file_save(
# 			["user://game/data/farm/greenhouses"],
# 			"user://game/data/farm/greenhouses/" + str(_greenhouse_name) + ".json",
# 			{
# 				"plants": _save_plants(),
# 				"fertilizers": _save_fertilizers(),
# 				"farmlands": _save_farmlands(),
# 				"waterings": _save_waterings(),
# 			}
# 		)
# 	)


# func _save_plants() -> Dictionary:
# 	var _plants = {}
# 	if farming.get_children().size() > 0:
# 		for plant in farming.get_children():
# 			if data.remove_suffix(plant.name) == "plant":
# 				if plant.has_method("get_data"):
# 					var child_data = plant.get_data()
# 					_plants[plant.name] = child_data
# 	return _plants


# func _save_fertilizers() -> Dictionary:
# 	var _fertilizers = {}
# 	if farming.get_children().size() > 0:
# 		for plant in farming.get_children():
# 			if data.remove_suffix(plant.name) == "fertilizer":
# 				if plant.has_method("get_data"):
# 					var child_data = plant.get_data()
# 					_fertilizers[plant.name] = child_data
# 	return _fertilizers


# func _save_farmlands() -> Array:
# 	var _farmlands = []
# 	_farmlands = collision.get_used_cells(collision.farmland_layer)
# 	return _farmlands


# func _save_waterings() -> Array:
# 	var _waterings = []
# 	_waterings = collision.get_used_cells(collision.watering_layer)
# 	return _waterings


# func _exit_tree():
# 	_save_all_data()

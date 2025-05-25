extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var plant_node:PackedScene = load("res://assets/nodes/farming/plant.tscn")
@onready var fertilizer_node:PackedScene = load("res://assets/nodes/farming/fertilizer.tscn")

const ATLAS_COORDS = Vector2i(0,3)
const COORDS_TILE_ID:int = 0
const TILE_SIZE:int = 16
const GROWTH_SPEED:int = 1

var items:Object = Items.new()
var crops:Object = Crops.new()
var plants_map:Dictionary = {}

func _ready():
	var plant_timer = Timer.new()
	plant_timer.set_autostart(true)
	plant_timer.set_wait_time(GROWTH_SPEED)
	plant_timer.connect('timeout', Callable(self, '_growth_timeout').bind())
	self.add_child(plant_timer)

func create_plant(plant_id:int, mouse_position:Vector2i) -> Node2D:
	var node = plant_node.instantiate()

	if collision.check_cell(mouse_position, collision.farmland_layer):
		var plant_caption = crops.crops[plant_id]['caption'] if crops.crops[plant_id].has('caption') && crops.crops[plant_id]['caption'] is String else null
		var plant_growth_rate = crops.crops[plant_id]['growth_rate'] if crops.crops[plant_id].has('growth_rate') && crops.crops[plant_id]['growth_rate'] is float else null
		var plant_growth_level_max = crops.crops[plant_id]['growth_level'] if crops.crops[plant_id].has('growth_level') && crops.crops[plant_id]['growth_level'] is int else null
		var plant_mortality = crops.crops[plant_id]['mortality'] if crops.crops[plant_id].has('mortality') && crops.crops[plant_id]['mortality'] is int else null
		var plant_seasons = crops.crops[plant_id]['season'] if crops.crops[plant_id].has('season') && crops.crops[plant_id]['season'] is Array else null
		var plant_rect_y = crops.crops[plant_id]['Y'] if crops.crops[plant_id].has('Y') && crops.crops[plant_id]['Y'] is int else null
		var plant_position = tilemap.map_to_local(mouse_position)

		tilemap.set_cell(collision.crops_layer, mouse_position, COORDS_TILE_ID, ATLAS_COORDS)
		add_child(node)
		node.z_index = 2
		node.name = "plant_1"
		node.plant(
			plant_id,
			plant_caption,
			plant_growth_rate,
			plant_growth_level_max,
			plant_mortality,
			plant_seasons,
			plant_rect_y,
			0,	# Фаза 'Посажено'
			0,	# Уровень роста
			0,	# Уровень смерти
			plant_position
		)
		add_plant(node, plant_growth_rate, plant_position, plant_mortality)
	return node

func add_plant(_plant:Node2D, _growth_rate:float, _position:Vector2i, _mortality) -> void:
	if !_plant: return
	
	plants_map[_plant.name] = {}
	plants_map[_plant.name]['node'] = _plant
	plants_map[_plant.name]['growth_rate'] = _growth_rate
	plants_map[_plant.name]['position'] = _position
	plants_map[_plant.name]['mortality'] = _mortality

func plant_destroy(vector:Vector2i) -> void:
	for child in get_children():
		if vector == tilemap.local_to_map(child.position):
			if data.remove_suffix(child.name) == "plant"\
			|| data.remove_suffix(child.name) == "fertilizer":
				remove_child(child)
				child.queue_free()
				if plants_map.has(child.name):
					plants_map.erase(child.name)

func check_season(id:int) -> bool:
	var crop_season = crops.crops[id]["season"]
	for i in crop_season:
		if i == clock.get_season():
			return true
	return false

func get_all_plants() -> Dictionary:
	var data_dict = {}
	for plant in get_children():
		if plant.has_method("get_data"):
			var child_data = plant.get_data()
			data_dict[plant.name] = child_data
	return data_dict

# fertilizer
func create_fertilizer(id:int, vector:Vector2i) -> void:
	if items.content.has(id):
		if items.content[id].has('item_type'):
			if items.content[id]['item_type'] == 'fertilizer':
				var fertilizer = fertilizer_node.instantiate()
				add_child(fertilizer)
				fertilizer.name = "fertilizer_1"
				fertilizer.z_index = 2
				fertilizer.set_fertilizer(id)
				fertilizer.set_position(tilemap.map_to_local(vector))
				
func _growth_timeout() -> void:
	if !plants_map.is_empty():
		for plant_id in plants_map.keys():
			var plant = plants_map[plant_id]
			# TODO:
			# - Переработать систему удобрений
			# - Сохранение и загрузка растений на ферме
			# - Сохранение и загрузка растений в теплице

			# ПОЯСНЕНИЕ:
			# Рост растения. Идет проверка, время роста больше нуля или нет.
			# Если больше нуля - идет проверка: есть ли на клетке вода или нет:
			# Нет - растение умирает. Да - растем.
			# ---
			# Если все-таки время равно нулю - новый уровень растения. 
			# growth() <- там есть доп. манипуляции с словарем "plants_map"*, в которой я не уверен, но оно работает
			# * - лучше переписать в будущем, кто его знает.
			if plant['node']._condition == plant['node'].PHASES.GROWED\
			|| plant['node']._condition == plant['node'].PHASES.DEAD:
				plants_map.erase(plant_id)
				return

			if abs(plant['growth_rate'] - GROWTH_SPEED) > 0.0:
				if collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
					if plant['node']._degree > 0: plant['node']._degree = 0
					plant['growth_rate'] = max(plant['growth_rate'] - GROWTH_SPEED, 0.0)
					if plant['node']._condition == plant['node'].PHASES.REQUIRES_WATERING:
						_update_watering_indicator(plant['node'], false)
					plant['node']._condition = plant['node'].PHASES.GROWING
				else:
					plant['node']._degree = min(plant['node']._degree + 1, plant['mortality'])
					if plant['node']._condition != plant['node'].PHASES.PLANTED\
					&& plant['node']._condition != plant['node'].PHASES.REQUIRES_WATERING: 
						plant['node']._condition = plant['node'].PHASES.REQUIRES_WATERING
						_update_watering_indicator(plant['node'], true)
					if plant['node']._degree == plant['mortality']:
						plant['node']._condition = plant['node'].PHASES.DEAD
			else:
				if !plant['node']._condition == plant['node'].PHASES.REQUIRES_WATERING\
				&& collision.check_cell(tilemap.local_to_map(plant['position']), collision.watering_layer):
					plant['node'].growth()
					plant['growth_rate'] = plant['node']._growth_rate
	return

func _update_watering_indicator(_node:Node2D, _state:bool) -> void:
	if !_node: return

	if !_state:
		if _node.indicator.visible:
			_node.indicator.visible = !true
			if _node.anim.is_playing():
				_node.anim.stop()
	else:
		if !_node.indicator.visible:
			_node.indicator.visible = true
			if !_node.anim.is_playing(): 
				_node.anim.play('bubble')
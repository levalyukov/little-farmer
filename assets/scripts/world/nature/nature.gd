extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")

var tree_node = preload("res://assets/nodes/world/tree.tscn")
var stone_node = preload("res://assets/nodes/world/stone.tscn")
var weed_node = preload("res://assets/nodes/world/weed.tscn")

const _tree_func_calls:int = 150 * 5
const _stone_func_calls:int = 100 * 5
const _weed_func_calls:int = 275 * 3

const _big_stone_func_calls:int = 1

var _all_vectors:Array[Vector2i] = []
var _occuped_cells_removed:bool = false

var _trees:Array[CompressedTexture2D] = []
var _stones:Array[CompressedTexture2D] = []
var _weeds:Array[CompressedTexture2D] = []
var _trees_shadow:Array[CompressedTexture2D] = []
var _stones_shadow:Array[CompressedTexture2D] = []
var _weeds_shadow:Array[CompressedTexture2D] = []

const _tree_sprite_max:int = 6
const _stone_sprite_max:int = 8
const _weed_sprite_max:int = 8

var _tree_func_called:int = 0
var _stone_func_called:int = 0
var _weed_func_called:int = 0

var _tree_sprite_value:int = 0
var _stone_sprite_value:int = 0
var _weed_sprite_value:int = 0

func _ready():
	self.z_index = 2
	if main == "Farm":
		if !GameLoader.mode:
			_set_new_sprites()
			tilemap.set_atlas(clock.get_season())

func _set_new_sprites() -> void:
	while _trees.size() < _tree_sprite_max:
		_tree_sprite_value += 1
		_trees.append(load("res://assets/resources/world/trees/"+ str(clock.get_season()) + "/tree_"+str(_tree_sprite_value)+".png"))
		_trees_shadow.append(load("res://assets/resources/world/trees/shadow_"+str(_tree_sprite_value)+".png"))

	while _stones.size() < _stone_sprite_max:
		_stone_sprite_value += 1
		_stones.append(load("res://assets/resources/world/stones/stone_"+str(_stone_sprite_value)+".png"))
		_stones_shadow.append(load("res://assets/resources/world/stones/shadows/shadow_"+str(_stone_sprite_value)+".png"))

	while _weeds.size() < _weed_sprite_max:
		_weed_sprite_value += 1
		_weeds.append(load("res://assets/resources/world/weeds/"+ str(clock.get_season()) + "/weed_"+str(_weed_sprite_value)+".png"))
		_weeds_shadow.append(load("res://assets/resources/world/weeds/"+ str(clock.get_season()) + "/shadow_"+str(_weed_sprite_value)+".png"))

func clear_all_arrays() -> void:
	_trees.clear()
	_trees_shadow.clear()
	_stones.clear()
	_stones_shadow.clear()
	_weeds.clear()
	_weeds_shadow.clear()
	_tree_sprite_value = 0
	_stone_sprite_value = 0
	_weed_sprite_value = 0

func create_new_nature():
	_all_vectors = tilemap.get_used_cells(0)
	check_aviabled_vectors()
	while _weed_func_called < _weed_func_calls:
		_weed_func_called+=1
		_create_nature(weed_node, "weed", _weeds, _weeds_shadow)

	check_aviabled_vectors()
	while _stone_func_called < _stone_func_calls:
		_stone_func_called+=1
		_create_nature(stone_node, "stone", _stones, _stones_shadow)

	check_aviabled_vectors()
	while _tree_func_called < _tree_func_calls:
		_tree_func_called+=1
		_create_nature(tree_node, "tree", _trees, _trees_shadow)

func _create_nature(node:PackedScene, node_name:String, sprites_array:Array[CompressedTexture2D], shadows_array:Array[CompressedTexture2D]) -> void:
	var target_node = node.instantiate()
	var target_position = set_random_position()
	
	if node == null: return
	if target_position == null: return
	if tilemap == null: return
	
	if !collision.check_cell(target_position, collision.road_layer)\
	&& !collision.check_cell(target_position, collision.nature_layer)\
	&& !collision.check_cell(target_position, collision.coast_layer)\
	&& !collision.check_cell(target_position, collision.water_layer)\
	&& !collision.check_cell(target_position, collision.building_layer)\
	&& !collision.check_cell(target_position, collision.collision_scene):
		add_child(target_node)
		target_node.name = node_name + "_1"

		var random_sprite = randi() % sprites_array.size()

		target_node.set_texture(sprites_array[random_sprite], random_sprite)
		target_node.set_position(tilemap.map_to_local(target_position))
		tilemap.set_cell(collision.nature_layer, target_position, 0, Vector2i(0,3))

		if shadows:
			if shadows_array != []:
				shadows.create_shadow_nature(str(node_name) + "_shadow", shadows_array[random_sprite], target_position, random_sprite, node_name)

func load_nature(
	node:PackedScene, 
	node_name:String, 
	sprite:CompressedTexture2D, 
	index:int, 
	target_position:Vector2i, 
	health:int, 
	shadow:CompressedTexture2D = null,
	) -> void:
	var target_node = node.instantiate()
	if node == null: return
	if target_position == null: return
	if tilemap == null: return
	
	if !collision.check_cell(target_position, collision.road_layer)\
	&& !collision.check_cell(target_position, collision.nature_layer)\
	&& !collision.check_cell(target_position, collision.building_layer):
		add_child(target_node)
		target_node.name = node_name

		target_node.set_texture(sprite, index)
		target_node.set_position(tilemap.map_to_local(target_position))
		tilemap.set_cell(collision.nature_layer, target_position, 0, Vector2i(0, 3))
		target_node.health = health
		if shadows:
			if shadow != null:
				shadows.create_shadow_nature(
					str(node_name) + "_shadow", 
					shadow, 
					target_position, 
					index, 
					data.remove_suffix(node_name)
				)

func set_random_position() -> Vector2i:
	if _all_vectors.size() == 0: return Vector2i()
	var random_index = randi() % _all_vectors.size()
	var target_position = _all_vectors[random_index]
	_all_vectors.remove_at(random_index) 
	return target_position

func check_aviabled_vectors():
	if tilemap:
		_occuped_cells_removed = false
		var all_occuped_cells:Array[Vector2i] = tilemap.get_used_cells(collision.road_layer)
		all_occuped_cells += tilemap.get_used_cells(collision.nature_layer)
		if all_occuped_cells.size() > 0:
			for cell in all_occuped_cells:
				if _all_vectors.has(cell):
					_all_vectors.erase(cell)
					_occuped_cells_removed = true

func get_all_nature() -> Dictionary:
	var data_dict = {}
	for nature in get_children():
		if nature.has_method("get_data"):
			var child_data = nature.get_data()
			data_dict[nature.name] = child_data
	return data_dict

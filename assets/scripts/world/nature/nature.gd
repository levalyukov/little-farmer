extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tree_node = preload("res://assets/nodes/world/tree.tscn")
@onready var stone_node = preload("res://assets/nodes/world/stone.tscn")
@onready var weed_node = preload("res://assets/nodes/world/weed.tscn")

const tree_func_calls:int = 150
const stone_func_calls:int = 100
const weed_func_calls:int = 275

var all_vectors:Array[Vector2i] = []
var occuped_cells:Array[Vector2i] = []
var occuped_cells_removed:bool = false

var trees:Array[CompressedTexture2D] = []
var stones:Array[CompressedTexture2D] = []
var weeds:Array[CompressedTexture2D] = []
var trees_shadow:Array[CompressedTexture2D] = []
var stones_shadow:Array[CompressedTexture2D] = []
var weeds_shadow:Array[CompressedTexture2D] = []

const tree_sprite_max:int = 6
const stone_sprite_max:int = 8
const weed_sprite_max:int = 8

const tree_sprite_min:int = 1 
const stone_sprite_min:int = 1 
const weed_sprite_min:int = 1 

var tree_func_called:int = 0
var stone_func_called:int = 0
var weed_func_called:int = 0

var tree_sprite_value:int = 0
var stone_sprite_value:int = 0
var weed_sprite_value:int = 0

func _ready():
	self.z_index = 2
	new_texture()

func new_texture() -> void:
	while trees.size() < tree_sprite_max:
		tree_sprite_value += 1
		trees.append(load("res://assets/resources/world/trees/"+ str(clock.get_season()) + "/tree_"+str(tree_sprite_value)+".png"))
		trees_shadow.append(load("res://assets/resources/world/trees/shadow_"+str(tree_sprite_value)+".png"))

	while stones.size() < stone_sprite_max:
		stone_sprite_value += 1
		stones.append(load("res://assets/resources/world/stones/stone_"+str(stone_sprite_value)+".png"))
		stones_shadow.append(load("res://assets/resources/world/stones/shadows/shadow_"+str(stone_sprite_value)+".png"))

	while weeds.size() < weed_sprite_max:
		weed_sprite_value += 1
		weeds.append(load("res://assets/resources/world/weeds/"+ str(clock.get_season()) + "/weed_"+str(weed_sprite_value)+".png"))
		weeds_shadow.append(load("res://assets/resources/world/weeds/"+ str(clock.get_season()) + "/shadow_"+str(weed_sprite_value)+".png"))

func clear_all_arrays() -> void:
	trees.clear()
	trees_shadow.clear()
	stones.clear()
	stones_shadow.clear()
	weeds.clear()
	weeds_shadow.clear()
	tree_sprite_value = 0
	stone_sprite_value = 0
	weed_sprite_value = 0

func create_start_nature():
	all_vectors = tilemap.get_used_cells(0)
	check_aviabled_vectors()
	print(weeds)
	print(stones)
	print(trees)
	while weed_func_called < weed_func_calls:
		weed_func_called+=1
		create_natural_obj(weed_node, "weed", weeds, weed_sprite_max, weeds_shadow)

	check_aviabled_vectors()
	while stone_func_called < stone_func_calls:
		stone_func_called+=1
		create_natural_obj(stone_node, "stone", stones, stone_sprite_max, stones_shadow)

	check_aviabled_vectors()
	while tree_func_called < tree_func_calls:
		tree_func_called+=1
		create_natural_obj(tree_node, "tree", trees, tree_sprite_max, trees_shadow)

func create_natural_obj(node:PackedScene, node_name:String, sprites_array:Array[CompressedTexture2D], sprite_max:int, shadows_array:Array[CompressedTexture2D]) -> void:
	var random = randi_range(1, sprite_max)
	var target_node = node.instantiate()
	var target_position = set_random_position()
	
	if node == null:
		data.debug("Node instantiation failed.", "error")
		return
	if target_position == null:
		data.debug("Target position is invalid.", "error")
		return
	if tilemap == null:
		data.debug("Tilemap is null.", "error")
		return
	
	if !collision.check_cell(target_position, collision.road_layer)\
	&& !collision.check_cell(target_position, collision.nature_layer)\
	&& !collision.check_cell(target_position, collision.coast_layer)\
	&& !collision.check_cell(target_position, collision.water_layer)\
	&& !collision.check_cell(target_position, collision.building_layer)\
	&& !collision.check_cell(target_position, collision.collision_scene):
		add_child(target_node)
		target_node.name = node_name + "_1"
		if not target_node.is_inside_tree():
			data.debug("Node not added to the tree.", "error")
			return
		var random_sprite = randi() % sprites_array.size()
		target_node.set_texture(sprites_array[random_sprite], random_sprite)
		target_node.set_position(tilemap.map_to_local(target_position))
		tilemap.set_cell(collision.nature_layer, target_position, 0, Vector2i(0, 3))
		if shadows:
			if shadows_array != []:
				shadows.create_shadow(str(node_name) + "_shadow_" + str(random), shadows_array[random_sprite], target_position)
		else:
			data.debug("Shadows manager is null.", "error")
			return

func load_natural_obj(
	node:PackedScene, 
	node_name:String, 
	sprite:CompressedTexture2D, 
	index:int, 
	target_position:Vector2i, 
	health:int, 
	shadow:CompressedTexture2D = null,
	) -> void:
	var target_node = node.instantiate()
	if node == null:
		data.debug("Node instantiation failed.", "error")
		return
	if target_position == null:
		data.debug("Target position is invalid.", "error")
		return
	if tilemap == null:
		data.debug("Tilemap is null.", "error")
		return
	
	if !collision.check_cell(target_position, collision.road_layer)\
	&& !collision.check_cell(target_position, collision.nature_layer)\
	&& !collision.check_cell(target_position, collision.building_layer):
		add_child(target_node)
		target_node.name = node_name
		if not target_node.is_inside_tree():
			data.debug("Node not added to the tree.", "error")
			return
		target_node.set_texture(sprite, index)
		target_node.set_position(tilemap.map_to_local(target_position))
		tilemap.set_cell(collision.nature_layer, target_position, 0, Vector2i(0, 3))
		target_node.health = health
		if shadows:
			if shadow != null:
				shadows.create_shadow(str(node_name) + "_shadow_" + str(index), shadow, target_position)
		else:
			data.debug("Shadows manager is null.", "error")
			return

func set_random_position() -> Vector2i:
	if all_vectors.size() == 0:
		return Vector2i()
	var random_index = randi() % all_vectors.size()
	var target_position = all_vectors[random_index]
	all_vectors.remove_at(random_index) 
	return target_position

func check_aviabled_vectors():
	if tilemap:
		occuped_cells_removed = false
		var all_occuped_cells:Array[Vector2i] = tilemap.get_used_cells(collision.road_layer)
		all_occuped_cells += tilemap.get_used_cells(collision.nature_layer)
		if all_occuped_cells.size() > 0:
			for cell in all_occuped_cells:
				if all_vectors.has(cell):
					all_vectors.erase(cell)
					occuped_cells_removed = true
	else:
		data.debug("TileMap was not loaded at the time.", "error")
		return

func get_all_nature() -> Dictionary:
	var data_dict = {}
	for nature in get_children():
		if nature.has_method("get_data"):
			var child_data = nature.get_data()
			data_dict[nature.name] = child_data
	return data_dict

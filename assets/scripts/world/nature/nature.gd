extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tree_node = preload("res://assets/nodes/world/tree.tscn")

const func_calls:int = 75
var func_called:int = 0

const tree_sprite_max:int = 6
const tree_sprite_min:int = 1 
var trees:Array[CompressedTexture2D] = []
var trees_shadow:Array[CompressedTexture2D] = []
var tree_sprite_value:int = 0
var all_vectors:Array[Vector2i] = []
var occuped_cells:Array[Vector2i] = []
var occuped_cells_removed:bool = false

func _ready():
	self.z_index = 3
	all_vectors = tilemap.get_used_cells(0)
	get_aviabled_vectors()
	while trees.size() < tree_sprite_max:
		tree_sprite_value += 1
		trees.append(load("res://assets/resources/world/trees/tree_"+str(tree_sprite_value)+".png"))
		trees_shadow.append(load("res://assets/resources/world/trees/shadows/shadow_"+str(tree_sprite_value)+".png"))
	await get_tree().create_timer(0.15).timeout
	while func_called < func_calls:
		func_called+=1
		create_tree()

func create_tree() -> void:
	var random = randi_range(tree_sprite_min, tree_sprite_max)
	var node = tree_node.instantiate()
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

	add_child(node)
	node.name = "tree_1"
	if not node.is_inside_tree():
		data.debug("Node not added to the tree.", "error")
		return
	
	if !collision.check_cell(target_position, collision.road_layer)\
	&& !collision.check_cell(target_position, collision.nature_layer)\
	&& !collision.check_cell(target_position, collision.building_layer):
		var random_sprite = randi() % trees.size()
		node.set_texture(trees[random_sprite])
		node.set_position(tilemap.map_to_local(target_position))
		tilemap.set_cell(collision.nature_layer, target_position, 0, Vector2i(0, 3))
		if shadows:
			shadows.create_shadow("tree_shadow_" + str(random), trees_shadow[random_sprite], target_position)
		else:
			data.debug("Shadows manager is null.", "error")
			return
	else:
		create_tree()

func set_random_position() -> Vector2i:
	if all_vectors.size() == 0:
		return Vector2i()
	var random_index = randi() % all_vectors.size()
	var target_position = all_vectors[random_index]
	all_vectors.remove_at(random_index) 
	return target_position

func get_aviabled_vectors():
	if tilemap:
		if not occuped_cells_removed:
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

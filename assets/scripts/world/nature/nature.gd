extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tree_node = preload("res://assets/nodes/world/tree.tscn")

var trees:Array[CompressedTexture2D] = []
var trees_shadow:Array[CompressedTexture2D] = []
const tree_sprite_max:int = 2
const tree_sprite_min:int = 0 
var tree_sprite_value:int = 0
var all_vectors:Array[Vector2i] = []
var occuped_cells:Array[Vector2i] = []
var occuped_cells_removed:bool = false

func _ready():
	self.z_index = 4
	all_vectors = tilemap.get_used_cells(0)
	while trees.size() < tree_sprite_max-1:
		tree_sprite_value += 1
		trees.append(load("res://assets/resources/world/trees/tree_"+str(tree_sprite_value)+".png"))
		trees_shadow.append(load("res://assets/resources/world/trees/shadows/shadow_"+str(tree_sprite_value)+".png"))

func _input(_event):
	if Input.is_action_pressed('test'):
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
	if not node.is_inside_tree():
		data.debug("Node not added to the tree.", "error")
		return
    
	node.set_position(tilemap.map_to_local(target_position))
	tilemap.set_cell(4, target_position, 0, Vector2i(0, 3))
    
	if shadows:
		shadows.create_shadow("tree_shadow_" + str(random), trees_shadow[0], target_position)
	else:
		data.debug("Shadows manager is null.", "error")
		return

func set_random_position() -> Vector2i:
	var random_vector = randi() % all_vectors.size()
	var target_position = all_vectors[random_vector]
	all_vectors.erase(random_vector)
	return target_position

func get_aviabled_vectors():
	if tilemap:
		if not occuped_cells_removed:
			var all_occuped_cells: Array = tilemap.get_used_cells(1)
			for cell in all_occuped_cells:
				occuped_cells.append(cell)

			if occuped_cells.size() > 0:
				for cell in occuped_cells:
					all_vectors.erase(cell)
				occuped_cells.clear()
				occuped_cells_removed = true
	else:
		data.debug("", "error")
		return

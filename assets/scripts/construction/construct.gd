extends Node2D

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
const max_distance:int = 250

var all_buildings:Dictionary = {
	"sign": load("res://assets/nodes/buildings/sign.tscn"),
}

func get_buildings() -> Dictionary:
	var data_dict = {}
	for building in buildings.get_children():
		if building.has_method("get_data"):
			data_dict[building.name] = building.get_data()
	return data_dict

func construct(node_name:String, node_scene:PackedScene, node_shadow, node_position:Vector2i) -> void:
	if node_scene != null:
		var building = node_scene.instantiate()
		var building_name = node_name + "_1"

		add_child(building)
		building.set_position(tilemap.map_to_local(node_position))
		building.name = building_name
		if node_shadow is PackedScene:
			shadows.create_shadow_node(building_name, node_shadow, node_position)
		if node_shadow is CompressedTexture2D:
			shadows.create_shadow(building_name, node_shadow, node_position)

		for i in collision.get_children():
			var grid_position = tilemap.local_to_map(i.get_global_position())
			tilemap.set_cell(collision.building_layer, grid_position, 0, Vector2i(0,3))
			#tilemap.set_cell(collision.ground_layer, grid_position, 0, Vector2i(1,1))

func construct_load(node_name:String, node_scene:PackedScene, node_position:Vector2i, collisions:Array[Vector2i]) -> void:
	var building = node_scene.instantiate()
	add_child(building)
	building.set_position(tilemap.map_to_local(node_position))
	building.name = node_name
	building._shadow_create()
	for i in collisions:
		var target_position = tilemap.local_to_map(i)
		tilemap.set_cell(collision.building_layer, target_position, 0, Vector2i(0,3))

func construct_load_sprites(name_node:String, sprite_id:int) -> void:
	for build in buildings.get_children():
		if build.name == name_node:
			build.set_sign_sprite(sprite_id)
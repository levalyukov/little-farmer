extends Node2D

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridCollision")
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

func construct(node_name:String, node_scene:PackedScene, node_shadow:CompressedTexture2D, node_position:Vector2i) -> void:
	var building = node_scene.instantiate()
	var building_name = node_name + "_1"

	add_child(building)
	tilemap.set_cell(collision.building_layer-1, node_position, 0, Vector2i(0,3))
	building.set_position(tilemap.map_to_local(node_position))
	building.name = building_name
	shadows.create_shadow(building_name, node_shadow, node_position)

func construct_load(node_name:String, node_scene:PackedScene, node_position:Vector2i) -> void:
	var building = node_scene.instantiate()

	add_child(building)
	tilemap.set_cell(collision.building_layer-1, node_position, 0, Vector2i(0,3))
	building.set_position(tilemap.map_to_local(node_position))
	building.name = node_name
	building._shadow_create()

func construct_load_sprites(name_node:String, sprite_id:int) -> void:
	for build in buildings.get_children():
		if build.name == name_node:
			build.set_sign_sprite(sprite_id)
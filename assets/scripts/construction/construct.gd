extends Node2D

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var shadows:Node = get_node("/root/"+main+"/ShadowManager")
@onready var shadows_node:Node = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
const max_distance:int = 250

func get_buildings() -> Dictionary:
	var data_dict = {}
	for building in buildings.get_children():
		if building.has_method("get_data"):
			data_dict[building.name] = building.get_data()
	return data_dict

func create_node(id:int, vector:Vector2i, node_name:String = "") -> void:
	var blueprints = Blueprints.new()
	if blueprints.content.has("nodes"):
		if blueprints.content["nodes"].has(id):
			if blueprints.content["nodes"][id].has("config"):
				if blueprints.content["nodes"][id]["config"].has("name"):
					if blueprints.content["nodes"][id]["config"].has("node"):
						if blueprints.content["nodes"][id]["config"].has("area"):
							var node = blueprints.content["nodes"][id]["config"]["node"].instantiate()
							add_child(node)
							node.set_position(tilemap.map_to_local(vector))
							
							if node_name != "":
								node.name = node_name
							else:
								if blueprints.content["nodes"][id]["config"].has("name"):
									node.name = blueprints.content["nodes"][id]["config"]["name"] + "_1"
								else:
									node.name = "node" + "_1"

							node.blueprint_id = id
							if blueprints.content["nodes"][id]["config"].has("shadow"):
								if blueprints.content["nodes"][id]["config"]["shadow"] is PackedScene:
									shadows.create_shadow_node(
										node_name,
										blueprints.content["nodes"][id]["config"]["shadow"],
										vector
									)

							if collision.get_children().size() > 0:
								var all_collisions:Array[Vector2i] = []
								for i in collision.get_children():
									tilemap.set_cell(
										collision.building_layer, 
										tilemap.local_to_map(
											i.get_global_position()
										), 
										0, 
										Vector2i(0,3)
									)
									all_collisions.append(tilemap.local_to_map(i.get_global_position()))
								node.all_collisions = all_collisions
							else:
								for x in range(blueprints.content["nodes"][id]["config"]["area"].x):
									for y in range(blueprints.content["nodes"][id]["config"]["area"].y):
										tilemap.set_cell(
											collision.building_layer, 
											tilemap.local_to_map(
												Vector2i(
													(vector.x + x) * grid.SIZE.x, 
													(vector.y + y) * grid.SIZE.y
												)
											),
											0, 
											Vector2i(0,3)
										)

func remove_node(node:Node2D, vectors:Array[Vector2i]) -> void:
	for nodes in self.get_children():
		if nodes == node:
			for i in vectors:
				if i == tilemap.local_to_map(nodes.position):
					remove_child(node)

	for i in shadows_node.get_children():
		if i.name == node.name:
			for v in vectors:
				if v == tilemap.local_to_map(i.position):
					shadows_node.remove_child(i)

	for i in vectors:
		tilemap.set_cell(collision.building_layer, i, -1)
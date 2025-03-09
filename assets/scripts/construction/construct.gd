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
var haved:bool = false

func get_buildings() -> Dictionary:
	var data_dict = {}
	for building in buildings.get_children():
		if building.has_method("get_data"):
			data_dict[building.name] = building.get_data()
	return data_dict

func create_node(id:int, vector:Vector2i, node_name:String = "") -> void:
	var blueprints = BlueprintManager.new()
	if blueprints.content.has("nodes"):
		if blueprints.content["nodes"].has(id):
			if blueprints.content["nodes"][id].has("config"):
				if blueprints.content["nodes"][id]["config"].has("name"):
					if blueprints.content["nodes"][id]["config"].has("node"):
						if blueprints.content["nodes"][id]["config"].has("area"):
							if (blueprints.content["nodes"][id]["config"].has('onlyInstance') && !blueprints.content["nodes"][id]["config"]['onlyInstance'])\
							|| (!blueprints.content["nodes"][id]["config"].has('onlyInstance')):
								var node = blueprints.content["nodes"][id]["config"]["node"].instantiate()
								node.set_position(tilemap.map_to_local(vector))
								
								var node_index:int = 1
								if node_name != "":
									if data.get_suffix_from_name(node_name) == 0:
										for i in self.get_children():
											if data.remove_suffix(i.name) == node_name:
												node_index += 1
										node.name = node_name + "_" + str(node_index)
									else:
										node.name = node_name
								else:
									node_index += 1
									node.name = "node_" + str(node_index)

								node.blueprint_id = id
								if blueprints.content["nodes"][id]["config"].has("shadow"):
									if blueprints.content["nodes"][id]["config"]["shadow"] is PackedScene:
										shadows.create_shadow_node(
											node.name,
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
								add_child(node)
							else:
								if blueprints.content["nodes"][id]["config"].has('onlyInstance'):
									haved = false
									for x in self.get_children():
										if data.remove_suffix(x.name) == node_name:
											haved = true
											break
									if !haved:
										var node = blueprints.content["nodes"][id]["config"]["node"].instantiate()
										node.set_position(tilemap.map_to_local(vector))

										var node_index:int = 1
										if node_name != "":
											if data.get_suffix_from_name(node_name) == 0:
												for i in self.get_children():
													if data.remove_suffix(i.name) == node_name:
														node_index += 1
												node.name = node_name + "_" + str(node_index)
											else:
												node.name = node_name
										else:
											node_index += 1
											node.name = "node_" + str(node_index)

										node.blueprint_id = id
										if blueprints.content["nodes"][id]["config"].has("shadow"):
											if blueprints.content["nodes"][id]["config"]["shadow"] is PackedScene:
												shadows.create_shadow_node(
													node.name,
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
										add_child(node)

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

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
@onready var animalManager:Node2D = get_node("/root/"+main+"/AnimalManager")

const max_distance:int = 250
var haved:bool = false
var blueprints = BlueprintManager.new()

func get_buildings() -> Dictionary:
	var data_dict = {}
	for building in buildings.get_children():
		if building.has_method("get_data"):
			data_dict[building.name] = building.get_data()
	return data_dict

func create_node(id:int, vector:Vector2i, node_name:String = ""):
	if blueprints.content.has("nodes"):
		var _blueprint = blueprints.content["nodes"]
		if _blueprint.has(id):
			if _blueprint[id].has("config"):
				if _blueprint[id]["config"].has("name"):
					if _blueprint[id]["config"].has("node"):
						if _blueprint[id]["config"].has("area"):
							if (_blueprint[id]["config"].has('onlyInstance') && !_blueprint[id]["config"]['onlyInstance'])\
							|| (!_blueprint[id]["config"].has('onlyInstance')):
								var node = _blueprint[id]["config"]["node"].instantiate()
								node.set_position(tilemap.map_to_local(vector))
								
								node.name = _generate_unique_name(node_name)
								node.blueprint_id = id
								if _blueprint[id]["config"].has("shadow"):
									if _blueprint[id]["config"]["shadow"] is PackedScene:
										shadows.create_shadow_node(
											node.name,
											_blueprint[id]["config"]["shadow"],
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
									for x in range(_blueprint[id]["config"]["area"].x):
										for y in range(_blueprint[id]["config"]["area"].y):
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
								if animalManager:
									match id:
										4: animalManager.add_spawn(node);
										_: pass
								return node
							else:
								if _blueprint[id]["config"].has('onlyInstance'):
									haved = false
									for x in self.get_children():
										if data.remove_suffix(x.name) == node_name:
											haved = true
											break
									if !haved:
										var node = _blueprint[id]["config"]["node"].instantiate()
										node.set_position(tilemap.map_to_local(vector))

										node.blueprint_id = id
										if _blueprint[id]["config"].has("shadow"):
											if _blueprint[id]["config"]["shadow"] is PackedScene:
												shadows.create_shadow_node(
													node.name,
													_blueprint[id]["config"]["shadow"],
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
											for x in range(_blueprint[id]["config"]["area"].x):
												for y in range(_blueprint[id]["config"]["area"].y):
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
										return node

func remove_node(node:Node2D, vectors:Array[Vector2i]) -> void:
	if !self.get_children().has(node): 
		return

	var blueprint_id = node.blueprint_id
	var _blueprint = blueprints.content
	if !_blueprint.has("nodes") || !blueprints.content['nodes'].has(blueprint_id): 
		return

	var config = _blueprint['nodes'][blueprint_id].get("config", {})
	if config.is_empty(): return

	var resources = config.get("resources", {})
	var required_resources_id = []
	var required_resources_amount = []

	for resource_id in resources:
		var resource_data = resources[resource_id]
		if resource_data.has("amount"):
			required_resources_id.append(resource_id)
			required_resources_amount.append(resource_data["amount"])

	if required_resources_id.size() > 0 && required_resources_amount.size() > 0:
		for i in range(required_resources_id.size()):
			var resource_id = required_resources_id[i]
			var resource_amount = required_resources_amount[i]
			inventory.add_item(resource_id, round(resource_amount / 2))

	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/buildings/destroy.ogg')
	audio.set_pitch_scale(randf_range(0.85, 1.25))
	audio.play()

	for child in shadows_node.get_children():
		if tilemap.local_to_map(child.position) == tilemap.local_to_map(node.position):
			shadows_node.remove_child(child)
			child.queue_free()

	for v in vectors:
		tilemap.set_cell(collision.building_layer, v, -1)

	remove_child(node)
	node.queue_free()

func _generate_unique_name(base_name:String) -> String:
	if base_name == "":
		base_name = "node"

	var existing_names = []
	for child in self.get_children():
		existing_names.append(child.name)

	var candidate = base_name
	var counter = 1
	while existing_names.has(candidate):
		candidate = base_name + "_" + str(counter)
		counter += 1
	return candidate

func _on_audio_finished(node) -> void:
	node.queue_free()

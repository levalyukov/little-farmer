extends Node2D

@onready var farm: FarmingManager = get_tree().current_scene.farm
@onready var build: BuildManager = get_tree().current_scene.build
@onready var nature: NatureManager = get_tree().current_scene.nature
@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var prefabs: PrefabContainer = get_tree().current_scene.prefabs

const GRID_NORMAL: CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/grid/default.png")
const GRID_ERROR: CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/grid/error.png")

var mode: BuildManager.GridModes
var size: Vector2i = Vector2i(4, 4)
var layer_id: int = 0

#* -------------------------------
# * Данные для создания,
# * игрового объекта,
# * которая содержит в себя:
# *
# * var node:Dictionary = \
# * {
# * 	"node": node,
# * 	"shadow": shadow
# * 	"dust": ...
# * }
# *
# * Где:
# * node 	- PackedScene;
# * shadow 	- CompressedTexture2D;
# * dust 	- создавать префаб пыли при
# * добавлении узла на сцену или нет.
#* -------------------------------
var node: Dictionary = {}
var plant: Dictionary = {}
var terrain: Array[int] = []


func _ready() -> void:
	if (
		!is_instance_valid(build)
		|| !is_instance_valid(tilemap)
		|| !is_instance_valid(nature)
		|| !is_instance_valid(prefabs)
	):
		printerr(
			"BuildManager or TileMap or Nature or PrefabsContainer is NULL: ",
			"\n\t",
			build,
			"\n\t",
			tilemap,
			"\n\t",
			nature,
			"\n\t",
			prefabs
		)
		return

	update_grid()


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_movement()
		_collision_check()
		if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			_action()


func _movement() -> void:
	self.set_position(tilemap.map_to_local(tilemap.local_to_map(tilemap.get_global_mouse_position())))


func update_grid() -> void:
	if size.x > build.MAX_GRID_SIZE.x && size.y > build.MAX_GRID_SIZE.y:
		return

	if !self.get_children().is_empty():
		for child in self.get_children():
			self.remove_child(child)
			child.queue_free()

	for x in size.x:
		for y in size.y:
			var sprite: Sprite2D = Sprite2D.new()
			sprite.texture = GRID_ERROR
			sprite.set_position(Vector2i(x * 16, y * 16))
			self.add_child(sprite)


func _action() -> void:
	match mode:
		BuildManager.GridModes.DESTROY:
			for grid in self.get_children():
				if grid.texture == GRID_ERROR:
					return

				if tilemap.get_cell_source_id(self.layer_id, tilemap.local_to_map(grid.global_position)) != -1:
					tilemap.set_cells_terrain_connect(
						self.layer_id, [tilemap.local_to_map(grid.global_position)], 0, -1
					)

		BuildManager.GridModes.FARMING:
			var grid_positions: Array[Vector2i] = []

			for grid in self.get_children():
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& grid.texture != GRID_ERROR
				):
					grid_positions.append(tilemap.local_to_map(grid.global_position))

			if !grid_positions.is_empty():
				tilemap.set_cells_terrain_connect(tilemap.Layers.FARMLAND, grid_positions, 0, tilemap.Terrains.FARMING)
				SoundManager.play_sound("farming/farming")

		BuildManager.GridModes.FERTILIZER:
			pass

		BuildManager.GridModes.WATERING:
			var grid_positions: Array[Vector2i] = []

			for grid in self.get_children():
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& grid.texture != GRID_ERROR
				):
					grid_positions.append(tilemap.local_to_map(grid.global_position))

			if !grid_positions.is_empty():
				tilemap.set_cells_terrain_connect(tilemap.Layers.WATERING, grid_positions, 0, tilemap.Terrains.WATERING)

				for i in grid_positions:
					prefabs.add_prefab(PrefabContainer.PrefabType.WATERING, tilemap.map_to_local(i))

				SoundManager.play_sound("farming/watering")

		BuildManager.GridModes.HARVESTING:
			for grid in self.get_children():
				var crop: Node2D = farm.get_plant_by_coords(tilemap.local_to_map(grid.global_position))
				if crop && grid.texture != GRID_ERROR:
					var crop_data: Dictionary = Crops.get_crop(crop.id)
					if crop_data.is_empty() || !(crop_data.has("item_value") && crop_data["item_id"]):
						return

					Inventory.add_item(
						crop_data["item_id"], randi_range(crop_data["item_value"].x, crop_data["item_value"].y)
					)
					farm.remove_plant(crop)
					tilemap.erase_cell(tilemap.Layers.CROPS, tilemap.local_to_map(grid.global_position))
					SoundManager.play_sound("farming/harvesting")

		BuildManager.GridModes.BUILD:
			var grid_positions: Array[Vector2i] = []

			for grid in self.get_children():
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.BUILDING, tilemap.local_to_map(grid.global_position))
						!= -1
					)
					|| grid.texture == GRID_ERROR
				):
					grid_positions.clear()
					break

				grid_positions.append(tilemap.local_to_map(grid.global_position))

			if !grid_positions.is_empty():
				if !self.node.has("node"):
					printerr("Node for build is NULL.")
					return

				if (
					self.node.has("resources")
					&& self.node["resources"] is Dictionary
					&& !self.node["resources"].is_empty()
				):
					var access_flag: bool = true  # * Флаг, который разрешает создать объект
					var required_resources: Dictionary = {}

					for id in self.node["resources"]:
						var resources_amount: int = self.node["resources"][int(id)]["amount"]
						if Inventory.get_item_amount(int(id)) < resources_amount:
							access_flag = false
							required_resources.clear()
							break
						else:
							required_resources[int(id)] = {}
							required_resources[int(id)]["amount"] = resources_amount

					if access_flag:
						if required_resources.is_empty():
							return

						for i in required_resources:
							Inventory.subject_item(int(i), required_resources[i]["amount"])

						# * Самая простая проверка: если
						# * хватит предметов на следующую
						# * постройку, то оставляем сетку,
						# * иначе - удаляем.
						for j in required_resources:
							var inventory_amount: int = Inventory.get_item_amount(int(j))
							var resources_amount: int = self.node["resources"][int(j)]["amount"]
							if inventory_amount < resources_amount:
								build.grid_remove()

					else:
						build.grid_remove()
						return

				var build_node: Node2D = build.add_build(
					self.node["node"].instantiate(),
					self.node["shadow"],
					tilemap.local_to_map(self.global_position),
					grid_positions,
					self.node["resources"]
				)

				if build_node:
					for vector in grid_positions:
						tilemap.set_cell(
							tilemap.Layers.BUILDING, vector, tilemap.SourcesAtlas.GROUND, tilemap.NODE_COLLISION
						)

					if self.node.has("dust") && self.node["dust"] is bool:
						var sprite: Node = build_node.get_node("Sprite2D")
						if sprite && sprite is Sprite2D:
							prefabs.add_prefab(
								PrefabContainer.PrefabType.DUST,
								self.global_position + sprite.position,
								Vector2i(sprite.texture.get_width(), sprite.texture.get_height())
							)

					SoundManager.play_sound("building/build")
				else:
					printerr("Node is NULL.")

		BuildManager.GridModes.PLANT:
			for grid in self.get_children():
				if grid.texture != GRID_ERROR:
					if (
						farm.add_plant(plant, tilemap.local_to_map(grid.global_position))
						&& Inventory.get_item_amount(plant["inventory_item"]) > 0
					):
						tilemap.set_cell(
							tilemap.Layers.CROPS,
							tilemap.local_to_map(grid.global_position),
							tilemap.SourcesAtlas.GROUND,
							tilemap.NODE_COLLISION
						)

						Inventory.subject_item(plant["inventory_item"])
						SoundManager.play_sound("farming/planting")

					if Inventory.get_item_amount(plant["inventory_item"]) < 1:
						build.grid_remove()

		BuildManager.GridModes.TERRAIN:
			print("Hello, World!")


func _collision_check() -> void:
	if !is_instance_valid(build) && !is_instance_valid(tilemap):
		self.layer_id = -1
		return

	for grid in self.get_children():
		#! Мне все равно не нравится этот вариант перебора слоев...
		grid.texture = GRID_ERROR

		match mode:
			BuildManager.GridModes.DESTROY:
				if (
					tilemap.get_cell_source_id(tilemap.Layers.BUILDING, tilemap.local_to_map(grid.global_position))
					!= -1
				):
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.BUILDING
					return

				if tilemap.get_cell_source_id(tilemap.Layers.CROPS, tilemap.local_to_map(grid.global_position)) != -1:
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.CROPS
					return

				if (
					tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(grid.global_position))
					!= -1
				):
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.WATERING
					return

				if (
					tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
					!= -1
				):
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.FARMLAND
					return

				if tilemap.get_cell_source_id(tilemap.Layers.NATURE, tilemap.local_to_map(grid.global_position)) != -1:
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.NATURE
					return

				if tilemap.get_cell_source_id(tilemap.Layers.ROAD, tilemap.local_to_map(grid.global_position)) != -1:
					grid.texture = GRID_NORMAL
					self.layer_id = tilemap.Layers.ROAD

			BuildManager.GridModes.FARMING:
				if (
					(tilemap.get_cell_source_id(tilemap.Layers.ROAD, tilemap.local_to_map(grid.global_position)) != -1)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap
						. get_cell_tile_data(tilemap.Layers.ROAD, tilemap.local_to_map(grid.global_position))
						. get_custom_data("can_place_dirt")
					)
				):
					grid.texture = GRID_NORMAL

			# 	BuildManager.GridModes.FERTILIZER:
			# 		self.layer_id = 1

			BuildManager.GridModes.WATERING:
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						!= -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(grid.global_position))
						== -1
					)
				):
					grid.texture = GRID_NORMAL

			BuildManager.GridModes.HARVESTING:
				var crop: Node2D = farm.get_plant_by_coords(tilemap.local_to_map(grid.global_position))
				if (
					tilemap.get_cell_source_id(tilemap.Layers.CROPS, tilemap.local_to_map(grid.global_position)) != -1
					&& (crop && crop.growed)
				):
					grid.texture = GRID_NORMAL

			BuildManager.GridModes.BUILD:
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.BUILDING, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.NATURE, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.BORDERS, tilemap.local_to_map(grid.global_position))
						== -1
					)
					&& (
						tilemap.get_cell_source_id(
							tilemap.Layers.STATIC_NODES, tilemap.local_to_map(grid.global_position)
						)
						== -1
					)
				):
					grid.texture = GRID_NORMAL

			BuildManager.GridModes.PLANT:
				if (
					(
						tilemap.get_cell_source_id(tilemap.Layers.FARMLAND, tilemap.local_to_map(grid.global_position))
						!= -1
					)
					&& (
						tilemap.get_cell_source_id(tilemap.Layers.CROPS, tilemap.local_to_map(grid.global_position))
						== -1
					)
				):
					grid.texture = GRID_NORMAL

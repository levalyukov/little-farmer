class_name NatureManager extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var build: BuildManager = get_tree().current_scene.build
@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var shadow: ShadowManager = get_tree().current_scene.shadow

enum NatureType { TREE, BUSH, WEED, LONG_WEED, STONE, BOULDERS, STUMP }
const SHADER_DISABLE: Array[NatureType] = [NatureType.STONE, NatureType.BOULDERS, NatureType.STUMP]
const TEXTURES: Dictionary = {
	NatureType.TREE:
	{
		WorldCycle.Season.SPRING:
		[
			preload("res://assets/resources/world/trees/spring/tree_1.png"),
			preload("res://assets/resources/world/trees/spring/tree_2.png"),
			preload("res://assets/resources/world/trees/spring/tree_3.png"),
			preload("res://assets/resources/world/trees/spring/tree_4.png"),
			preload("res://assets/resources/world/trees/spring/tree_5.png"),
			preload("res://assets/resources/world/trees/spring/tree_6.png")
		],
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/trees/summer/tree_1.png"),
			preload("res://assets/resources/world/trees/summer/tree_2.png"),
			preload("res://assets/resources/world/trees/summer/tree_3.png"),
			preload("res://assets/resources/world/trees/summer/tree_4.png"),
			preload("res://assets/resources/world/trees/summer/tree_5.png"),
			preload("res://assets/resources/world/trees/summer/tree_6.png")
		],
		WorldCycle.Season.AUTUMN:
		[
			preload("res://assets/resources/world/trees/autumn/tree_1.png"),
			preload("res://assets/resources/world/trees/autumn/tree_2.png"),
			preload("res://assets/resources/world/trees/autumn/tree_3.png"),
			preload("res://assets/resources/world/trees/autumn/tree_4.png"),
			preload("res://assets/resources/world/trees/autumn/tree_5.png"),
			preload("res://assets/resources/world/trees/autumn/tree_6.png")
		],
		WorldCycle.Season.WINTER:
		[
			preload("res://assets/resources/world/trees/winter/tree_1.png"),
			preload("res://assets/resources/world/trees/winter/tree_2.png"),
			preload("res://assets/resources/world/trees/winter/tree_3.png"),
			preload("res://assets/resources/world/trees/winter/tree_4.png"),
			preload("res://assets/resources/world/trees/winter/tree_5.png"),
			preload("res://assets/resources/world/trees/winter/tree_6.png")
		]
	},
	NatureType.BUSH:
	#! Что-то здесь будет
	{},
	NatureType.WEED:
	{
		WorldCycle.Season.SPRING:
		[
			preload("res://assets/resources/world/weeds/spring/weed_1.png"),
			preload("res://assets/resources/world/weeds/spring/weed_2.png"),
			preload("res://assets/resources/world/weeds/spring/weed_3.png"),
			preload("res://assets/resources/world/weeds/spring/weed_4.png"),
			preload("res://assets/resources/world/weeds/spring/weed_5.png"),
			preload("res://assets/resources/world/weeds/spring/weed_6.png"),
			preload("res://assets/resources/world/weeds/spring/weed_7.png"),
			preload("res://assets/resources/world/weeds/spring/weed_8.png")
		],
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/weeds/summer/weed_1.png"),
			preload("res://assets/resources/world/weeds/summer/weed_2.png"),
			preload("res://assets/resources/world/weeds/summer/weed_3.png"),
			preload("res://assets/resources/world/weeds/summer/weed_4.png"),
			preload("res://assets/resources/world/weeds/summer/weed_5.png"),
			preload("res://assets/resources/world/weeds/summer/weed_6.png"),
			preload("res://assets/resources/world/weeds/summer/weed_7.png"),
			preload("res://assets/resources/world/weeds/summer/weed_8.png")
		],
		WorldCycle.Season.AUTUMN:
		[
			preload("res://assets/resources/world/weeds/autumn/weed_1.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_2.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_3.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_4.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_5.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_6.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_7.png"),
			preload("res://assets/resources/world/weeds/autumn/weed_8.png")
		],
		WorldCycle.Season.WINTER:
		[
			preload("res://assets/resources/world/weeds/winter/weed_1.png"),
			preload("res://assets/resources/world/weeds/winter/weed_2.png"),
			preload("res://assets/resources/world/weeds/winter/weed_3.png"),
			preload("res://assets/resources/world/weeds/winter/weed_4.png"),
			preload("res://assets/resources/world/weeds/winter/weed_5.png"),
			preload("res://assets/resources/world/weeds/winter/weed_6.png"),
			preload("res://assets/resources/world/weeds/winter/weed_7.png"),
			preload("res://assets/resources/world/weeds/winter/weed_8.png")
		]
	},
	NatureType.LONG_WEED:
	{
		# WorldCycle.Season.SPRING:
		# [
		# ],
		
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/long_weed/summer/sprite_0.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_1.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_2.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_3.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_4.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_5.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_6.png"),
			preload("res://assets/resources/world/long_weed/summer/sprite_7.png"),
		],

		# WorldCycle.Season.AUTUMN:
		# [
		# ],

		# WorldCycle.Season.WINTER:
		# [
		# ]
	},
	NatureType.STONE:
	[
		preload("res://assets/resources/world/stones/stone_1.png"),
		preload("res://assets/resources/world/stones/stone_2.png"),
		preload("res://assets/resources/world/stones/stone_3.png"),
		preload("res://assets/resources/world/stones/stone_4.png"),
		preload("res://assets/resources/world/stones/stone_5.png"),
		preload("res://assets/resources/world/stones/stone_6.png"),
		preload("res://assets/resources/world/stones/stone_7.png"),
		preload("res://assets/resources/world/stones/stone_8.png")
	],
	NatureType.BOULDERS:
	[
		preload("res://assets/resources/world/boulders/big_stone_1.png"),
		preload("res://assets/resources/world/boulders/big_stone_2.png"),
		preload("res://assets/resources/world/boulders/big_stone_3.png"),
		preload("res://assets/resources/world/boulders/big_stone_4.png")
	],
	NatureType.STUMP:
	[
		preload("res://assets/resources/world/stumps/stump_0.png"),
		preload("res://assets/resources/world/stumps/stump_1.png"),
		preload("res://assets/resources/world/stumps/stump_2.png"),
		preload("res://assets/resources/world/stumps/stump_3.png"),
		preload("res://assets/resources/world/stumps/stump_4.png"),
		preload("res://assets/resources/world/stumps/stump_5.png")
	]
}

const SHADOWS: Dictionary = {
	NatureType.TREE:
	[
		preload("res://assets/resources/world/trees/shadow_1.png"),
		preload("res://assets/resources/world/trees/shadow_2.png"),
		preload("res://assets/resources/world/trees/shadow_3.png"),
		preload("res://assets/resources/world/trees/shadow_4.png"),
		preload("res://assets/resources/world/trees/shadow_5.png"),
		preload("res://assets/resources/world/trees/shadow_6.png")
	],
	NatureType.BUSH: {},
	NatureType.WEED:
	{
		WorldCycle.Season.SPRING:
		[
			preload("res://assets/resources/world/weeds/spring/shadow_1.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_2.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_3.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_4.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_5.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_6.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_7.png"),
			preload("res://assets/resources/world/weeds/spring/shadow_8.png")
		],
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/weeds/summer/shadow_1.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_2.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_3.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_4.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_5.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_6.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_7.png"),
			preload("res://assets/resources/world/weeds/summer/shadow_8.png")
		],
		WorldCycle.Season.AUTUMN:
		[
			preload("res://assets/resources/world/weeds/autumn/shadow_1.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_2.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_3.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_4.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_5.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_6.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_7.png"),
			preload("res://assets/resources/world/weeds/autumn/shadow_8.png")
		],
		WorldCycle.Season.WINTER:
		[
			preload("res://assets/resources/world/weeds/winter/shadow_1.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_2.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_3.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_4.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_5.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_6.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_7.png"),
			preload("res://assets/resources/world/weeds/winter/shadow_8.png")
		]
	},
	NatureType.LONG_WEED:
	{
		WorldCycle.Season.SUMMER:
		[
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_0.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_1.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_2.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_3.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_4.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_5.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_6.png"),
			preload("res://assets/resources/world/long_weed/summer/shadow/sprite_7.png"),
		]
	},
	NatureType.STONE:
	[
		preload("res://assets/resources/world/stones/shadows/shadow_1.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_2.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_3.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_4.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_5.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_6.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_7.png"),
		preload("res://assets/resources/world/stones/shadows/shadow_8.png")
	],
	NatureType.BOULDERS:
	[
		preload("res://assets/resources/world/boulders/big_stone_shadow_1.png"),
		preload("res://assets/resources/world/boulders/big_stone_shadow_2.png"),
		preload("res://assets/resources/world/boulders/big_stone_shadow_3.png"),
		preload("res://assets/resources/world/boulders/big_stone_shadow_4.png")
	],
	NatureType.STUMP:
	[
		preload("res://assets/resources/world/stumps/shadow_0.png"),
		preload("res://assets/resources/world/stumps/shadow_1.png"),
		preload("res://assets/resources/world/stumps/shadow_2.png"),
		preload("res://assets/resources/world/stumps/shadow_3.png"),
		preload("res://assets/resources/world/stumps/shadow_4.png"),
		preload("res://assets/resources/world/stumps/shadow_5.png")
	]
}

const MAX_TREE: int = 1000
const MAX_BUSH: int = 100
const MAX_WEED: int = 1000
const MAX_LONG_WEED: int = 300
const MAX_STONE: int = 600
const MAX_BOULDERS: int = 150
const MAX_STUMPS: int = 200

const NOISE_COEFFICIENT: Array[float] = [
	0.03, 	0.04, 	0.07, 
	0.009, 	0.005, 	0.007,
	0.02, 	0.3, 	0.1
]
const SHADER_SOURCE: Shader = preload("res://assets/shaders/wind.gdshader")
const NATURES_NODE: Dictionary = {
	NatureType.TREE:
	{
		"max": MAX_TREE,
		"id": 1,
		"value": [1, 3],
		"sample": "farming/tree_destroy",
		"area_size": Vector2i(1, 1),
		"sprite_offset": Vector2i(0, -16),
		"collision_size": Vector2i(16, 16),
		"collision_offset": Vector2i(0, 16)
	},
	NatureType.BUSH:
	{
		"max": MAX_BUSH,
		"sample": "farming/weed_destroy",
		"area_size": Vector2i(1, 1),
		"sprite_offset": Vector2i(8, 8),
		"collision_size": Vector2i(0, 0),
		"collision_offset": Vector2i(0, 0)
	},
	NatureType.WEED:
	{
		"max": MAX_WEED,
		"sample": "farming/weed_destroy",
		"area_size": Vector2i(1, 1),
		"sprite_offset": Vector2i(0, 0),
		"collision_size": Vector2i(0, 0),
		"collision_offset": Vector2i(0, 0)
	},
	NatureType.LONG_WEED:
	{
		"max": MAX_LONG_WEED,
		"sample": "farming/weed_destroy",
		"area_size": Vector2i(1, 1),
		"sprite_offset": Vector2i(0, -8),
		"collision_size": Vector2i(16, 16),
		"collision_offset": Vector2i(0, 8)
	},
	NatureType.STONE:
	{
		"max": MAX_STONE,
		"id": 3,
		"value": [1, 2],
		"sample": "farming/stone_destroy",
		"area_size": Vector2i(1, 1),
		"sprite_offset": Vector2i(0, 0),
		"collision_size": Vector2i(0, 0),
		"collision_offset": Vector2i(0, 0)
	},
	NatureType.BOULDERS:
	{
		"max": MAX_BOULDERS,
		"id": 3,
		"value": [2, 10],
		"sample": "farming/stone_destroy",
		"area_size": Vector2i(2, 2),
		"sprite_offset": Vector2i(8, 8),
		"collision_size": Vector2i(0, 0),
		"collision_offset": Vector2i(0, 0)
	},
	NatureType.STUMP:
	{
		"max": MAX_STUMPS,
		"id": 1,
		"value": [1, 1],
		"sample": "farming/tree_destroy",
		"area_size": Vector2i(1, 1),
		"sprite_offset": Vector2i(0, 0),
		"collision_size": Vector2i(0, 0),
		"collision_offset": Vector2i(0, 0)
	}
}

var tiles: Array[Vector2i] = []
var shader: ShaderMaterial = _setup_wind_shader()


func _ready() -> void:
	if !is_instance_valid(tilemap):
		printerr("TileMap is NULL.")
		return

	if !is_instance_valid(build):
		printerr("BuildManager is NULL.")
		return

	if !is_instance_valid(shadow):
		printerr("ShadowManager is NULL.")
		return


func spawn() -> void:
	self.tiles = _get_free_tiles()

	create_nature(NatureType.TREE)
	create_nature(NatureType.WEED)
	create_nature(NatureType.LONG_WEED)
	create_nature(NatureType.STONE)
	create_nature(NatureType.BOULDERS)
	create_nature(NatureType.STUMP)


func add_nature_node(
	type: NatureType,
	size: Vector2i,
	pos: Vector2i,
	sprite_offset: Vector2i = Vector2i(0, 0),
	collision_size: Vector2i = Vector2i(0, 0),
	collision_pos: Vector2i = Vector2i(0, 0)
) -> Node2D:
	#* ------------------------------------------------------
	# * Тут нужно пояснение: здесь проверка на соостветствие
	# * размеров массивов для корректной выборки спрайта тени.
	# *
	# * Из-за того что спрайты могут храниться в словарях и в
	# * обычном массиве, из-за того что система смены сезонов,
	# * принято решение сделать такой способ проверки на размер.
	# *
	# * Уродливое решение? Да, но я ничего лучшего не придумал,
	# * зато работает, но позже нужно это переделать...
	# *
	# * P.S. №1 Эта проверка чисто защита от дураков и от меня,
	# * ибо работает даже без этой проверки, но я параноик.
	#* ------------------------------------------------------

	if TEXTURES[type] is Dictionary && SHADOWS[type] is Dictionary:
		if !(TEXTURES[type][cycle.season_id].size() == SHADOWS[type][cycle.season_id].size()):
			printerr("The sizes of the two arrays do not match.")
			return null

	if TEXTURES[type] is Dictionary && SHADOWS[type] is Array[CompressedTexture2D]:
		if !(TEXTURES[type][cycle.season_id].size() == SHADOWS[type].size()):
			printerr("The sizes of the two arrays do not match.")
			return null

	if TEXTURES[type] is Array[CompressedTexture2D] && SHADOWS[type] is Array[CompressedTexture2D]:
		if !(TEXTURES[type][cycle.season_id].size() == SHADOWS[type].size()):
			printerr("The sizes of the two arrays do not match.")
			return null

	if size.x < 1 || size.y < 1:
		printerr("Uncorrected node size: Vector(", size.x, ",", size.y, ")")
		return null

	var node_cells: Array[Vector2i] = []
	if size.x > 1 && size.y > 1:
		for x in size.x:
			for y in size.y:
				node_cells.append(pos + Vector2i(x, y))

		if !node_cells.is_empty():
			for i in node_cells:
				if (
					tilemap.get_cell_source_id(tilemap.Layers.ROAD, i) != -1
					|| tilemap.get_cell_source_id(tilemap.Layers.NATURE, i) != -1
					|| tilemap.get_cell_source_id(tilemap.Layers.BUILDING, i) != -1
					|| tilemap.get_cell_source_id(tilemap.Layers.STATIC_NODES, i) != -1
				):
					return null

			for j in node_cells:
				self.tiles.erase(j)
				tilemap.set_cell(tilemap.Layers.NATURE, j, tilemap.SourcesAtlas.GROUND, tilemap.NODE_COLLISION)

	else:
		node_cells.append(pos)
		tilemap.set_cell(tilemap.Layers.NATURE, pos, tilemap.SourcesAtlas.GROUND, tilemap.NODE_COLLISION)

	var parent: Node2D = Node2D.new()
	var area: Area2D = Area2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var sprite: Sprite2D = Sprite2D.new()
	var random: int = (
		randi() % TEXTURES[type][cycle.season_id].size()
		if TEXTURES[type] is Dictionary
		else randi() % TEXTURES[type].size()
	)
	var random_texture: CompressedTexture2D = (
		TEXTURES[type][cycle.season_id][random] if TEXTURES[type] is Dictionary else TEXTURES[type][random]
	)

	sprite.texture = random_texture
	sprite.position.x += sprite_offset.x
	sprite.position.y += sprite_offset.y

	var shadow_node: Node2D = shadow.add_shadow(
		SHADOWS[type][cycle.season_id][random] if SHADOWS[type] is Dictionary else SHADOWS[type][random],
		tilemap.map_to_local(pos),
		sprite_offset
	)

	if type not in SHADER_DISABLE:
		var coefficient: float = fmod(randf(), NOISE_COEFFICIENT[cycle.season_id])

		sprite.material = self.shader
		sprite.material = sprite.material.duplicate()
		sprite.material.set_shader_parameter("amplitude", coefficient)

		if shadow_node:
			shadow_node.material = self.shader
			shadow_node.material = shadow_node.material.duplicate()
			shadow_node.material.set_shader_parameter("amplitude", coefficient)

	if collision_size.x == 0 && collision_size.y == 0:
		rectangle.size = random_texture.get_size()
	else:
		rectangle.size = collision_size

	collision.shape = rectangle
	collision.position = collision_pos
	area.position.x += sprite_offset.x
	area.position.y += sprite_offset.y
	area.input_pickable = true
	area.input_event.connect(
		func(_viewport: Node, event: InputEvent, _index: int) -> void:
			if (
				build.buildings.has(build.GRID.get_state().get_node_name(0))
				&& build.buildings[build.GRID.get_state().get_node_name(0)].mode == BuildManager.GridModes.DESTROY
			):
				if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
					if NATURES_NODE.has(type):
						var id: int = NATURES_NODE[type]["id"] if NATURES_NODE[type].has("id") else -1
						var value: Array = NATURES_NODE[type]["value"] if NATURES_NODE[type].has("value") else []
						var sample: String = NATURES_NODE[type]["sample"] if NATURES_NODE[type].has("sample") else ""

						if Items.items.has(id) && !value.is_empty():
							Inventory.add_item(id, randi_range(value[0], value[1]))
						SoundManager.play_sound(sample)

					for i in node_cells:
						tilemap.erase_cell(tilemap.Layers.NATURE, i)

					shadow_node.queue_free()
					parent.queue_free()
	)

	area.add_child(collision)

	parent.set_meta("type", type)
	parent.set_meta("shadow", shadow_node)
	parent.set_meta("relative_cells", node_cells)
	parent.set_position(tilemap.map_to_local(pos))
	parent.add_child(sprite)
	parent.add_child(area)

	return parent


func create_nature(type: NatureType) -> void:
	if NATURES_NODE.is_empty() && !NATURES_NODE.has(type):
		return

	var current_position: int = -1
	for i in NATURES_NODE[type]["max"]:
		current_position = randi() % self.tiles.size()
		(
			self
			. add_child(
				add_nature_node(
					type,
					NATURES_NODE[type]["area_size"],
					self.tiles[current_position],
					NATURES_NODE[type]["sprite_offset"] if NATURES_NODE[type].has("sprite_offset") else Vector2i(0, 0),
					(
						NATURES_NODE[type]["collision_size"]
						if NATURES_NODE[type].has("collision_size")
						else Vector2i(0, 0)
					),
					(
						NATURES_NODE[type]["collision_offset"]
						if NATURES_NODE[type].has("collision_offset")
						else Vector2i(0, 0)
					),
				)
			)
		)

		self.tiles.erase(tiles[current_position])


func _get_free_tiles() -> Array[Vector2i]:
	var map: Array[Vector2i] = tilemap.get_used_cells(tilemap.Layers.GROUND)
	var occupieds: Array[Vector2i] = []

	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.ROAD))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.BUILDING))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.COAST))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.FARMLAND))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.STATIC_NODES))

	for vector in occupieds:
		map.erase(vector)

	return map


func _setup_wind_shader() -> ShaderMaterial:
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	var noise_texture: NoiseTexture2D = NoiseTexture2D.new()
	var noise: FastNoiseLite = FastNoiseLite.new()

	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_texture.noise = noise

	shader_material.shader = SHADER_SOURCE
	shader_material.set_shader_parameter("noise_texture", noise_texture)

	return shader_material

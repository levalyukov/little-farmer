class_name NatureManager extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var shadow: ShadowManager = get_tree().current_scene.shadow

enum NatureType { TREE, BUSH, WEED, STONE }

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
	]
}

const NOISE_COEFFICIENT:float = 0.05
const SHADER_SOURCE: Shader = preload("res://assets/shaders/wind.gdshader")
const MAX_TREE: int = 700
const MAX_BUSH: int = 100
const MAX_WEED: int = 1500
const MAX_STONE: int = 400

var tiles: Array[Vector2i] = []
var shader:ShaderMaterial = _setup_wind_shader()


func spawn() -> void:
	if !is_instance_valid(tilemap):
		printerr("TileMap is NULL.")
		return

	if !is_instance_valid(shadow):
		printerr("ShadowManager is NULL.")
		return

	self.tiles = _get_free_tiles()
	_create_tree()
	_create_weed()
	_create_stone()


func _create_tree() -> void:
	var it: int = 0
	var position_id: int = -1
	while it < MAX_TREE:
		position_id = randi() % self.tiles.size()
		self.add_child(_create_nature_node(NatureType.TREE, self.tiles[position_id], Vector2i(0, -16)))
		self.tiles.erase(tiles[position_id])
		it += 1


func _create_nature_node(
	node_type: NatureType, node_position: Vector2i, node_sprite_offset: Vector2i = Vector2i(0, 0)
) -> Node2D:

	# ------------------------------------------------------
	# Тут нужно пояснение: здесь проверка на соостветствие
	# размеров массивов для корректной выборки спрайта тени.
	#
	# Из-за того что спрайты могут храниться в словарях и в
	# обычном массиве, из-за того что система смены сезонов,
	# принято решение сделать такой способ проверки на размер.
	#
	# Уродливое решение? Да, но я ничего лучшего не придумал,
	# зато работает, но позже нужно это переделать...
	# ------------------------------------------------------

	if TEXTURES[node_type] is Dictionary && SHADOWS[node_type] is Dictionary:
		if !(TEXTURES[node_type][cycle.season_id].size() == SHADOWS[node_type][cycle.season_id].size()):
			printerr("The sizes of the two arrays do not match.")
			return

	if TEXTURES[node_type] is Dictionary && SHADOWS[node_type] is Array[CompressedTexture2D]:
		if !(TEXTURES[node_type][cycle.season_id].size() == SHADOWS[node_type].size()):
			printerr("The sizes of the two arrays do not match.")
			return

	if TEXTURES[node_type] is Array[CompressedTexture2D] && SHADOWS[node_type] is Array[CompressedTexture2D]:
		if !(TEXTURES[node_type][cycle.season_id].size() == SHADOWS[node_type].size()):
			printerr("The sizes of the two arrays do not match.")
			return

	var parent: Node2D = Node2D.new()
	var sprite: Sprite2D = Sprite2D.new()
	var random: int = (
		randi() % TEXTURES[node_type][cycle.season_id].size()
		if TEXTURES[node_type] is Dictionary
		else randi() % TEXTURES[node_type].size()
	)

	sprite.texture = (
		TEXTURES[node_type][cycle.season_id][random]
		if TEXTURES[node_type] is Dictionary
		else TEXTURES[node_type][random]
	)

	sprite.position.x += node_sprite_offset.x
	sprite.position.y += node_sprite_offset.y
	
	if node_type != NatureType.STONE:
		sprite.material = shader

	var shadow_node:Sprite2D = shadow.shadow_add(
		SHADOWS[node_type][cycle.season_id][random]if SHADOWS[node_type] is Dictionary else SHADOWS[node_type][random],
		tilemap.map_to_local(node_position)
	)

	if shadow_node:
		shadow_node.material = shader
	

	parent.z_index = tilemap.Layers.NATURE
	parent.set_position(tilemap.map_to_local(node_position))
	parent.add_child(sprite)

	return parent


func _create_weed() -> void:
	var it: int = 0
	var position_id: int = -1
	while it < MAX_WEED:
		position_id = randi() % self.tiles.size()
		self.add_child(_create_nature_node(NatureType.WEED, self.tiles[position_id]))
		self.tiles.erase(tiles[position_id])
		it += 1


func _create_stone() -> void:
	var it: int = 0
	var position_id: int = -1
	while it < MAX_STONE:
		position_id = randi() % self.tiles.size()
		self.add_child(_create_nature_node(NatureType.STONE, self.tiles[position_id]))
		self.tiles.erase(tiles[position_id])
		it += 1


func _get_free_tiles() -> Array[Vector2i]:
	var map: Array[Vector2i] = tilemap.get_used_cells(tilemap.Layers.GROUND)

	var occupieds: Array[Vector2i] = []
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.ROAD))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.BUILDING))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.COAST))
	occupieds.append_array(tilemap.get_used_cells(tilemap.Layers.FARMLAND))

	for vector in occupieds:
		if map.has(vector):
			map.erase(vector)

	return map

func _setup_wind_shader() -> ShaderMaterial:
	var shader_material:ShaderMaterial = ShaderMaterial.new()
	var noise_texture:NoiseTexture2D = NoiseTexture2D.new()
	var noise:FastNoiseLite = FastNoiseLite.new() 

	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_texture.noise = noise

	shader_material.shader = SHADER_SOURCE
	shader_material.set_shader_parameter("amplitude", NOISE_COEFFICIENT)
	shader_material.set_shader_parameter("noise_texture", noise_texture)

	return shader_material
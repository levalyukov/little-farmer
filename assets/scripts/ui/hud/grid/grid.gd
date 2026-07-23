extends Node2D

@onready var build:BuildManager = get_parent()
@onready var sprite:Sprite2D = $Sprite2D

const GRID_NORMAL:CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/grid/default.png")
const GRID_ERROR:CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/grid/error.png")

var mode:int = 0
var code:int = 0

func _input(event):
	if event is InputEventMouseButton\
	&& event.pressed\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& sprite.texture != GRID_ERROR:
		action()

func _process(_delta:float) -> void:
	movement()
	collision_check()

func movement() -> void:
	if is_instance_valid(build.tilemap):
		self.set_position(
			build.tilemap.map_to_local(
				build.tilemap.local_to_map(
					build.tilemap.get_global_mouse_position()
		)))

func collision_check() -> void:
	if !is_instance_valid(build.tilemap):
		code = -1
		return
	
	sprite.texture = GRID_ERROR
	match mode:
		build.GRID_MODES.DESTROY:
			#! Мне все равно не нравится этот вариант перебора слоев...

			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.WATERING,
				build.tilemap.local_to_map(self.global_position)
			) != -1:
				sprite.texture = GRID_NORMAL
				code = build.tilemap.LAYERS.WATERING
				return

			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.FARMLAND,
				build.tilemap.local_to_map(self.global_position)
			) != -1:
				sprite.texture = GRID_NORMAL
				code = build.tilemap.LAYERS.FARMLAND
				return

			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.ROAD,
				build.tilemap.local_to_map(self.global_position)
			) != -1:
				sprite.texture = GRID_NORMAL
				code = build.tilemap.LAYERS.ROAD

		build.GRID_MODES.FARMING:
			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.ROAD,
				build.tilemap.local_to_map(self.global_position)
			) != -1 && \
			build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.FARMLAND,
				build.tilemap.local_to_map(self.global_position)
			) == -1 && \
			build.tilemap.get_cell_tile_data(
				build.tilemap.LAYERS.ROAD,
				build.tilemap.local_to_map(self.global_position)
			).get_custom_data("can_place_dirt"):
				sprite.texture = GRID_NORMAL

		build.GRID_MODES.FERTILIZER:
			code = 1

		build.GRID_MODES.WATERING:
			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.FARMLAND,
				build.tilemap.local_to_map(self.global_position)
			) != -1 && \
			build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.WATERING,
				build.tilemap.local_to_map(self.global_position)
			) == -1:
				sprite.texture = GRID_NORMAL

		build.GRID_MODES.HARVESTING:
			code = 1

		build.GRID_MODES.BUILD:
			code = 1

		_: code = -1

func action() -> void:
	if !is_instance_valid(build.tilemap):
		return

	match mode:
		build.GRID_MODES.DESTROY:
			if build.tilemap.get_cell_source_id(
				code, build.tilemap.local_to_map(self.global_position)
			) != -1:
				build.tilemap.set_cells_terrain_connect(
					code, 
					[build.tilemap.local_to_map(self.global_position)], 
					0, -1
				)

		build.GRID_MODES.FARMING:
			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.FARMLAND,
				build.tilemap.local_to_map(self.global_position)
			) == -1:
				build.tilemap.set_cells_terrain_connect(
					build.tilemap.LAYERS.FARMLAND, 
					[build.tilemap.local_to_map(self.global_position)], 
					0, build.tilemap.TERRAINS.FARMING
				)
			SoundManager.play_sound("farming/farming")

		build.GRID_MODES.FERTILIZER:
			pass

		build.GRID_MODES.WATERING:
			if build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.FARMLAND,
				build.tilemap.local_to_map(self.global_position)
			) != -1 && \
			build.tilemap.get_cell_source_id(
				build.tilemap.LAYERS.WATERING,
				build.tilemap.local_to_map(self.global_position)
			) == -1:
				build.tilemap.set_cells_terrain_connect(
					build.tilemap.LAYERS.WATERING, 
					[build.tilemap.local_to_map(self.global_position)], 
					0, build.tilemap.TERRAINS.WATERING
				)
			SoundManager.play_sound("farming/watering")

		build.GRID_MODES.HARVESTING:
			pass

		build.GRID_MODES.BUILD:
			pass
class_name BuildManager extends Node

@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var shadow: ShadowManager = get_tree().current_scene.shadow
@onready var prefabs: PrefabContainer = get_tree().current_scene.prefabs

enum GridModes { DESTROY, FARMING, FERTILIZER, WATERING, HARVESTING, BUILD, PLANT, TERRAIN }

const MAX_DISTANCE: int = 250
const MAX_GRID_SIZE: Vector2i = Vector2i(16, 16)

const HOUSE_POSITION: Vector2i = Vector2i(19, 2)
const MAILBOX_POSITION: Vector2i = Vector2i(16, 2)
const STORAGE_POSITION: Vector2i = Vector2i(22, 2)

const HOUSE_SHADOW: CompressedTexture2D = preload("res://assets/resources/buildings/house/shadow.png")
const MAILBOX_SHADOW: CompressedTexture2D = preload("res://assets/resources/buildings/mailbox/shadow.png")
const STORAGE_SHADOW: CompressedTexture2D = preload("res://assets/resources/buildings/storage/shadow.png")

const HOUSE: PackedScene = preload("res://assets/nodes/buildings/house.tscn")
const MAILBOX: PackedScene = preload("res://assets/nodes/buildings/mailbox.tscn")
const STORAGE: PackedScene = preload("res://assets/nodes/buildings/storage.tscn")
const GRID: PackedScene = preload("res://assets/nodes/buildings/grid.tscn")

var buildings: Dictionary


func _ready():
	set_process_input(false)

	var house: Node2D = HOUSE.instantiate()
	var mailbox: Node2D = MAILBOX.instantiate()
	var storage: Node2D = STORAGE.instantiate()

	if (house && mailbox && storage) && (house is Node2D && mailbox is Node2D && storage is Node2D):
		buildings[HOUSE.get_state().get_node_name(0)] = house
		buildings[MAILBOX.get_state().get_node_name(0)] = mailbox
		buildings[STORAGE.get_state().get_node_name(0)] = storage

		house.set_position(tilemap.map_to_local(HOUSE_POSITION))
		mailbox.set_position(tilemap.map_to_local(MAILBOX_POSITION))
		storage.set_position(tilemap.map_to_local(STORAGE_POSITION))

		self.add_child(house)
		self.add_child(mailbox)
		self.add_child(storage)

		var house_sprite: Sprite2D = house.get_node("Sprite2D")
		var mailbox_sprite: Sprite2D = mailbox.get_node("Sprite2D")
		var storage_sprite: Sprite2D = storage.get_node("Sprite2D")

		if house_sprite && house_sprite is Sprite2D:
			shadow.add_shadow(HOUSE_SHADOW, house.position + house_sprite.position)

		if mailbox_sprite && house_sprite is Sprite2D:
			shadow.add_shadow(MAILBOX_SHADOW, mailbox.position + mailbox_sprite.position)

		if storage_sprite && house_sprite is Sprite2D:
			shadow.add_shadow(STORAGE_SHADOW, storage.position + storage_sprite.position)


func _input(event: InputEvent) -> void:
	if (
		((event is InputEventMouseButton) && (event.pressed) && ((event.button_index) == MOUSE_BUTTON_RIGHT))
		|| ((event.is_action_pressed("esc")) && (buildings.has(GRID.get_state().get_node_name(0))))
	):
		if buildings.has(GRID.get_state().get_node_name(0)):
			grid_remove()


func grid_add(mode: BuildManager.GridModes, size: Vector2i = Vector2i(1, 1)) -> Node2D:
	var grid: Node2D = null

	if !(size.x > 0 && size.y > 0) || !(size.x <= MAX_GRID_SIZE.x && size.y <= MAX_GRID_SIZE.y):
		printerr("Incorrect grid size.")
		return

	if !(buildings.has(GRID.get_state().get_node_name(0))):
		var node = GRID.instantiate()
		buildings[node.name] = node
		node.size = size
		node.mode = mode
		self.add_child(node)
		grid = node
		set_process_input(true)

	return grid


func grid_remove() -> void:
	var grid: Node2D = (
		buildings[GRID.get_state().get_node_name(0)] if buildings.has(GRID.get_state().get_node_name(0)) else null
	)

	if !grid:
		return

	self.remove_child(grid)
	grid.queue_free()
	buildings.erase(GRID.get_state().get_node_name(0))
	UIManager.add_ui(UIManager.MENUS.HUD)
	set_process_input(false)


func add_build(node: Node2D, shadow_texture: CompressedTexture2D, position: Vector2i, cells: Array[Vector2i]) -> Node2D:
	if !is_instance_valid(tilemap):
		printerr("TileMap is NULL.")
		return

	if !node:
		printerr("Node is NULL.")
		return

	node.set_position(tilemap.map_to_local(position))

	var sprite: Node = node.get_node("Sprite2D")
	var shadow_node: Node2D
	if sprite && sprite is Sprite2D:
		shadow_node = self.shadow.add_shadow(shadow_texture, node.position + sprite.position)

	node.set_meta("cells", cells)
	node.set_meta("shadow", shadow_node)
	var collision: Node = node.get_node("Area2D")
	if collision && collision is Area2D:
		collision.input_pickable = true
		collision.input_event.connect(
			func(_viewport: Node, event: InputEvent, _index: int) -> void:
				var grid: Node2D = self.buildings["Grid"] if self.buildings.has("Grid") else null
				if (
					(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed)
					&& (grid && grid.mode == BuildManager.GridModes.DESTROY)
				):
					if sprite && sprite is Sprite2D:
						prefabs.add_prefab(
							PrefabContainer.PrefabType.DUST,
							node.global_position + sprite.position,
							Vector2i(sprite.texture.get_width(), sprite.texture.get_height())
						)

					remove_build(node)
		)

	#* Сначала добавляем, ибо индекс
	#* автоинкрементируемый, только
	#* потом записываем в словарь.
	self.add_child(node, true)
	buildings[node.name] = node

	return node


func remove_build(node: Node2D) -> void:
	var node_shadow: Node2D = node.get_meta("shadow")
	var node_cells: Array[Vector2i] = node.get_meta("cells")

	if !node_cells.is_empty():
		for i in node_cells:
			tilemap.erase_cell(tilemap.Layers.BUILDING, i)

	if node_shadow:
		node_shadow.queue_free()

	SoundManager.play_sound("building/destroy")
	node.queue_free()

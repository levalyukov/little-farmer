class_name FarmingManager extends Node2D

@onready var build: BuildManager = get_tree().current_scene.build
@onready var tilemap: TileMap = get_tree().current_scene.tilemap
@onready var shadow: ShadowManager = get_tree().current_scene.shadow

var plants: Dictionary
var timer: Timer

const PLANT_NODE: PackedScene = preload("res://assets/nodes/farming/plant.tscn")


func _ready() -> void:
	if !is_instance_valid(tilemap):
		printerr("TileMap is NULL.")
		return

	timer = Timer.new()
	timer.name = "GrowthTimer"
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(growth)
	self.add_child(timer)


func growth() -> void:
	if plants.is_empty():
		return

	for plant in plants:
		var data: Dictionary = plants[plant]

		if (
			!data["dead"]
			&& tilemap.get_cell_source_id(tilemap.Layers.WATERING, tilemap.local_to_map(data["position"])) == -1
		):
			if data["mortality"] + 1 < Crops.MORTALITY:
				data["mortality"] += 1
			else:
				data["dead"] = true
				#! Здесь будет потом изменение спрайтов погибших растений

			continue

		if data["has_grown"] || data["dead"]:
			continue

		if data["rate"] + 1 >= data["growth"]:
			if data["current_level"] + 1 >= data["max_level"]:
				data["rate"] = 0
				data["current_level"] = data["max_level"]
				data["has_grown"] = true
				data["node"].growed = true
				data["mortality"] = 0
				data["node"].update()
			else:
				data["rate"] = 0
				data["current_level"] += 1
				data["mortality"] = 0
				data["node"].update()
				tilemap.set_cells_terrain_connect(
					tilemap.Layers.WATERING, [tilemap.local_to_map(data["position"])], 0, -1
				)
		else:
			data["rate"] += 1


func add_plant(data: Dictionary, pos: Vector2i) -> Node2D:
	var plant: Node2D = PLANT_NODE.instantiate()
	var sprite: Node = plant.get_node("Sprite2D")

	if sprite && sprite is Sprite2D:
		sprite.region_rect.position.x = data["coords"].x
		sprite.region_rect.position.y = data["coords"].y
		sprite.region_rect.size.x = Crops.SIZE.x
		sprite.region_rect.size.y = Crops.SIZE.y

	plant.id = data["id"]
	plant.max_level = data["level"]
	plant.position = tilemap.map_to_local(pos)

	var collision: Node = plant.get_node("Area2D")
	if collision && collision is Area2D:
		collision.input_pickable = true
		collision.input_event.connect(
			func(_viewport: Node, event: InputEvent, _index: int) -> void:
				var grid: Node2D = build.buildings["Grid"] if build.buildings.has("Grid") else null
				if (
					(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed)
					&& (grid && grid.mode == BuildManager.GridModes.DESTROY)
				):
					self.remove_plant(plant)
		)

	self.add_child(plant, true)

	plants[plant.name] = {}

	#* {
	#* 		node			<- Сам узел для манипуляции со спрайтом
	#*		position		<- Позиция на тайловой карте
	#* 		max_level		<- Максимальный уровень роста
	#* 		current_level	<- Текущий уровень роста
	#* 		growth			<- Максимальное время роста для перехода на следующий этап
	#* 		rate			<- Текущее время роста
	#*		mortality		<- Счетчик до флага "погибло"
	#*		dead			<- Флаг "погибло"
	#* 		has_grown		<- Флаг "созрело"
	#* }

	plants[plant.name]["node"] = plant
	plants[plant.name]["position"] = tilemap.map_to_local(pos)
	plants[plant.name]["max_level"] = data["level"]
	plants[plant.name]["current_level"] = 0
	plants[plant.name]["growth"] = data["growth"]
	plants[plant.name]["rate"] = 0
	plants[plant.name]["mortality"] = 0
	plants[plant.name]["dead"] = false
	plants[plant.name]["has_grown"] = false

	return plant


func get_plant_by_coords(coords: Vector2i) -> Node2D:
	var node: Node2D = null

	if !plants.is_empty():
		for plant in plants:
			if plants[plant]["position"] == tilemap.map_to_local(coords):
				node = plants[plant]["node"]

	return node


func remove_plant(node: Node2D) -> void:
	if self.plants.has(node.name):
		SoundManager.play_sound("farming/plant_destroy")
		plants.erase(node.name)
		self.remove_child(node)
		node.queue_free()

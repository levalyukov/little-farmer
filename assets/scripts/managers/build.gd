class_name BuildManager extends Node

# ===================================================================
# BuildManager (build.gd)
# ===================================================================
# Центральный менеджер управления игровыми постройками
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Добавление, хранение и удаление узлов
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - build_add(id:int)
# - build_get()
# - build_remove(id:int)
#
# ЗАВИСИМОСТИ:
# - 
#
# ===================================================================

const MAX_DISTANCE: int = 250
const MAX_GRID_SIZE:Vector2i = Vector2i(16,16)
const GRID:PackedScene = preload("res://assets/nodes/buildings/grid.tscn")

enum GridModes 
{ 
	DESTROY, 
	FARMING, 
	FERTILIZER, 
	WATERING, 
	HARVESTING, 
	BUILD 
}

var buildings: Dictionary


func _input(event:InputEvent) -> void:
	if (
		((event is InputEventMouseButton) && (event.pressed) && ((event.button_index) == MOUSE_BUTTON_RIGHT))
		|| ((event.is_action_pressed("esc")) && (buildings.has(GRID.get_state().get_node_name(0))))
	):
		if buildings.has(GRID.get_state().get_node_name(0)):
			var grid: Node2D = buildings[GRID.get_state().get_node_name(0)]
			if grid:
				self.remove_child(grid)
				grid.queue_free()
				buildings.erase(GRID.get_state().get_node_name(0))
				UIManager.ui_add(UIManager.MENUS.HUD)


func grid_add(mode: BuildManager.GridModes, size: Vector2i = Vector2i(1,1)) -> Node2D:
	var grid:Node2D = null

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

	return grid


func build_add(node:Node2D, position:Vector2i) -> void:
	if !node:
		printerr("Node is null.")
		return

	buildings[node.name] = node
	print(buildings)
	# node.position = position


func build_remove(node:Node2D) -> bool:
	var flag:bool = false

	return flag

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

@export var tilemap: TileMap

const MAX_DISTANCE: int = 250
const GRID: PackedScene = preload("res://assets/nodes/buildings/grid.tscn")

enum GridModes 
{ 
	DESTROY, 
	FARMING, 
	FERTILIZER, 
	WATERING, 
	HARVESTING, 
	BUILD 
}

var buildings: Dictionary = {}


func _input(event) -> void:
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


func grid_add(mode: GridModes) -> void:
	if !(buildings.has(GRID.get_state().get_node_name(0))):
		var node = GRID.instantiate()
		buildings[node.name] = node
		self.add_child(node)
		node.mode = mode


func build_add(_id: int) -> void:
	pass
	# var building = BlueprintManager.CONTENT["buildings"][id]

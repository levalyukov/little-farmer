class_name BuildManager extends Node

@export var tilemap:TileMap

const MAX_DISTANCE:int = 250
const GRID:PackedScene = preload("res://assets/nodes/grid.tscn")

enum GRID_MODES \
{
    DESTROY,
    FARMING,
    FERTILIZER,
    WATERING,
    HARVESTING,
    BUILD
}

var buildings:Dictionary = {}

func _input(event):
    if event is InputEventMouseButton && event.pressed\
    && event.button_index == MOUSE_BUTTON_RIGHT\
    && buildings.has(GRID.get_state().get_node_name(0)):
        if buildings.has(GRID.get_state().get_node_name(0)):
            var grid:Node2D = buildings[GRID.get_state().get_node_name(0)]
            if grid:
                self.remove_child(grid)
                grid.queue_free()
                buildings.erase(GRID.get_state().get_node_name(0))
                UIManager.ui_add(UIManager.MENUS.HUD)

func grid_add(mode:GRID_MODES) -> void:
    if !buildings.has(GRID.get_state().get_node_name(0)):
        var node = GRID.instantiate()
        buildings[node.name] = node
        self.add_child(node)
        node.mode = mode

func build_add(_id:int) -> void: 
    pass
    # var building = BlueprintManager.CONTENT["buildings"][id]


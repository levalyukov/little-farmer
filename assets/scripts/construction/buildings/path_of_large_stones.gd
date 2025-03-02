extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D
var blueprint_id:int = 0
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var object:Dictionary = {
    'idle' = load('res://assets/resources/buildings/path_of_large_stones/object_0.png'),
    'delete' = load('res://assets/resources/buildings/path_of_large_stones/object_1.png')
}

func _ready():
    if self:
        if blueprint_id == 0:
            var shadow = load("res://assets/resources/buildings/path_of_large_stones/shadow.png")
            if shadow:
                if shadow is CompressedTexture2D:
                    canvas.create_shadow("path_of_large_stones_shadow", shadow, tilemap.local_to_map(self.position))

func get_data() -> Dictionary:
    return {
        "position": tilemap.local_to_map(self.position),
        "id": blueprint_id
    }

func _input(event):
    if event is InputEventMouseButton\
    && event.button_index == MOUSE_BUTTON_LEFT\
    && event.is_pressed()\
    && !blur.state\
    && destroyMode\
    && buttonDestroy.destroyMode:
        buildings.remove_node(self, all_collisions)

func _on_area_2d_mouse_exited():
    if destroyMode:
        destroyMode = !true
    if object.has('idle'):
        if object['idle'] is CompressedTexture2D:
            sprite.texture = object['idle']

func _on_area_2d_mouse_entered():
    if !blur.state\
    && grid.mode == grid.modes.NOTHING\
    && buttonDestroy.destroyMode:
        destroyMode = true
        if object.has('delete'):
            if object['delete'] is CompressedTexture2D:
                sprite.texture = object['delete']

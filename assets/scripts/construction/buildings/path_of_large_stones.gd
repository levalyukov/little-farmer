extends Node2D

@onready var main:String = GameData.main
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
var blueprint_id:int = 0

func _ready():
    if self:
        if blueprint_id == 0:
            var shadow = load("res://assets/resources/buildings/path_of_large_stones/shadow.png")
            if shadow:
                if shadow is CompressedTexture2D:
                    canvas.create_shadow("path_of_large_stones_shadow", shadow, tilemap.local_to_map(self.position))
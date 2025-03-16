extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D
@onready var shadow_sprite:CompressedTexture2D = load("res://assets/resources/buildings/fountan/shadow.png")

func _ready() -> void:
	if self:
		if shadow_sprite:
			if shadow_sprite is CompressedTexture2D:
				var vector2i_position = tilemap.local_to_map(position)
				var target_position = Vector2i(vector2i_position.x, vector2i_position.y)
				canvas.create_shadow("fountan_shadow", shadow_sprite, target_position)

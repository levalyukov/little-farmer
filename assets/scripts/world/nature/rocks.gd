extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D
@export var index:int = 1

func _ready():
	if self:
		var target_sprite = load("res://assets/resources/world/stones/stone_"+str(index)+".png")
		var shadow_sprite = load("res://assets/resources/world/stones/shadows/shadow_"+str(index)+".png")
		if target_sprite:
			if target_sprite is CompressedTexture2D:
				sprite.texture = target_sprite
				if shadow_sprite:
					if shadow_sprite is CompressedTexture2D:
						canvas.create_shadow(
							"stone_"+str(index)+"_shadow", 
							shadow_sprite, 
							tilemap.local_to_map(self.position)
						)

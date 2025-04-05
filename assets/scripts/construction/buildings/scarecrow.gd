extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D

func _ready() -> void:
	if self:
		if clock:
			match clock.get_season():
				'spring':
					var target_sprite:CompressedTexture2D = load("res://assets/resources/buildings/scarecrow/obj_1.png")
					var shadow_sprite:CompressedTexture2D = load("res://assets/resources/buildings/scarecrow/shadow_1.png")
					sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("scarecrow_shadow", shadow_sprite, tilemap.local_to_map(position))
				'summer':
					var target_sprite:CompressedTexture2D = load("res://assets/resources/buildings/scarecrow/obj_0.png")
					var shadow_sprite:CompressedTexture2D = load("res://assets/resources/buildings/scarecrow/shadow_2.png")
					sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("scarecrow_shadow", shadow_sprite, tilemap.local_to_map(position))
				'autumn':
					var target_sprite:CompressedTexture2D = load("res://assets/resources/buildings/scarecrow/obj_2.png")
					var shadow_sprite:CompressedTexture2D = load("res://assets/resources/buildings/scarecrow/shadow_3.png")
					sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("scarecrow_shadow", shadow_sprite, tilemap.local_to_map(position))
				'winter':
					if self.visible:
						self.visible = false
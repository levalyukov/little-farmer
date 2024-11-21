extends Node2D

@onready var sprite:Sprite2D = $Sprite2D

func set_texture(target_sprite:CompressedTexture2D) -> void:
	sprite.texture = target_sprite
	print(target_sprite)
extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D
@onready var shadow_sprite:CompressedTexture2D = load("res://assets/resources/buildings/fountan/shadow.png")
@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	if self:
		if clock:
			match clock.get_season():
				'spring':
					var target_sprite = load('res://assets/resources/buildings/fountan/obj_2.png')
					if target_sprite:
						sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("fountan_shadow", shadow_sprite, tilemap.local_to_map(position))
					if audio:
						if audio.is_playing():
							audio.stop()
				'summer':
					var target_sprite = load('res://assets/resources/buildings/fountan/obj_0.png')
					if target_sprite:
						sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("fountan_shadow", shadow_sprite, tilemap.local_to_map(position))
				'autumn':
					var target_sprite = load('res://assets/resources/buildings/fountan/obj_0.png')
					if target_sprite:
						sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("fountan_shadow", shadow_sprite, tilemap.local_to_map(position))
				'winter':
					var target_sprite = load('res://assets/resources/buildings/fountan/obj_1.png')
					if target_sprite:
						sprite.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("fountan_shadow", shadow_sprite, tilemap.local_to_map(position))
					if audio:
						if audio.is_playing():
							audio.stop()

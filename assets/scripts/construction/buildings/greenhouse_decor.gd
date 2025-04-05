extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var audio:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shadow_sprite:CompressedTexture2D = load("res://assets/resources/buildings/greenhouse/level_1/shadow.png")

func _ready() -> void:
	if self:
		if clock:
			match clock.get_season():
				'spring':
					var target_sprite = load('res://assets/resources/buildings/greenhouse/level_1/spring/object_0.png')
					if target_sprite:
						self.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("greenhouse_decor_shadow", shadow_sprite, Vector2i(tilemap.local_to_map(position).x, tilemap.local_to_map(position).y+1))
					if audio:
						if audio.is_playing():
							audio.stop()
				'summer':
					var target_sprite = load('res://assets/resources/buildings/greenhouse/level_1/summer/object_0.png')
					if target_sprite:
						self.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("greenhouse_decor_shadow", shadow_sprite, Vector2i(tilemap.local_to_map(position).x, tilemap.local_to_map(position).y+1))
				'autumn':
					var target_sprite = load('res://assets/resources/buildings/greenhouse/level_1/autumn/object_0.png')
					if target_sprite:
						self.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("greenhouse_decor_shadow", shadow_sprite, Vector2i(tilemap.local_to_map(position).x, tilemap.local_to_map(position).y+1))
				'winter':
					var target_sprite = load('res://assets/resources/buildings/greenhouse/level_1/winter/object_0.png')
					if target_sprite:
						self.texture = target_sprite
					if shadow_sprite:
						if shadow_sprite is CompressedTexture2D:
							canvas.create_shadow("greenhouse_decor_shadow", shadow_sprite, Vector2i(tilemap.local_to_map(position).x, tilemap.local_to_map(position).y+1))
					if audio:
						if audio.is_playing():
							audio.stop()

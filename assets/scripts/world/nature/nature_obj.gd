extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var sprite:Sprite2D = $Sprite2D

var type:String = ""
var health:int = 1
var index:int = 0

func set_texture(target_sprite:CompressedTexture2D, texture_index:int = 0) -> void:
	sprite.texture = target_sprite
	index = texture_index
	type = data.remove_suffix(self.name)
	set_health()

func change_texture(target_sprite:CompressedTexture2D) -> void:
	sprite.texture = target_sprite

func set_health():
	match data.remove_suffix(self.name):
		"weed":
			health = 1
		"tree":
			health = 3
		"stone":
			health = 2
		_:
			health = 1

func get_data():
	return {
		"type": type,
		"sprite_index": index,
		"position": tilemap.local_to_map(global_position),
		"health": health,
	}

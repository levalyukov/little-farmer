extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var sprite:Sprite2D = $Sprite2D

var health:int = 1

func set_texture(target_sprite:CompressedTexture2D) -> void:
	sprite.texture = target_sprite
	set_health()

func set_health():
	match data.remove_suffix(self.name):
		"weed":
			health = 1
		"tree":
			health = 3
		"stone":
			health = 2
		_:
			pass

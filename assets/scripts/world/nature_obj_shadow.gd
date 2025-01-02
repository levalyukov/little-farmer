extends Sprite2D

var index:int
var type:String

func set_sprite(sprite:CompressedTexture2D, id:int, node_type:String) -> void:
	self.texture = sprite
	index = id
	type = node_type

func change_sprite(sprite:CompressedTexture2D) -> void:
	texture = sprite

func is_nature_shadow() -> bool:
	return true
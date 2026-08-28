class_name ShadowManager extends CanvasGroup

const MODULATE: Color = Color(0, 0, 0)
const SELF_MODULATE: Color = Color(0, 0, 0, 0.2)
const OFFSET: int = 8


func _ready() -> void:
	self.z_index = 1
	self.modulate = MODULATE
	self.self_modulate = SELF_MODULATE


func shadow_add(texture: CompressedTexture2D, pos: Vector2i) -> Sprite2D:
	if !texture:
		printerr("Texture is NULL.")
		return

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.set_position(pos)
	self.add_child(sprite)

	return sprite

extends Sprite2D

@export var speed:float = 18.0
@export var direction:Vector2i = Vector2i(1,1)

func _process(delta: float) -> void:
    self.position.x += direction.x * delta * speed
    self.position.y += direction.y * delta * speed
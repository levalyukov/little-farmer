extends Sprite2D

@export var region_offset: Array[Vector2i]


func update(season: WorldCycle.Season) -> void:
	if self.region_offset[season].x == -2147483648 || self.region_offset[season].y == -2147483648:
		self.visible = false
		return

	self.region_rect.position.x = region_offset[season].x * self.region_rect.size.x
	self.region_rect.position.y = region_offset[season].y * self.region_rect.size.y

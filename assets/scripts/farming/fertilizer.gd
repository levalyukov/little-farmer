extends Node2D

@onready var sprite:Sprite2D = $Sprite2D

var items:Object = Items.new()
var id:int

func set_fertilizer(fertilizerId:int) -> void:
	id = fertilizerId
	match fertilizerId:
		61:
			sprite.set_rect(0, 0)
		62:
			sprite.set_rect(16, 0)
		_:
			pass

func get_data() -> Dictionary:
	return {
		"fertilizerID": id,
	}
			
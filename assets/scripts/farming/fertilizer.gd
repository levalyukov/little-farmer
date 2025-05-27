extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var sprite:Sprite2D = $Sprite2D

var _id:int = 0
var _percent:int = 0

func set_fertilizer(_fertilizer_id:int, _fertilizer_percent:int) -> void:
	_id = _fertilizer_id
	_percent = _fertilizer_percent
	match _id:
		61:
			sprite.region_rect.position.x = 0
			sprite.region_rect.position.y = 0
		62:
			sprite.region_rect.position.x = 16
			sprite.region_rect.position.y = 0
		_:
			pass
	
func get_data() -> Dictionary:
	return {
		"id": _id,
		"percent": _percent,
		"region_rect.x": sprite.region_rect.position.x,
		"region_rect.y": sprite.region_rect.position.y,
		"position": tilemap.local_to_map(global_position),
	}

func set_data(
		_fertilizer_id:int,
		_fertilizer_percent:int, 
		_region_rect_x:int, 
		_region_rect_y:int, 
		_position:Vector2i,
		_caption:String,
	) -> void:
	_id = _fertilizer_id
	sprite.region_rect.position.x = _region_rect_x
	sprite.region_rect.position.y = _region_rect_y
	self.name = _caption
	set_position(tilemap.map_to_local(_position))
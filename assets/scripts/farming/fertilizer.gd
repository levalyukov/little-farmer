extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var sprite:Sprite2D = $Sprite2D

var items:Object = Items.new()
var id:int

func set_fertilizer(fertilizerId:int) -> void:
	id = fertilizerId
	match fertilizerId:
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
		"fertilizerID": id,
		"region_rect.x": sprite.region_rect.position.x,
		"region_rect.y": sprite.region_rect.position.y,
		"position": tilemap.local_to_map(global_position),
	}

func set_data(
		fertilizerID:int, 
		region_rect_x:int, 
		region_rect_y:int, 
		vector:Vector2i,
		caption:String,
	) -> void:
	id = fertilizerID
	sprite.region_rect.position.x = region_rect_x
	sprite.region_rect.position.y = region_rect_y
	self.name = caption
	set_position(tilemap.map_to_local(vector))
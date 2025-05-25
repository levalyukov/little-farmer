extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var plant = $".."

func set_rect(rect_y:int) -> void:
	region_rect.position.x = 0
	region_rect.position.y = rect_y
extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var plant = $".."
@onready var timer:Timer = $"../Timer"

var crops:Object = Crops.new()
var level:int = 0

#	func _ready():
#		if crops.crops.has("atlas"):
#			if crops.crops["atlas"] is CompressedTexture2D:
#				texture = texture
		
func rect(plant_rect_x:int, plant_rect_y:int) -> void:
	region_rect.position.x = plant_rect_x
	region_rect.position.y = plant_rect_y

func set_rect(x:int, y:int, timerIsStopped:bool = false) -> void:
	region_rect.position.x = x
	region_rect.position.y = y
	if timerIsStopped\
	&& !timer.is_stopped():
		timer.stop()

func _on_timer_timeout() -> void:
	if !pause.paused:
		region_rect.position.x += 16
		level += 1
		if level == plant.plant_growth_level_max:
			plant_increased()
		else:
			plant.check_water(
				tilemap.local_to_map(self.global_position)
			)
			
func plant_increased():
	plant.condition = plant.phases.growed
	plant.degree = 0
	plant.timer.stop()
	plant.check_water_timer.stop()
	plant.tilemap.set_cells_terrain_connect(
		plant.collision.watering_layer,
		[tilemap.local_to_map(self.global_position)],
		0,
		-1
	)

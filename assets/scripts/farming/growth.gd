extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var plant = $".."
@onready var timer:Timer = $"../Timer"

var crops:Object = Crops.new()
var level:int

func _ready():
	if crops.crops.has("atlas"):
		if crops.crops["atlas"] is CompressedTexture2D:
			texture = texture
		else:
			data.debug("Atlas is not a CompressedTexture2D.", "error")
	else:
		data.debug("No atlas of crops.", "fatal")

func _process(_delta):
	if plant.plantID != 0:
		if level == crops.crops[plant.plantID]["growth_level"]\
		&& plant.condition != plant.phases.growed:
			plant_increased()
	else:
		data.debug("Invalid variable index: " + str(plant.plantID), "error")
		remove_child(plant)
		queue_free()
		
func rect(id) -> void:
	if crops.crops[id].has("X")\
	&& crops.crops[id].has("Y"):
		region_rect.position.x = crops.crops[id]['X']
		region_rect.position.y = crops.crops[id]['Y']
	else:
		data.debug("The X and Y coordinates cannot be determined.", "error")

func set_rect(x:int, y:int, timerIsStopped:bool = false) -> void:
	region_rect.position.x = x
	region_rect.position.y = y
	if timerIsStopped\
	&& !timer.is_stopped():
		timer.stop()

func _on_timer_timeout() -> void:
	if !pause.paused:
		if level < crops.crops[plant.plantID]["growth_level"]:
			region_rect.position.x += 16
			level += 1
			plant.check_water(tilemap.local_to_map(self.global_position))
		else:
			plant_increased()

func plant_increased():
	plant.condition = plant.phases.growed
	timer.stop()

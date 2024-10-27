extends Timer

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
const sprite_max:int = 20
const sprite_min:int = 0

var clouds:Array[CompressedTexture2D] = []
var sprite_value:int = 0
var spawn_clouds_time_max:float = 5
var spawn_clouds_time_min:float = 0.25

func _ready() -> void:
	while clouds.size() < sprite_max:
		sprite_value += 1
		clouds.append(load("res://assets/resources/world/clouds/cloud_"+str(sprite_value)+".png"))

func _on_timeout():
	if clouds != []:
		if has_node("/root/"+main+"/ShadowManager/CanvasGroup"):
			var random_sprite = randi() % clouds.size()
			canvas.create_cloud(clouds[random_sprite])
			wait_time = randi_range(spawn_clouds_time_min*clock.speed, spawn_clouds_time_max*clock.speed)
		else:
			data.debug("The 'CanvasGroup' node is missing.", "error")

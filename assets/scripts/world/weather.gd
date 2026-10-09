class_name WeatherManager extends Node2D

@onready var tilemap:TileMap = get_tree().current_scene.tilemap
@onready var canvas:CanvasGroup = $CanvasGroup

const WAIT_TIME:Array[float] = [0.25, 1.5]
const CLOUDS_SCRIPT:GDScript = preload("res://assets/scripts/world/cloud.gd")
const CLOUDS_COORDS:Array[Vector2i] = [Vector2i(-40,-40), Vector2i(79,51)]
const CLOUDS_TEXTURES:Array[CompressedTexture2D] = \
[
	preload("res://assets/resources/world/clouds/cloud_0.png"),
	preload("res://assets/resources/world/clouds/cloud_1.png"),
	preload("res://assets/resources/world/clouds/cloud_2.png"),
	preload("res://assets/resources/world/clouds/cloud_3.png"),
	preload("res://assets/resources/world/clouds/cloud_4.png"),
	preload("res://assets/resources/world/clouds/cloud_5.png"),
	preload("res://assets/resources/world/clouds/cloud_6.png"),
	preload("res://assets/resources/world/clouds/cloud_7.png"),
	preload("res://assets/resources/world/clouds/cloud_8.png"),
	preload("res://assets/resources/world/clouds/cloud_9.png"),
	preload("res://assets/resources/world/clouds/cloud_10.png"),
	preload("res://assets/resources/world/clouds/cloud_12.png"),
	preload("res://assets/resources/world/clouds/cloud_13.png"),
	preload("res://assets/resources/world/clouds/cloud_14.png"),
	preload("res://assets/resources/world/clouds/cloud_15.png"),
	preload("res://assets/resources/world/clouds/cloud_16.png"),
	preload("res://assets/resources/world/clouds/cloud_17.png"),
	preload("res://assets/resources/world/clouds/cloud_18.png"),
	preload("res://assets/resources/world/clouds/cloud_19.png"),
	preload("res://assets/resources/world/clouds/cloud_20.png")
] 

var process:Timer = null
var spawner:Timer = null
var clouds:Dictionary = {}

func _ready() -> void:
	if !canvas:
		printerr("CanvasGroup is NULL.")
		return

	spawner = Timer.new()
	spawner.autostart = true
	spawner.wait_time = WAIT_TIME[0]
	spawner.timeout.connect(cloud_spawn)
	self.add_child(spawner)

	process = Timer.new()
	process.autostart = true
	process.wait_time = 1.0
	process.timeout.connect(update)
	self.add_child(process)

	canvas.self_modulate = Color(0,0,0,0.2)
	
func update() -> void:
	if clouds.is_empty():
		return

	for cloud in clouds:
		if clouds[cloud]["lifetime"] - 1 > 1:
			clouds[cloud]["lifetime"] -= 1
		else:
			clouds[cloud]["node"].queue_free()
			clouds.erase(cloud)

func cloud_spawn() -> void:
	spawner.wait_time = randf_range(WAIT_TIME[0], WAIT_TIME[1])
	var node:Sprite2D = _cloud()

	if !node:
		return

	canvas.add_child(node, true)
	clouds[node.name] = {}
	clouds[node.name]["node"] = node
	clouds[node.name]["lifetime"] = randi_range(30, 120)

# * 
func _cloud() -> Sprite2D:
	var sprite:Sprite2D = Sprite2D.new()
	var texture:CompressedTexture2D = CLOUDS_TEXTURES[randi() % CLOUDS_TEXTURES.size()]
	var current_position:Vector2 = tilemap.map_to_local(
		Vector2(
			randi_range(CLOUDS_COORDS[0].x, CLOUDS_COORDS[1].x),
			randi_range(CLOUDS_COORDS[0].y, CLOUDS_COORDS[1].y)
		)
	)

	sprite.texture = texture
	sprite.set_position(current_position)
	sprite.set_script(CLOUDS_SCRIPT)

	return sprite

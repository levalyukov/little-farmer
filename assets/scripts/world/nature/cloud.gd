extends Sprite2D

@onready var main:String = GameData.main
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var anim:AnimationPlayer = $Animation
@onready var life:Timer = $LifeCycle

const max_distance:int = 750

func _ready():
	life.wait_time = randi_range(2*clock.speed,10*clock.speed)
	life.start()

func _process(delta) -> void:
	if !pause.paused:
		position.x += canvas.vector_x * delta
		position.y += canvas.vector_y * delta
		var distance = round(global_position.distance_to(player.global_position))
		if distance > max_distance:
			change_animation(false)

func change_animation(state:bool) -> void:
	if state:
		anim.play("create")
	else:
		anim.play("remove")

func _on_life_cycle_timeout() -> void:
	change_animation(false)

func _life_cycle_end() -> void:
	canvas.clouds_value -= 1
	life.stop()
	queue_free()

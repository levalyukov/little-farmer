extends Control

@onready var background:ColorRect = $ColorRect
@onready var anim:AnimationPlayer = $Animation

func _ready():
	z_index = 999
	background.modulate = "ffffff"

func blackout(state:bool, speed:float = 0.5) -> void:
	match state:
		true:
			anim.play("blackout")
			anim.speed_scale = speed
			
		false:
			anim.play("blackout_reset")
			anim.speed_scale = speed

func change_color(colouring:Color, default_clear_color:bool = false):
	if typeof(colouring) == TYPE_COLOR:
		background.color = colouring
		if default_clear_color:
			RenderingServer.set_default_clear_color(colouring)

func change_scene(_path:String, _value:float = 1.25) -> void:
	if _path != "":
		await get_tree().create_timer(_value).timeout
		get_tree().change_scene_to_file(_path)
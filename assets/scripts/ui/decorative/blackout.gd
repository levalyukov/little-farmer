extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var background:ColorRect = $ColorRect
@onready var anim:AnimationPlayer = $Animation

var blackouted:bool = false

func _ready():
	z_index = 999
	background.modulate = "ffffff"

func blackout(state:bool, speed:int = 4) -> void:
	match state:
		true:
			anim.play("blackout")
			anim.speed_scale = speed
			blackouted = true
		false:
			anim.play("blackout_reset")
			anim.speed_scale = speed
			blackouted = false

func change_color(colouring:Color, default_clear_color:bool = false):
	if typeof(colouring) == TYPE_COLOR:
		background.color = colouring
		if default_clear_color:
			RenderingServer.set_default_clear_color(colouring)
	else:
		if data.has_method("debug"):
			data.debug("The variable 'coloring' is not a type of 'Color'.", "error")

func change_scene(path:String) -> bool:
	if path != "":
		await get_tree().create_timer(1.25).timeout
		var result = get_tree().change_scene_to_file(path)
		
		if result == OK:
			return true
		else:
			match result:
				ERR_CANT_OPEN:
					if data.has_method("debug"):
						data.debug("Can't open the scene file.", "error")
				ERR_FILE_NOT_FOUND:
						data.debug("Scene file not found.", "error")
				ERR_INVALID_DATA:
					if data.has_method("debug"):
						data.debug("Invalid scene file format.", "error")
				ERR_FILE_CORRUPT:
					if data.has_method("debug"):
						data.debug("Scene file is corrupt.", "error")
				ERR_UNAVAILABLE:
					if data.has_method("debug"):
						data.debug("The scene is unavailable.", "error")
				_:
					if data.has_method("debug"):
						data.debug("An unknown error occurred: " + str(result), "error")
	return false

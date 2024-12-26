extends Camera2D

@onready var main_scene = str(get_tree().root.get_child(1).name)
@onready var pause = get_node("/root/" + main_scene + "/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/" + main_scene + "/UI/Decorative/Blur")

const zoom_min:float = 2.0
const zoom_max:float = 10.0
const speed:float = 6.0
const tolerance:float = 0.01

var current:float = 3.5
var increment:float = 1.0 
var target:float = 3.0

var zooming:bool = true
var change_zoom:bool = false

func _process(delta):
	if !pause.paused:
		if !zooming:
			if !pause.other_menu:
				if Input.is_action_just_released("zoom_in"):
					if current < zoom_max:
						target = min(current + increment, zoom_max)
						change_zoom = true
				if Input.is_action_just_released("zoom_out"):
					if current > zoom_min:
						target = max(current - increment, zoom_min)
						change_zoom = true			
			current = lerp(current, target, speed * delta)
			if abs(current - target) < tolerance:
				current = target
				change_zoom = false
			set_zoom(Vector2(current, current))

extends Control

@onready var background:ColorRect = $ColorRect

const MAX:float = 1.0
const MIN:float = 0.0
const SPEED:float = 0.001
const EPSILON:float = 0.0001

var value:float = 0.0
var state:bool = false
var reverse:bool = false

func _ready():
	z_index = 999

func _process(_delta):
	if state: 
		value = min(value + SPEED, MAX)
	else: 
		value = max(value - SPEED, MIN)

	if state && abs(value - MAX) < EPSILON:
		set_process(false)
	elif !state && abs(value - MIN) < EPSILON:
		set_process(false)
	background.material.set_shader_parameter("progress", value)

func blackout(_state:bool, _start_value:float = 0.0, _reversed:bool = false) -> void:
	value = _start_value
	state = _state
	reverse = _reversed
	background.material.set_shader_parameter("progress", value)
	background.material.set_shader_parameter("fill", _reversed)
	set_process(true)

func change_scene(_path:String, _time_to_change:float = 1.25) -> void:
	if _path != "":
		await get_tree().create_timer(_time_to_change).timeout
		get_tree().change_scene_to_file(_path)

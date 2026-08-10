class_name BlurEffect extends Control

@onready var background: ColorRect = $ColorRect

const MAX: float = 1.0
const MIN: float = 0.0
const SPEED: float = 0.2
const EPSILON: float = 0.001

var value: float = 0
var state: bool = false


func _process(_delta):
	value = min(value + SPEED, MAX) if state else max(value - SPEED, MIN)
	background.material.set_shader_parameter("lod", value)

	if state && abs(value - MAX) < EPSILON:
		set_process(false)

	elif !state && abs(value - MIN) < EPSILON:
		visible = false
		set_process(false)


func blur(bluring: bool) -> void:
	set_process(true)
	state = bluring
	if bluring:
		visible = state

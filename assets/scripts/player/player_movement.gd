extends CharacterBody2D

const SMOOTHING_SPEED:int = 5
const SPEED:int = 150
const THRESHOLD:int = 50

var direction:Vector2 = Vector2.ZERO
var switch:bool = true

var mouseMovement:bool = true
var mouseOutside:bool = true

func _ready():
	if mouseMovement:
		get_viewport().connect("mouse_entered", Callable(self, "_mouse_enter").bind())
		get_viewport().connect("mouse_exited", Callable(self, "_mouse_exit").bind())

func _process(_delta):
	if !mouseMovement:
		direction = Input.get_vector("a", "d", "w", "s")
		if direction != Vector2.ZERO\
		&& !switch:
			$Camera2D.position_smoothing_speed = SMOOTHING_SPEED

func check_switch() -> void:
	if switch:
		$Camera2D.position_smoothing_speed = 0
	else: 
		$Camera2D.position_smoothing_speed = SMOOTHING_SPEED
		
func _physics_process(_delta):
	if !switch:
		if !mouseMovement:
			velocity = direction * SPEED
		
		if mouseMovement:
			if !mouseOutside:
				var _viewport_size = get_viewport_rect().size
				var _mouse_position = get_viewport().get_mouse_position()

				direction = Vector2i.ZERO

				var center_threshold = THRESHOLD * 2.5
				var center_x = _viewport_size.x / 2
				var center_y = _viewport_size.y / 2

				if !(_mouse_position.x > center_x - center_threshold\
				&& _mouse_position.x < center_x + center_threshold\
				&& _mouse_position.y > center_y - center_threshold\
				&& _mouse_position.y < center_y + center_threshold):
					if _mouse_position.x > _viewport_size.x - THRESHOLD: direction.x = 1
					if _mouse_position.x < THRESHOLD: direction.x = -1
					if _mouse_position.y < THRESHOLD: direction.y = -1
					if _mouse_position.y > _viewport_size.y - THRESHOLD: direction.y = 1

				velocity = direction * SPEED
			else:
				velocity = Vector2i.ZERO
		move_and_slide()

func _mouse_enter() -> void:
	mouseOutside = false

func _mouse_exit() -> void:
	mouseOutside = true
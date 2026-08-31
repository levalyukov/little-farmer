extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D

const MOVEMENT_SPEED: int = 150
const THRESHOLD: int = 50

const CAMERA_MIN: float = 2.0
const CAMERA_MAX: float = 10.0
const CAMERA_SPEED: float = 7.5
const CAMERA_TOLERANCE: float = 0.01
const CAMERA_INCREMENT: float = 1.0
const CAMERA_SMOOTHING_SPEED: int = 5

var current_zoom: float = 3.5
var target_zoom: float = 3.0
var is_changing_zoom: bool = false
var zooming_flag: bool = false

var direction: Vector2 = Vector2.ZERO
var stop_flag: bool = false
var mouse_outside: bool = true


func _ready() -> void:
	get_viewport().mouse_entered.connect(func() -> void: mouse_outside = false)
	get_viewport().mouse_exited.connect(func() -> void: mouse_outside = true)

	if !UIManager || !Settings:
		set_process(false)
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	if camera && Settings.movement_type:
		direction = Input.get_vector("left", "right", "up", "down")
		if !stop_flag && direction != Vector2.ZERO:
			camera.position_smoothing_speed = CAMERA_SMOOTHING_SPEED

		handle_zoom(delta)

	if !UIManager.blur.state && !stop_flag:
		if Settings.movement_type:
			velocity = direction * MOVEMENT_SPEED

		if !Settings.movement_type:
			if !mouse_outside:
				var viewport_size: Vector2 = get_viewport_rect().size
				var mouse_position: Vector2 = get_viewport().get_mouse_position()
				var center_threshold: float = THRESHOLD * 2.5
				var center: Vector2 = Vector2(viewport_size.x / 2, viewport_size.y / 2)

				direction = Vector2i.ZERO
				if !(
					mouse_position.x > center.x - center_threshold
					&& mouse_position.x < center.x + center_threshold
					&& mouse_position.y > center.y - center_threshold
					&& mouse_position.y < center.y + center_threshold
				):
					if mouse_position.x > viewport_size.x - THRESHOLD:
						direction.x = 1
					if mouse_position.x < THRESHOLD:
						direction.x = -1
					if mouse_position.y < THRESHOLD:
						direction.y = -1
					if mouse_position.y > viewport_size.y - THRESHOLD:
						direction.y = 1

				velocity = direction * MOVEMENT_SPEED
			else:
				velocity = Vector2i.ZERO

		move_and_slide()


func handle_zoom(delta: float) -> void:
	if !UIManager.blur.state && !zooming_flag:
		if Input.is_action_just_released("mwu"):
			if current_zoom < CAMERA_MAX:
				target_zoom = min(current_zoom + CAMERA_INCREMENT, CAMERA_MAX)
				is_changing_zoom = true
				SoundManager.play_sound("ui/zoom")

		if Input.is_action_just_released("mwd"):
			if current_zoom > CAMERA_MIN:
				target_zoom = max(current_zoom - CAMERA_INCREMENT, CAMERA_MIN)
				is_changing_zoom = true
				SoundManager.play_sound("ui/zoom")

	if is_changing_zoom:
		current_zoom = lerp(current_zoom, target_zoom, CAMERA_SPEED * delta)
		if abs(current_zoom - target_zoom) < CAMERA_TOLERANCE:
			current_zoom = target_zoom
			is_changing_zoom = false

	camera.set_zoom(Vector2(current_zoom, current_zoom))

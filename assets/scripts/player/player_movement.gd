extends CharacterBody2D

const camera_speed:int = 5
const speed:int = 150
var direction:Vector2 = Vector2.ZERO
var switch:bool = true

func _process(_delta):
	direction = Input.get_vector("a", "d", "w", "s")
	if direction != Vector2.ZERO\
	&& !switch:
		$Camera2D.position_smoothing_speed = camera_speed
	
func check_switch() -> void:
	if switch:
		$Camera2D.position_smoothing_speed = 0
	else: 
		$Camera2D.position_smoothing_speed = camera_speed
		
func _physics_process(_delta):
	if !switch:
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

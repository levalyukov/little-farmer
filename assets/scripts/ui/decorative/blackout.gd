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
			self.mouse_filter = MOUSE_FILTER_STOP
			
		false:
			anim.play("blackout_reset")
			anim.speed_scale = speed
			self.mouse_filter = MOUSE_FILTER_IGNORE
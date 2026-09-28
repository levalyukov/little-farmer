extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D


func _ready() -> void:
	if !particles:
		printerr("CPUParticles2D is NULL.")
		return

	particles.emitting = true
	particles.finished.connect(func() -> void: self.queue_free())

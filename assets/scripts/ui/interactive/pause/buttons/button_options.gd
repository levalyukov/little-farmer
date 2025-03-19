extends Button

@onready var main_scene = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/" + main_scene + "/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/" + main_scene + "/UI/Interactive/Pause")
@onready var options:Control = get_node("/root/" + main_scene + "/UI/Interactive/Options")
@onready var player:CharacterBody2D = get_node("/root/" + main_scene + "/Camera")

func _on_pressed() -> void:
	if blur.state:
		if pause.paused:
			options.open()
			pause.visible = false
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_mouse_entered():
	if blur.state:
		if pause.paused:
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/hover.ogg')
			audio.play()
			
func _on_audio_finished(node) -> void:
	node.queue_free()
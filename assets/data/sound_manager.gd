extends Node

func play_sound(volume:String) -> void:
	var audio:AudioStreamPlayer = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.finished.connect(_audio_is_finished.bind(audio))
	audio.stream = load("res://assets/sounds/"+volume+".ogg")
	audio.play()

func _audio_is_finished(audio:AudioStreamPlayer) -> void:
	if !is_instance_valid(audio):
		return

	self.remove_child(audio)
	audio.queue_free()
extends Node

# ===================================================================
# SoundsManager (sounds.gd)
# ===================================================================
# Центральный синглтон отвечающий за воспроизведение игровых звуков
# и игровой музыки по заданном расписанию.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Воспроизведение музыки и игровых звуков
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - play_sound(volume:String) - воспроизвести звук из папки "sounds"
#
# ЗАВИСИМОСТИ:
# - AudioStreamPlayer - воспроизведение звуков
#
# ===================================================================

func play_sound(volume:String) -> void:
	var path:String
	var audio:AudioStreamPlayer

	path = "res://assets/sounds/"+volume+".ogg" if !volume.ends_with(".ogg")\
	else "res://assets/sounds/"+volume

	audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.finished.connect(_audio_is_finished.bind(audio))
	audio.stream = load(path)
	audio.play()

func _audio_is_finished(audio:AudioStreamPlayer) -> void:
	self.remove_child(audio)
	audio.queue_free()
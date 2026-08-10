extends AudioStreamPlayer

# =============================================================================================
#  (script.gd)
# =============================================================================================
# Описание скрипта
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# -
# -
# -
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# -
# -
# -
#
# =============================================================================================

const PLAYLIST: Array[String] = ["res://assets/sounds/music/flp/spring/music#1.ogg"]

var cooldown: Timer = Timer.new()


func music_init() -> void:
	self.bus = "Music"
	self.add_child(cooldown)
	music_play()


func music_play() -> void:
	if self.playing:
		self.stop()

	self.stream = ResourceLoader.load(PLAYLIST[randi() % PLAYLIST.size()])
	self.play()


func _on_audio_stream_player_finished() -> void:
	cooldown.set_wait_time(30.0)
	cooldown.start()

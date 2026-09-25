extends Node

enum MusicType { MENU, GAME }

const MENU_FOLDER: String = "res://assets/sounds/music/menu/"
const RADIO_FOLDER: String = "res://assets/sounds/music/radio/"
const AMBIENT_FOLDER: String = "res://assets/sounds/music/ambient/"

var radio: Array[AudioStreamOggVorbis] = []


func _ready() -> void:
	_init_audio(RADIO_FOLDER)


func play_sound(volume: String) -> void:
	var path: String

	if volume.is_empty():
		return

	path = "res://assets/sounds/" + volume + ".ogg" if !volume.ends_with(".ogg") else "res://assets/sounds/" + volume

	var audio: AudioStreamPlayer
	audio = AudioStreamPlayer.new()
	audio.finished.connect(_audio_is_finished.bind(audio))
	audio.stream = load(path)
	self.add_child(audio)
	audio.play()


func play_music(type: MusicType) -> void:
	match type:
		MusicType.MENU:
			pass

		MusicType.GAME:
			pass

		_:
			print("asdasdasd")


func _init_audio(folder: String) -> void:
	var dir := DirAccess.open(folder)

	if !dir:
		printerr("Could not open folder")
		return

	dir.list_dir_begin()
	for file: String in dir.get_files():
		if file.ends_with(".ogg"):
			var audio := load(dir.get_current_dir() + "/" + file)

			if !audio || !audio is AudioStreamOggVorbis:
				printerr("Uncorrected type file.")
				return

			radio.append(audio)


func _audio_is_finished(audio: AudioStreamPlayer) -> void:
	self.remove_child(audio)
	audio.queue_free()

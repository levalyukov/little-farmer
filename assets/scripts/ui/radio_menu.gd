extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

@onready var header:Label = $NinePatchRect/VBoxContainer/HeaderMargin/Label
@onready var playNow:Label = $NinePatchRect/VBoxContainer/PlayNowMargin/Label
@onready var powerButton:Button = $NinePatchRect/VBoxContainer/PowerRadio/HBoxContainer2/PowerButton

@onready var buttonsInteractions:HBoxContainer = $NinePatchRect/VBoxContainer/PreviousNextButton/HBoxContainer
@onready var previousButton:Button = $NinePatchRect/VBoxContainer/PreviousNextButton/HBoxContainer/PreviousTrackButton
@onready var pauseTrack:Button = $NinePatchRect/VBoxContainer/PreviousNextButton/HBoxContainer/PauseTrackButton
@onready var nextTrack:Button = $NinePatchRect/VBoxContainer/PreviousNextButton/HBoxContainer/NextTrackButton

@onready var radiostationsHeader:Label = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer2/MarginContainer/Label
@onready var usersTracksHeader:Label = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer2/MarginContainer2/Label
@onready var radiostationsContainer:VBoxContainer = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer/RadiostationContainer/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var usersTracksMargin:MarginContainer = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer/UserTracksContainer/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer
@onready var usersTracksContainer:VBoxContainer = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer/UserTracksContainer/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer
@onready var buttonOpenFolder:Button = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer/UserTracksContainer/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/OpenFolderButton
@onready var buttonScanUsersTracks:Button = $NinePatchRect/VBoxContainer/RadioType/VBoxContainer/HBoxContainer/UserTracksContainer/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ScanFolderButton
@onready var anim:AnimationPlayer = $AnimationPlayer

var opened:bool = false
var node:Node2D = null
var buttons_captions:Array[String] = []
var buttons_index:Array[int] = []
var stations_name:Array[String] = []
var stream_position:float = 0.0
var stopped:bool = false
var stations:Dictionary = {
	tr('Радио «Культура»'): {
		'captions': [
			'Странник в облаках',
			'Без названия',
			'Не грусти!',
			'Где-то в облаках',
			'Фермерский быт',
			'Утренний ветерок',
			'В даль реки',
			'Композиция',
		],
		'tracks': [
			'res://assets/sounds/music/radio/track#1.ogg',
			'res://assets/sounds/music/radio/track#2.ogg',
			'res://assets/sounds/music/radio/track#3.ogg',
			'res://assets/sounds/music/radio/track#4.ogg',
			'res://assets/sounds/music/radio/track#5.ogg',
			'res://assets/sounds/music/radio/track#6.ogg',
			'res://assets/sounds/music/radio/track#7.ogg',
			'res://assets/sounds/music/radio/track#8.ogg',
		]
	},
}

var stations_audios_captions = []
var stations_audios = []
var station_audio_index:int = 0

func _ready():
	close()

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		close()

func _process(_delta):
	if visible:
		if node:
			if node.enabled:
				if !node.audio_player.is_playing() && !stopped:
					playNow.text ="Выберите режим работы радио ниже:"
				powerButton.text = tr("Выключить радио")

				if node.audio_player.is_playing():
					if !node.particles.emitting:
						node.particles.emitting = true
				else:
					if node.particles.emitting:
						node.particles.emitting = !true

				if node.radio_noise:
					if !node.radio_noise.is_playing():
						node.radio_noise.play()
			else:
				if playNow.text != "":
					playNow.text = ""
				powerButton.text = tr("Включить радио")

				if node.particles.emitting:
					node.particles.emitting = !true

				if node.radio_noise:
					if node.radio_noise.is_playing():
						node.radio_noise.stop()
			if node.userMode:
				if stopped:
					pauseTrack.text = 'Слушать'
				else:
					pauseTrack.text = 'Пауза'
				if node.audio_player.is_playing():
					if !buttonsInteractions.visible:
						buttonsInteractions.visible = true
			else:
				if buttonsInteractions.visible:
					buttonsInteractions.visible = false

func update_string_playNow() -> void:
	if node:
		if !stopped:
			if len(node.audio_captions[node.audio_index_track]) > 50:
				playNow.text = tr("Сейчас играет: ") + "\"" + str(node.audio_captions[node.audio_index_track].substr(0,50)) + "..." + "\""
			else:
				playNow.text = tr("Сейчас играет: ") + "\"" + str(node.audio_captions[node.audio_index_track]) + "\""
		else:
			if len(node.audio_captions[node.audio_index_track]) > 50:
				playNow.text = tr("На паузе: ") + "\"" + str(node.audio_captions[node.audio_index_track].substr(0,50)) + "..." + "\""
			else:
				playNow.text = tr("На паузе: ") + "\"" + str(node.audio_captions[node.audio_index_track]) + "\""

func set_stations() -> void:
	if radiostationsContainer.get_children() != []:
		for i in radiostationsContainer.get_children():
			radiostationsContainer.remove_child(i)

	if stations.size() > 0:
		for station_name in stations.keys():
			var button = Button.new()
			button.text = station_name
			button.connect("pressed", Callable(self, "on_station_pressed").bind(station_name))
			radiostationsContainer.add_child(button)

func on_station_pressed(stationName:String):
	if visible:
		if node:
			if !node.radio:
				node.userMode = false
				node.radio = true
				node.random = true
				node.repeat = true

				stations_audios = []
				if stations.has(stationName):
					if stations[stationName].has('captions'):
						if stations[stationName]['captions'] is Array && stations[stationName]['captions'].size() > 0:
							for i in stations[stationName]['captions']:
								stations_audios_captions.append(i)

						if stations[stationName]['tracks'] is Array && stations[stationName]['tracks'].size() > 0:
							for i in stations[stationName]['tracks']:
								stations_audios.append(i)

				if stations_audios.size() > 0 && stations_audios_captions.size() > 0 :
					if node:
						station_audio_index = randi() % stations_audios.size()
						node.play_radio_track(stations_audios, station_audio_index)
						set_radio_track_name(station_audio_index)

				var audio = AudioStreamPlayer.new()
				self.add_child(audio)
				audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
				audio.stream = load('res://assets/sounds/ui/click.ogg')
				audio.play()
			check_game_music()

func _on_open_folder_button_pressed():
	data.open_folder_in_explorer("user://game/custom_music/")
	var readme_url = 'user://game/custom_music/readme.txt'
	var readme_read = FileAccess.open(readme_url, FileAccess.READ)
	if !readme_read:
		var readme_file = FileAccess.open(readme_url, FileAccess.WRITE)
		readme_file.store_string(
			"Чтобы воспроизвести пользовательские песни, нужно поместить в эту папку аудиофайлы формата .mp3\n\n* * *\n\nTo play custom songs, you need to place the .mp3 audio files in this folder"
		)
		readme_file.close()
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_scan_folder_button_pressed():
	if node:
		node.playlist_scan()
		remove_users_track_buttons()
		if node.audio_captions != []:
			buttons_captions = []
			for caption in node.audio_captions:
				if len(caption) > 20:
					buttons_captions.append(caption.substr(0,20) + "...")
				else:
					buttons_captions.append(caption)
			for x in node.audio_streams.size():
				var button = Button.new()
				button.text = buttons_captions[x]
				button.connect("pressed", Callable(self, "on_userTrack_pressed").bind(x))
				usersTracksContainer.add_child(button)
				if node:
					if !node.enabled:
						button.disabled = true
					else:
						button.disabled = !true
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

	if usersTracksContainer.get_children() == []:
		usersTracksMargin.add_theme_constant_override("margin_top", 0)
	else:
		usersTracksMargin.add_theme_constant_override("margin_top", 16)

func remove_users_track_buttons() -> void:
	if usersTracksContainer:
		if usersTracksContainer.get_children() != []:
			for x in usersTracksContainer.get_children():
				usersTracksContainer.remove_child(x)
		usersTracksMargin.add_theme_constant_override("margin_top", 0)

func on_userTrack_pressed(index:int):
	if node:
		node.play_track(index)
		node.userMode = true
		node.radio = false
		node.random = !true
		node.repeat = true
		stream_position = 0.0
		stopped = false
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/click.ogg')
		audio.play()

func open(_node:Node2D) -> void:
	opened = true
	node = _node
	set_stations()
	blur.blur(true)
	anim.play("open")
	if node:
		if !node.enabled:
			if usersTracksContainer.get_children().size() > 0:
				for x in usersTracksContainer.get_children():
					if x is Button:
						x.disabled = true
			if radiostationsContainer.get_children().size() > 0:
				for z in radiostationsContainer.get_children():
					if z is Button:
						z.disabled = true
		else:
			if usersTracksContainer.get_children().size() > 0:
				for x in usersTracksContainer.get_children():
					if x is Button:
						x.disabled = false
			if radiostationsContainer.get_children().size() > 0:
				for z in radiostationsContainer.get_children():
					if z is Button:
						z.disabled = false
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func close() -> void:
	opened = false
	node = null
	blur.blur(false)
	anim.play("close")
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_close_button_pressed() -> void:
	close()
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_power_button_pressed():
	if visible:
		if node:
			if node.enabled:
				node.start_game_music = true
				node.enabled = false
				node.radio = false
				node.userMode = false
				node.audio_player.stop()
				stream_position = 0.0
				stopped = false
				if usersTracksContainer.get_children().size() > 0:
					for x in usersTracksContainer.get_children():
						if x is Button:
							x.disabled = true

				if radiostationsContainer.get_children().size() > 0:
					for z in radiostationsContainer.get_children():
						if z is Button:
							z.disabled = true
			else:
				node.enabled = true
				if usersTracksContainer.get_children().size() > 0:
					for x in usersTracksContainer.get_children():
						if x is Button:
							x.disabled = false

				if radiostationsContainer.get_children().size() > 0:
					for z in radiostationsContainer.get_children():
						if z is Button:
							z.disabled = false
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_pause_track_button_pressed():
	if visible:
		if node:
			if !stopped && node.audio_player.is_playing():
				stream_position = node.audio_player.get_playback_position()
				node.audio_player.stop()
				stopped = true
			else:
				node.audio_player.play(stream_position)
				stopped = false
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()
			
func _on_next_track_button_pressed():
	if visible:
		if node:
			stream_position = 0.0
			stopped = false
			node.next_track()
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_previous_track_button_pressed():
	if visible:
		if node:
			stream_position = 0.0
			stopped = false
			node.previous_track()
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_close_button_mouse_entered():
	if cursor: cursor.set_cursor(cursor.states.ACTIVE)
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()

func _on_close_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(_audio) -> void:
	_audio.queue_free()

func _on_previous_track_button_mouse_entered():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_previous_track_button_mouse_exited():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_pause_track_button_mouse_exited():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_pause_track_button_mouse_entered():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_next_track_button_mouse_entered():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_next_track_button_mouse_exited():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_power_button_mouse_entered():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_power_button_mouse_exited():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_open_folder_button_mouse_entered():
	if visible && !buttonOpenFolder.disabled:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_open_folder_button_mouse_exited():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_scan_folder_button_mouse_entered():
	if visible && !buttonScanUsersTracks.disabled:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_scan_folder_button_mouse_exited():
	if visible:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func set_radio_track_name(track_index) -> void:
	if stations_audios_captions.size() > 0:
		playNow.text = tr("Сейчас играет: ") + "\"" + stations_audios_captions[track_index] + "\""

func check_game_music() -> void:
	if node:
		if node.enabled:
			if node.radio_noise.is_playing():
				if main == 'Farm':
					for i in get_tree().root.get_child(2).get_children():
						if i.name == 'MusicPlayer':
							i.stop()

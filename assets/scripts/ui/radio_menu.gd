extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")

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

@onready var anim:AnimationPlayer = $AnimationPlayer

var opened:bool = false
var node:Node2D = null
var buttons_captions:Array[String] = []
var buttons_index:Array[int] = []
var stations_name:Array[String] = []
var stream_position:float = 0.0
var stopped:bool = false
var stations:Dictionary = {
	tr('Радио «Культура»'): [
		'res://sounds/stations/cultura/track_1',
		'res://sounds/stations/cultura/track_2',
		'res://sounds/stations/cultura/track_3',
		'res://sounds/stations/cultura/track_4',
		'res://sounds/stations/cultura/track_5',
		],
	tr('Радио «Инди»'): [
		'res://sounds/stations/indie/track_1',
		'res://sounds/stations/indie/track_2',
		'res://sounds/stations/indie/track_3',
		'res://sounds/stations/indie/track_4',
		'res://sounds/stations/indie/track_5',
		],
	tr('Радио+ FM'): [
		'res://sounds/stations/radio-plus/track_1',
		'res://sounds/stations/radio-plus/track_2',
		'res://sounds/stations/radio-plus/track_3',
		'res://sounds/stations/radio-plus/track_4',
		'res://sounds/stations/radio-plus/track_5',
		],
}

func _ready():
	close()

func _process(_delta):
	if visible:
		if node:
			if node.enabled:
				if node.audio_player.is_playing():
					if !node.particles.emitting:
						node.particles.emitting = true
				else:
					if node.particles.emitting:
						node.particles.emitting = !true
			else:
				if node.particles.emitting:
					node.particles.emitting = !true

			if stopped:
				pauseTrack.text = 'Слушать'
			else:
				pauseTrack.text = 'Пауза'

			if node.audio_player.is_playing():
				if !buttonsInteractions.visible:
					buttonsInteractions.visible = true

			if node.enabled:
				if !node.audio_player.is_playing() && !stopped:
					playNow.text ="Выберите режим работы радио ниже:"
				powerButton.text = tr("Выключить радио")
			else:
				if playNow.text != "":
					playNow.text =""
				powerButton.text = tr("Включить радио")
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
			node.userMode = !true
			print(stationName)

func _on_open_folder_button_pressed():
	data.open_folder_in_explorer("user://game/custom_music/")

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
		stream_position = 0.0
		stopped = false

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

func close() -> void:
	opened = false
	node = null
	blur.blur(false)
	anim.play("close")

func window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_close_button_pressed() -> void:
	close()

func _on_power_button_pressed():
	if visible:
		if node:
			if node.enabled:
				node.enabled = false
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
			
func _on_next_track_button_pressed():
	if visible:
		if node:
			stream_position = 0.0
			stopped = false
			node.next_track()

func _on_previous_track_button_pressed():
	if visible:
		if node:
			stream_position = 0.0
			stopped = false
			node.previous_track()

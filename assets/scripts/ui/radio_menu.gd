extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")

@onready var header:Label = $NinePatchRect/VBoxContainer/HeaderMargin/Label
@onready var playNow:Label = $NinePatchRect/VBoxContainer/PlayNowMargin/Label
@onready var powerButton:Button = $NinePatchRect/VBoxContainer/PowerRadio/HBoxContainer2/Pause

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
var stations:Dictionary = {
	'Retro FM': [
		'res://sounds/stations/retro/track_1',
		'res://sounds/stations/retro/track_2',
		'res://sounds/stations/retro/track_3',
		'res://sounds/stations/retro/track_4',
		'res://sounds/stations/retro/track_5'
		],
}

func _ready():
	close()

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
	print(
		'stations data: ', stations[stationName]
	)

func _on_open_folder_button_pressed():
	data.open_folder_in_explorer("user://game/custom_music/")

func _on_scan_folder_button_pressed():
	if node:
		node.playlist_scan()
		if usersTracksContainer.get_children() != []:
			for x in usersTracksContainer.get_children():
				usersTracksContainer.remove_child(x)
		if node.audio_captions != []:
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

	if usersTracksContainer.get_children() == []:
		usersTracksMargin.add_theme_constant_override("margin_top", 0)
	else:
		usersTracksMargin.add_theme_constant_override("margin_top", 16)

func on_userTrack_pressed(musicID:int):
	if node:
		print(musicID)

func open(_node:Node2D) -> void:
	opened = true
	node = _node
	set_stations()
	blur.blur(true)
	anim.play("open")

func close() -> void:
	opened = false
	node = null
	blur.blur(false)
	anim.play("close")

func window() -> void:
	visible = opened

func _on_close_button_pressed() -> void:
	close()
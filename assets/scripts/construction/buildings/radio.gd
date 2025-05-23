extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var radioMenu:Control = get_node("/root/"+main+"/UI/Interactive/RadioMenu")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

@onready var particles:CPUParticles2D = $CPUParticles2D
@onready var audio_player:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var radio_noise:AudioStreamPlayer2D = $RadioNoise
@onready var sprite:Sprite2D = $Sprite2D

var node_name:String = ''
var start_game_music:bool = false

var level:int = 0

var audio_streams:Array[AudioStreamMP3] = []
var audio_captions:Array[String] = []
var audio_index_track:int = -1

var enabled:bool = false
var radio:bool = false
var userMode:bool = false
var repeat:bool = true
var random:bool = false

var blueprint_id:int
var all_collisions:Array[Vector2i] = []
var state:bool = false
var destroyMode:bool = false
var object:Dictionary = {
	"default": load("res://assets/resources/buildings/radio/obj_0.png"),
	"hover": load("res://assets/resources/buildings/radio/obj_1.png"),
	'delete': load("res://assets/resources/buildings/radio/obj_2.png")
}

func playlist_scan(folder_path:String = "user://game/custom_music/") -> void:
	var files = scan_user_files(folder_path)
	if files != []:
		audio_streams = []
		for file in files:
			var full_path = folder_path + file
			var audio_resource = load_mp3(full_path)
			if audio_resource:
				audio_streams.append(audio_resource)
	else:
		data.debug('the folder is empty.', 'error')

func load_mp3(file_path:String) -> AudioStream:
	if !FileAccess.file_exists(file_path):
		return null
	var file = FileAccess.open(file_path, FileAccess.READ)
	if !file:
		return null
	var file_size = file.get_length()
	if file_size == 0:
		file.close()
		return null
	var _data = file.get_buffer(file_size)
	file.close()
	var stream = AudioStreamMP3.new()
	stream.data = _data
	return stream

func play_track(index:int) -> void:
	audio_index_track = index
	if audio_streams.size() > 0:
		if index < 0 || index >= audio_streams.size():
			return
		if enabled:
			audio_player.stop()
			audio_player.stream = audio_streams[audio_index_track]
			audio_player.play()
	if radioMenu:
		radioMenu.update_string_playNow()

func stop_track() -> void:
	audio_player.stop()

func scan_user_files(folder_path:String = "user://game/custom_music/") -> Array:
	var dir = DirAccess.open(folder_path)
	var files = []
	var readme_url = 'user://game/custom_music/readme.txt'
	var readme_read = FileAccess.open(readme_url, FileAccess.READ)
	if !readme_read:
		var readme_file = FileAccess.open(readme_url, FileAccess.WRITE)
		readme_file.store_string(
			"Чтобы воспроизвести пользовательские песни, нужно поместить в эту папку аудиофайлы формата .mp3\n\n* * *\n\nTo play custom songs, you need to place the .mp3 audio files in this folder"
		)
		readme_file.close()
	if !dir:
		FileSystem.new().Funcs.create_directory(folder_path)
		scan_user_files(folder_path)
	else:
		dir.list_dir_begin()
		audio_captions = []
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			if file_name.begins_with(".") || file_name == "..":
				continue
			if dir.current_is_dir():
				continue
			if file_name.to_lower().ends_with(".mp3"):
				audio_captions.append(file_name.replace(".mp3", ""))
				files.append(file_name)
	return files

func next_track() -> void:
	if audio_index_track < audio_streams.size()-1:
		audio_index_track += 1
		play_track(audio_index_track)
	else:
		if repeat:
			audio_index_track = 0
			play_track(audio_index_track)

func previous_track() -> void:
	if audio_index_track < 0:
		audio_index_track = audio_streams.size()-1
	else:
		audio_index_track -= 1
	play_track(audio_index_track)

func _input(event):
	if !pause.paused\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& !destroyMode:
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed()\
		&& state:
			radioMenu.open(self)

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		buildings.remove_node(self, all_collisions)
		if radioMenu:
			radioMenu.remove_users_track_buttons()

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_RIGHT\
	&& event.is_pressed()\
	&& state\
	&& !blur.state\
	&& !destroyMode:
		next_track()

func _on_area_2d_mouse_entered() -> void:
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& !buttonDestroy.destroyMode:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		if !state:
			state = true
		if object.has('hover'):
			if object['hover'] is CompressedTexture2D:
				sprite.texture = object['hover']
	elif !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& buttonDestroy.destroyMode\
	&& !enabled:
		if !destroyMode:
			destroyMode = true
		if object.has('delete'):
			if object['delete'] is CompressedTexture2D:
				sprite.texture = object['delete']

func _on_area_2d_mouse_exited() -> void:
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if destroyMode:
		destroyMode = !true
	if state:
		state = !true
	if object.has('default'):
		if object['default'] is CompressedTexture2D:
			sprite.texture = object['default']

func get_data() -> Dictionary:
	return {
		'name': node_name,
		"id": blueprint_id,
		"position": tilemap.local_to_map(position),
		'all_collisions': all_collisions
	}

func _on_audio_stream_player_2d_finished() -> void:
	if !pause.paused:
		if userMode:
			next_track()
		if radio:
			next_radio_track() 

func play_radio_track(array,index) -> void:
	if enabled:
		audio_player.stop()
		audio_player.stream = ResourceLoader.load(array[index])
		audio_player.play()

func next_radio_track() -> void:
	if radioMenu:
		if radioMenu.stations_audios.size() > 0:
			var new_index_track = get_random_audio_index(radioMenu.stations_audios, radioMenu.station_audio_index)
			if new_index_track != -1:
				radioMenu.station_audio_index = new_index_track
				play_radio_track(
					radioMenu.stations_audios, 
					radioMenu.station_audio_index
				)
				radioMenu.set_radio_track_name()

func get_random_audio_index(sounds_array, index):
	if sounds_array.size() == 0:
		return -1
	var new_index = randi() % sounds_array.size()
	if sounds_array.size() == 1:
		if is_valid_sound(sounds_array[0]):
			return 0
		else:
			return -1
	while true:
		new_index = randi() % sounds_array.size()
		if new_index != index && is_valid_sound(sounds_array[new_index]):
			break
	audio_index_track = new_index
	return new_index

func is_valid_sound(sound_path) -> bool:
	if sound_path is String and sound_path.length() > 0:
		var file_exists = ResourceLoader.exists(sound_path, "AudioStream")
		return file_exists
	return false

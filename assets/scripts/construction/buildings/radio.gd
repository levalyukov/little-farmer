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

@onready var particles:CPUParticles2D = $CPUParticles2D
@onready var audio_player:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite:Sprite2D = $Sprite2D

var audio_streams:Array[AudioStreamMP3] = []
var audio_captions:Array[String] = []
var audio_index_track:int = 0
var enabled:bool = false
var repeat:bool = true
var userMode:bool = false
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
	if !dir:
		FileSystem.new().Funcs.create_directory(folder_path)
		scan_user_files(folder_path)

	dir.list_dir_begin()
	audio_captions = []
	var files = []
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

func _process(_delta):
	if pause.paused:
		if enabled:
			if !audio_player.get_stream_paused():
				audio_player.set_stream_paused(true)
			if particles.speed_scale > 0.0:
				particles.speed_scale = 0.0
	else:
		if enabled:
			if audio_player.get_stream_paused():
				audio_player.set_stream_paused(false)
			if particles.speed_scale == 0.0:
				particles.speed_scale = 0.5

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
	if destroyMode:
		destroyMode = !true
	if state:
		state = !true
	if object.has('default'):
		if object['default'] is CompressedTexture2D:
			sprite.texture = object['default']

func get_data() -> Dictionary:
	return {
		"id": blueprint_id,
		"position": tilemap.local_to_map(position),
		'all_collisions': all_collisions
	}

func _on_audio_stream_player_2d_finished() -> void:
	if !pause.paused:
		next_track()

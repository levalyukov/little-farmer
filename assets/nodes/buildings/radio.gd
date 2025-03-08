extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var particles:CPUParticles2D = $CPUParticles2D
@onready var audio_player:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite:Sprite2D = $Sprite2D

var audio_streams:Array[AudioStreamMP3] = []
var enabled:bool = false
var state:bool = false
var object:Dictionary = {
	"default": load("res://assets/resources/buildings/radio/obj_0.png"),
	"hover": load("res://assets/resources/buildings/radio/obj_1.png"),
	'delete': load("res://assets/resources/buildings/radio/obj_2.png")
}

func playlist_scan(folder_path:String) -> void:
	var files = scan_mp3_files(folder_path)
	for file in files:
		var full_path = folder_path + file
		var audio_resource = load_mp3(full_path)
		if audio_resource:
			audio_streams.append(audio_resource)
	if audio_streams.size() > 0:
		play_track(0)

func load_mp3(file_path: String) -> AudioStream:
	if not FileAccess.file_exists(file_path):
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
	if index < 0 or index >= audio_streams.size():
		return
	audio_player.stop()
	audio_player.stream = audio_streams[index]
	audio_player.play()

func stop_track() -> void:
	audio_player.stop()

func scan_mp3_files(folder_path:String) -> Array:
	var dir = DirAccess.open(folder_path)
	if !dir:
		data.debug("Folder was not found or access is denied.", "error")
		return []
	dir.list_dir_begin()
	var files = []
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if file_name.begins_with(".") or file_name == "..":
			continue
		if dir.current_is_dir():
			continue
		if file_name.to_lower().ends_with(".mp3"):
			files.append(file_name)
	return files

func convert_to_mono(file_path:String, output_path:String):
	if !FileAccess.file_exists(file_path):
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	if !file:
		return
	var file_size = file.get_length()
	if file_size == 0:
		file.close()
		return
	var _data = file.get_buffer(file_size)
	file.close()
	var mono_data = PackedByteArray()
	for i in range(0, _data.size(), 4):
		var left_channel = _data[i] + (_data[i + 1] << 8)
		var right_channel = _data[i + 2] + (_data[i + 3] << 8)
		var mono_sample = (left_channel + right_channel) / 2 
		mono_data.append(mono_sample & 0xFF)
		mono_data.append((mono_sample >> 8) & 0xFF)
	var output_file = FileAccess.open(output_path, FileAccess.WRITE)
	if !output_file:
		return
	output_file.store_buffer(mono_data)
	output_file.close()

func _input(event):
	if !pause.paused\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed()\
		&& state:
			if !enabled:
				enabled = true
				if !particles.emitting:
					particles.emitting = true
				playlist_scan("user://.game/custom_music/")
			else:
				enabled = !true
				stop_track()
				if particles.emitting:
					particles.emitting = !true

func _on_area_2d_mouse_entered():
	if !state:
		state = true
	if object.has('hover'):
		if object['hover'] is CompressedTexture2D:
			sprite.texture = object['hover']

func _on_area_2d_mouse_exited():
	if state:
		state = !true
	if object.has('default'):
		if object['default'] is CompressedTexture2D:
			sprite.texture = object['default']
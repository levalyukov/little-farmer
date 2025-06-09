extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var constructionManager:Node2D = get_node('/root/'+main+'/ConstructionManager')
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")

const ATTEMPT_MAX = 10

var _COOLDOWN:float
var _timer:Timer
var _stream:AudioStreamPlayer

var _last_index:int = -1
var _new_index = 0

var _playlist = {
	'spring': {
		'day': [
			'res://assets/sounds/music/flp/spring/music#1.ogg',
			'res://assets/sounds/music/flp/spring/music#2.ogg',
			'res://assets/sounds/music/flp/spring/music#3.ogg'
		],
		'night': [
			'res://assets/sounds/music/flp/spring/night#1.ogg'
		]
	},
	'summer': {
		'day': [
			'res://assets/sounds/music/flp/summer/music#1.ogg',
			'res://assets/sounds/music/flp/summer/music#2.ogg',
			'res://assets/sounds/music/flp/summer/music#3.ogg'
		],
		'night': []
	},
	'autumn': {
		'day': [
			'res://assets/sounds/music/flp/autumn/music#1.ogg',
			'res://assets/sounds/music/flp/autumn/music#2.ogg'
		],
		'night': [
			'res://assets/sounds/music/flp/autumn/night#1.ogg'
		]
	}
}

var _spring_day_music = []
var _spring_night_music = []

var _summer_day_music = []
var _summer_night_music = []

var _autumn_day_music = []
var _autumn_night_music = []

var _winter_day_music = []
var _winter_night_music = []


func _ready() -> void:
	_COOLDOWN = randf_range(10.0, 180.0)
	_timer = Timer.new()
	_timer.set_autostart(true)
	_timer.wait_time = _COOLDOWN
	_timer.connect('timeout', Callable(self, '_game_music').bind())
	add_child(_timer)

	_stream = AudioStreamPlayer.new()
	add_child(_stream)
	_stream.bus = "Music"

func _game_music() -> void:
	if (_stream && !_stream.is_playing()) && !_radio_is_playing():
		_distribute_arrays()
		var _current_arr = _get_current_arr()
		
		if _current_arr.is_empty(): return
		
		_new_index = _generate_index(_current_arr)
		_last_index = _new_index
		
		var stream = load(_current_arr[_new_index])
		if stream:
			_stream.stream = stream
			_stream.play()
	else:
		_COOLDOWN = randf_range(10.0, 180.0)
		_timer.wait_time = _COOLDOWN

func _radio_is_playing() -> bool:
	if constructionManager && constructionManager.get_children().size() > 0:
		for node in constructionManager.get_children():
			if node && 'blueprint_id' in node:
				if node.blueprint_id == 10:
					if node.radio_noise.is_playing():
						return true
	return false

func _is_playing() -> bool:
	if _stream:
		if _stream.is_playing():
			return true
	return false

func _generate_index(_array:Array) -> int:
	if _array.size() == 0:
		return 0
	if _array.size() == 1:
		return 0
	
	var new_idx
	var attempt = 0
	
	while attempt < ATTEMPT_MAX:
		new_idx = randi() % _array.size()
		if new_idx != _last_index:
			break
		attempt += 1
	
	return new_idx

func _distribute_arrays() -> void:
	if _playlist.is_empty(): return

	var _clock_season = clock.get_season()

	if _playlist.has(_clock_season):
		if _playlist[_clock_season].has('day') && !_playlist[_clock_season]['day'].is_empty():
			var _playlist_day = _playlist[_clock_season]['day']
			match _clock_season:
				'spring':
					_spring_day_music = []
					for song in _playlist_day:
						_spring_day_music.append(song)
				'summer':
					_summer_day_music = []
					for song in _playlist_day:
						_summer_day_music.append(song)
				'autumn':
					_autumn_day_music = []
					for song in _playlist_day:
						_autumn_day_music.append(song)
				'winter':
					_winter_day_music = []
					for song in _playlist_day:
						_winter_day_music.append(song)

		if _playlist[_clock_season].has('night') && !_playlist[_clock_season]['night'].is_empty():

			var _playlist_night = _playlist[_clock_season]['night']

			match _clock_season:
				'spring':
					_spring_night_music = []
					for song in _playlist_night:
						_spring_night_music.append(song)
						
				'summer':
					_summer_night_music = []
					for song in _playlist_night:
						_summer_night_music.append(song)
						
				'autumn':
					_autumn_night_music = []
					for song in _playlist_night:
						_autumn_day_music.append(song)
						
				'winter':
					_winter_night_music = []
					for song in _playlist_night:
						_winter_night_music.append(song)

func _get_current_arr() -> Array:
	var _clock_season = clock.get_season()
	var _day_part = clock.get_part_day()

	match _clock_season:
		'spring':
			if _day_part == "day":
				return _spring_day_music
			return _spring_night_music

		'summer':
			if _day_part == "day":
				return _summer_day_music
			return _summer_night_music

		'autumn':
			if _day_part == "day":
				return _autumn_day_music
			return _autumn_night_music

		'winter':
			if _day_part == "day":
				return _winter_day_music
			return _winter_night_music
	return []
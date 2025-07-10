extends MarginContainer

@onready var main = str(get_tree().root.get_child(2).name)
@onready var options:Control = $Menu/Options
@onready var blackout:Control = $Blackout
@onready var blur:Control = $Blur
@onready var cursor:Node2D = $Cursor
@onready var game_continue_button:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ContinueMargin/ContinueButton
@onready var version:Label = $MenuContent/VContainer/FooterMargin/VBoxContainer/Version
@onready var credits:Label = $MenuContent/VContainer/FooterMargin/VBoxContainer/Credits
@onready var countinue_game_button:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ContinueMargin/ContinueButton
@onready var gamedata = get_node("/root/"+main+"/GameData")
@onready var modal = get_node("/root/"+main+"/Menu/Modal")
# --- --- ---
var data_path = DirAccess.open('user://game/data')
var farm_path = DirAccess.open('user://game/data/farm')
# farm path

var nature_file = FileAccess.open('user://game/data/nature.json', FileAccess.READ)
var world_file = FileAccess.open('user://game/data/world.json', FileAccess.READ)
# farm path files

var farm_main_file = FileAccess.open('user://game/data/farm/farm.json', FileAccess.READ)
var farm_buildings_file = FileAccess.open('user://game/data/farm/buildings.json', FileAccess.READ)
var farm_vectors_path = DirAccess.open('user://game/data/farm/vectors')
var vectors_coast_file = FileAccess.open('user://game/data/farm/vectors/coast.json', FileAccess.READ)
var vectors_farmlands_file = FileAccess.open('user://game/data/farm/vectors/farmlands.json', FileAccess.READ)
var vectors_plants_file = FileAccess.open('user://game/data/farm/vectors/plants.json', FileAccess.READ)
var vectors_roads_file = FileAccess.open('user://game/data/farm/vectors/roads.json', FileAccess.READ)
var vectors_waterings_file = FileAccess.open('user://game/data/farm/vectors/waterings.json', FileAccess.READ)
var vectors_water_file = FileAccess.open('user://game/data/farm/vectors/water.json', FileAccess.READ)

# player
var player_path = DirAccess.open('user://game/data/player')
var blueprints_file = FileAccess.open('user://game/data/player/blueprints.json', FileAccess.READ)
var inventory_file = FileAccess.open('user://game/data/player/inventory.json', FileAccess.READ)
var mailbox_file = FileAccess.open('user://game/data/player/mailbox.json', FileAccess.READ)
var player_file = FileAccess.open('user://game/data/player/player.json', FileAccess.READ)
# --- --- ---
@onready var buttonCountinue:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ContinueMargin/ContinueButton
@onready var buttonNewGame:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/NewGameMargin/NewGameButton
@onready var buttonSettings:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/SettingsMargin/SettingsButton
@onready var buttonExit:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ExitMargin/ExitButton

#Игра находится в ранем доступе, поэтому Вы можете\nстолкнуться с багами/ошибками, нестабильной\nработой механик и неполным контентом.\n\nЕсли Вы нашли баг, недочет или какая-то механика \nперестала корректно работать, используйте кнопку \nв меню паузы «Сообщить об ошибке».\n\nСпасибо, что присоединились к нам на этом этапе разработки!

var buttonCountinueText:String = tr('main_menu.countinue_game_button')
var buttonNewGameText:String = tr('main_menu.new_game_button')
var buttonSettingsText:String = tr('main_menu.settings_button')
var buttonQuitText:String = tr('main_menu.quit_buttin')
var creditsText:String = tr('main_menu.credits')

@onready var _menu_music:AudioStreamPlayer
@onready var _menu_music_cooldown:Timer

var clicked:bool = false
var _playlist:Array[String] = [
	'res://assets/sounds/music/flp/spring/music#1.ogg',
]


func _ready():
	_initilize_music()
	cursor.set_cursor(cursor.states.DEFAULT)
	blackout.blackout(false)
	version.text = "v" + ProjectSettings.get_setting("application/config/version")
	# Game Countinue
	if data_path\
	&& farm_path\
	&& nature_file\
	&& world_file\
	&& farm_main_file\
	&& farm_buildings_file\
	&& farm_vectors_path\
	&& vectors_coast_file\
	&& vectors_farmlands_file\
	&& vectors_plants_file\
	&& vectors_roads_file\
	&& vectors_waterings_file\
	&& vectors_water_file\
	&& player_path\
	&& blueprints_file\
	&& inventory_file\
	&& mailbox_file\
	&& player_file:
		game_continue_button.disabled = false
	else:
		game_continue_button.disabled = true

	if gamedata:
		if gamedata.has_method('config_load'):
			gamedata.config_load()
			#	SettingsManager.settings_apply()

func _initilize_music() -> void:
	_menu_music = AudioStreamPlayer.new()
	_menu_music_cooldown = Timer.new()
	self.add_child(_menu_music)
	self.add_child(_menu_music_cooldown)
	_menu_music.name = "MenuMusic"
	_menu_music.bus = 'Music'
	_play_music(_playlist)

func _on_continue_button_pressed():
	if !clicked:
		clicked = true
		if !blur.state:
			blackout.blackout(true)
			GameLoader.mode = true
			GameLoader.start = false
			blackout.change_scene("res://levels/farm.tscn")
		_play_sound('ui/click')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)

func _on_new_game_button_pressed():
	if !clicked:
		clicked = true
		if !blur.state:
			blackout.blackout(true)
			GameLoader.mode = false
			GameLoader.start = true
			blackout.change_scene("res://levels/farm.tscn")
		_play_sound('ui/click')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)

func _on_options_button_pressed():
	if !clicked:
		blur.blur(true)
		options.open()
		_play_sound('ui/click')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)

func _on_credits_button_pressed():
	if !clicked:
		_play_sound("ui/click")
		clicked = true
		modal.modal_create(
			tr('main_menu.modal.credits_header'),
			tr('main_menu.modal.credits_content'),
			tr('main_menu.modal.credits_button')
		)

func _on_exit_button_pressed():
	if !clicked:
		get_tree().quit() 

func _on_continue_button_mouse_entered():
	if !clicked && !countinue_game_button.disabled:
		_play_sound('ui/hover')
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_continue_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_new_game_button_mouse_entered():
	if !clicked:
		_play_sound('ui/hover')
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_new_game_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_settings_button_mouse_entered():
	if !clicked:
		_play_sound('ui/hover')
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_settings_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_exit_button_mouse_entered():
	if !clicked:
		_play_sound('ui/hover')
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_exit_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(_node) -> void:
	_node.queue_free()

func _play_music(array:Array[String]) -> void:
	var audio = array[randi() % array.size()]
	_menu_music.stop()
	_menu_music.stream = ResourceLoader.load(audio)
	_menu_music.play()

func _play_sound(_path:String) -> void:
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/'+_path+'.ogg')
	audio.play()

func _on_audio_stream_player_finished() -> void:
	_menu_music_cooldown.set_wait_time(30.0) 
	_menu_music_cooldown.start()

func _on_timer_timeout() -> void:
	_menu_music_cooldown.stop()
	_play_music(_playlist)



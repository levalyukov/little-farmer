extends MarginContainer

@onready var main = str(get_tree().root.get_child(2).name)
@onready var options:Control = $Menu/Options
@onready var blackout:Control = $Blackout
@onready var blur:Control = $Blur

@onready var game_continue_button:Button = $MenuContent/VContainer/ButtonsMargin/Buttons/ContinueMargin/ContinueButton
@onready var credits:Label = $MenuContent/VContainer/FooterMargin/Credits
var clicked:bool = false

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

func _ready():
	blackout.blackout(false)
	credits.text = "v" + ProjectSettings.get_setting("application/config/version") + "\n(C) Studio Miroro"
	if !GameLoader.modal:
		modal_create()
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
			GameConfig.apply()

func _on_continue_button_pressed():
	if !clicked:
		if !blur.state:
			blackout.blackout(true)
			GameLoader.mode = true
			GameLoader.start = false
			blackout.change_scene("res://levels/farm.tscn")
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/click.ogg')
		audio.play()

func _on_new_game_button_pressed():
	if !clicked:
		if !blur.state:
			blackout.blackout(true)
			GameLoader.mode = false
			GameLoader.start = true
			blackout.change_scene("res://levels/farm.tscn")
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/click.ogg')
		audio.play()

func _on_options_button_pressed():
	if !clicked:
		blur.blur(true)
		options.open()
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/click.ogg')
		audio.play()

func _on_exit_button_pressed():
	if !clicked:
		get_tree().quit() 

func modal_create() -> void:
	modal.modal_create(
		"Добро пожаловать!", 
		"
		Игра находится в альфе-тесте, поэтому Вы можете
		столкнуться с багами/ошибками, нестабильной 
		работой механик и неполным контентом.

		Если Вы нашли баг, недочет или какая-то механика
		перестала корректно работать, используйте кнопку
		в меню паузы «Сообщить об ошибке».

		Спасибо, что присоединились к нам на этом этапе разработки!
		"
		)

func _on_continue_button_mouse_entered():
	if !clicked:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_new_game_button_mouse_entered():
	if !clicked:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_settings_button_mouse_entered():
	if !clicked:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_exit_button_mouse_entered():
	if !clicked:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()
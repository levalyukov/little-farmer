extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data:Node = get_node("/root/"+main)
@export var languages:Array[String] = ["ru", "en"]
var lang:int = 1

func _ready():
	set_language(lang)

func change_language() -> void:
	lang = (lang + 1) % languages.size()
	TranslationServer.set_locale(languages[lang])
	GameConfig.language = lang

func set_language(value:int) -> void:
	lang = value
	TranslationServer.set_locale(languages[lang])

func _on_pressed() -> void:
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()
	match main:
		'MainMenu':
			var options:Control = get_node("/root/"+main+"/Menu/Options")
			if options.opened:
				change_language()
		_:
			var options:Control = get_node("/root/"+main+"/UI/Interactive/Options")
			if options.opened:
				change_language()

func _on_mouse_entered():
	match main:
		'MainMenu':
			var cursor = get_node('/root/'+main+'/Cursor')
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		_:
			var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_mouse_exited():
	match main:
		'MainMenu':
			var cursor = get_node('/root/'+main+'/Cursor')
			if cursor: cursor.set_cursor(cursor.states.DEFAULT)
		_:
			var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
			if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(node) -> void:
	node.queue_free()
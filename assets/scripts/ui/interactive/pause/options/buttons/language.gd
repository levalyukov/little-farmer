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
	match main:
		'MainMenu':
			var options:Control = get_node("/root/"+main+"/Menu/Options")
			if options.opened:
				change_language()
		_:
			var options:Control = get_node("/root/"+main+"/UI/Interactive/Options")
			if options.opened:
				change_language()

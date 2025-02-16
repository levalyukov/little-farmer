extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data:Node = get_node("/root/"+main)
@export var languages:Array[String] = ["ru", "en"]
var lang:int = 1

func _ready():
	change_language()

func change_language() -> void:
	lang = (lang + 1) % languages.size()
	TranslationServer.set_locale(languages[lang])
	if data.has_method("debug"):
		data.debug(
			"Game language changed: " + languages[lang],
		)
	else:
		print("Game language changed: ", languages[lang])

func _on_button_pressed() -> void:
	if main == "MainMenu":
		var options:Control = get_node("/root/"+main+"/Menu/Options")
		if options.opened:
			change_language()

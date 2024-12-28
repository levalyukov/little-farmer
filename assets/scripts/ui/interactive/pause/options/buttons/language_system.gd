extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@export var languages:Array[String] = ["ru", "en"]
var lang:int = 1

func _ready():
	change_language()

func change_language() -> void:
	lang = (lang + 1) % languages.size()
	TranslationServer.set_locale(languages[lang])
	print("Game language changed: ", languages[lang])

func _on_button_pressed() -> void:
	if main == "MainMenu":
		var options:Control = get_node("/root/"+main+"/Menu/Options")
		if options.opened:
			change_language()

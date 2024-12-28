extends Control

@onready var main = str(get_tree().root.get_child(1).name)

func _on_button_pressed():
	if main != "MainMenu":
		var options:Control = get_node("/root/"+main+"/UI/Interactive/Options")
		var blur:Control = get_node("/root/"+main+"/UI/Decoration/Blur")
		options.close()
		blur.blur(false)
	else:
		var menu:MarginContainer = get_node("/root/"+main+"/")
		var options:Control = get_node("/root/"+main+"/Menu/Options")
		var blur:Control = get_node("/root/"+main+"/Blur")
		options.close()
		blur.blur(false)
		menu.clicked = false

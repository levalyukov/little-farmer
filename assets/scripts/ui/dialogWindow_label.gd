extends Label

var text_to_print:String	#"Перед вами заброшенная могила, разрушенная временем.\n\nНа потрескавшейся могильной плите едва угадываются несколько букв имени покоящейся здесь женщины:\n\n - Тя..на Анна (200x — 20xx)"
var print_speed:float = 0.01
var timer:Timer
var current_char_index:int = 0

func setDialogText(mainText):
	text_to_print = mainText
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = print_speed
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	start_printing()

func start_printing():
	text = ""
	current_char_index = 0
	timer.start()

func _on_timer_timeout():
	if current_char_index < text_to_print.length():
		text += text_to_print[current_char_index]
		current_char_index += 1
	else:
		timer.stop()
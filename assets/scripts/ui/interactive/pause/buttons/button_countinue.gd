extends Button

@onready var main = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

func _on_pressed() -> void:
	if blur.state:
		if pause.paused:
			pause.close()
			player.check_switch()
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_mouse_entered():
	if blur.state:
		if pause.paused:
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/hover.ogg')
			audio.play()
			if cursor:
				cursor.set_cursor(cursor.states.ACTIVE)

func _on_mouse_exited():
	if cursor:
		cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(node) -> void:
	node.queue_free()

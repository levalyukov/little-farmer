extends Button

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")

func _on_pressed() -> void:
	if blur.state:
		if pause.paused:
			blackout.blackout(true)
			if main == "Farm":
				if visible:
					data.gamesave()
			blackout.change_scene("res://levels/menu.tscn")
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
			
func _on_audio_finished(node) -> void:
	node.queue_free()

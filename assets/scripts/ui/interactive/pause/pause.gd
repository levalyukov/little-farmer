extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var ui:CanvasLayer = get_node("/root/"+main+"/UI")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var options:Control = get_node("/root/"+main+"/UI/Interactive/Options")
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var zoom:Camera2D = get_node("/root/"+main+"/Player/Camera2D")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var mailbox:Node2D = get_node('/root/'+main+'/ConstructionManager/mailbox')
@onready var constructionManager:Node2D = get_node('/root/'+main+'/ConstructionManager')
@onready var farmingManager:Node2D = get_node('/root/'+main+'/FarmingManager')
@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var version:Label = $Main/Container/GameVersionMargin/GameVersion

@onready var buttonCountinue:Button = $Main/Container/CountinueButtonMargin/CountinueButton
@onready var buttonSettings:Button = $Main/Container/SettingsButtonMargin/SettingsButton
@onready var buttonBugReport:Button = $Main/Container/ReportBugButtonMargin/ReportBugButton
@onready var buttonExit:Button = $Main/Container/ExitButtonMargin/ExitButton

var paused:bool
var other_menu:bool

func _ready():
	player.switch = true
	player.check_switch()
	await get_tree().create_timer(0.75).timeout
	player.switch = true
	zoom.is_zooming = false
	zoom.is_changing_zoom = true
	blackout.blackout(false)
	await get_tree().create_timer(0.25).timeout
	hud.hud_all_show()
	player.switch = false
	player.check_switch()
	clock.clock_update()
	_check_window()

func _input(_event):
	if Input.is_action_just_pressed("esc"):
		if !other_menu:
			if !paused:
				open()
			else:
				close()

func open() -> void:
	paused = true
	anim.play("open")
	blur.blur(true)
	hud.hud_all_hide()
	player.check_switch()
	version.text = "v" + ProjectSettings.get_setting("application/config/version") + "\n(C) Studio Miroro"
	if has_node("/root/"+main+"/ConstructionManager/Grid"):
		grid.visible = false
	if destroy_menu.opened:
		destroy_menu.close()

	if GameLoader.get_children() != []:
		for timer in GameLoader.get_children():
			if !timer.is_paused():
				timer.set_paused(true)
	if main == 'Farm':
		for i in get_tree().root.get_child(2).get_children():
			match i.name:
				'MusicPlayer':
					i.set_stream_paused(true)
				'MusicCooldownTimer':
					if i.is_paused():
						i.set_paused(false)
		if mailbox:
			if mailbox.indicator.visible:
				if mailbox.anim.is_playing():
					mailbox.anim.stop()

		# For plants
		check_plants_state(true)
		# For forges
		check_forges_state()
	
		
func close() -> void:
	paused = false
	anim.play("close")
	blur.blur(false)
	hud.hud_all_show()
	player.check_switch()
	if GameLoader.get_children() != []:
		for timer in GameLoader.get_children():
			if timer.is_paused():
				timer.set_paused(!true)
	if main == 'Farm':
		for i in get_tree().root.get_child(2).get_children():
			match i.name:
				'MusicPlayer':
					i.set_stream_paused(!true)
				'MusicCooldownTimer':
					if !i.is_paused():
						i.set_paused(true)
		if mailbox:
			if mailbox.indicator.visible:
				if !mailbox.anim.is_playing():
					mailbox.anim.play()

		check_plants_state(false)
		check_forges_state()

func check_plants_state(state_plant:bool) -> void:
	if farmingManager:
		if farmingManager.get_children().size() > 0:
			for plants in farmingManager.get_children():
				plants.timer.set_paused(state_plant)
				plants.check_water_timer.set_paused(state_plant)
				if state_plant:
					if plants.indicator.visible:
						if plants.anim.is_playing():
							plants.anim.pause()
				else:
					if plants.indicator.visible:
						if !plants.anim.is_playing():
							plants.anim.play()

func check_forges_state() -> void:
	if constructionManager:
		if constructionManager.get_children().size() > 0:
			for node in constructionManager.get_children():
				if node:
					if 'blueprint_id' in node:
						if node.blueprint_id == 9:
							match paused:
								true:
									if node.particles && node.particles.emitting:
											if node.particles.speed_scale > 0.0:
												node.particles.speed_scale = 0.0
								false:
									if node.particles && node.particles.emitting:
											if node.particles.speed_scale == 0.0:
												node.particles.speed_scale = 0.5

func _check_window() -> void:
	visible = paused

func _on_report_bug_button_pressed():
	if visible:
		if data:
			if data.has_method('open_url'):
				data.open_url("https://forms.gle/GiVAMdDLAZFgt9aZA")
				var audio = AudioStreamPlayer.new()
				self.add_child(audio)
				audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
				audio.stream = load('res://assets/sounds/ui/click.ogg')
				audio.play()

func _on_report_bug_button_mouse_entered():
	if blur.state:
		if paused:
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/hover.ogg')
			audio.play()
			if cursor:
				cursor.set_cursor(cursor.states.ACTIVE)
			
func _on_report_bug_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(node) -> void:
	node.queue_free()
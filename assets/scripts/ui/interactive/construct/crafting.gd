extends Button

@onready var main = str(get_tree().root.get_child(3).name)
@onready var data = get_node("/root/" + main)
@onready var pause: Control = get_node("/root/" + main + "/UI/Interactive/Pause")
@onready var notice: Control = get_node("/root/" + main + "/UI/Feedback/Notifications")
@onready var hud: Control = get_node("/root/" + main + "/UI/HUD/GameHud")
@onready var inventory: Control = get_node("/root/" + main + "/UI/Interactive/Inventory")
@onready var craft: Control = get_node("/root/" + main + "/UI/Interactive/ConstructMenu")
@onready var blur: Control = get_node("/root/" + main + "/UI/Decorative/Blur")
@onready var grid: Node2D = get_node("/root/" + main + "/ConstructionManager/Grid")
@onready var cursor: Node2D = get_node("/root/" + main + "/UI/HUD/Cursor")

var items: Object = Items.new()
var blueprints: Object = BlueprintManager.new()

var disable: bool
var group: String
var id: int


func _on_pressed():
	if visible:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load("res://assets/sounds/ui/click.ogg")
		audio.play()
		if blueprints.content.has(group):
			match group:
				"nodes":
					if blueprints.content[group].has(id):
						if blueprints.content[group][id]["config"].has("area"):
							grid.group = group
							grid.id = id
							grid.grid_dimensions = blueprints.content[group][id]["config"]["area"]
							grid.mode = grid.modes.BUILD
							grid.visible = true
							grid.generate_grid()
							craft.close()
							hud.hud_all_hide()
						else:
							data.debug("The key element is missing - 'area'", "error")
							reset_grid_data()
							return
					else:
						data.debug("Invalid blueprint ID: " + str(id), "error")
						return
				"terrains":
					if blueprints.content[group].has(id):
						if blueprints.content[group][id]["config"].has("terrain"):
							grid.group = group
							grid.id = id
							grid.terrain_set = blueprints.content[group][id]["config"]["terrain"]
							grid.terrain_required_layer = (blueprints.content[group][id]["config"]["required_layer"])
							grid.terrain_blocking_layer = (blueprints.content[group][id]["config"]["blocking_layer"])
							grid.mode = grid.modes.TERRAIN_SET
							grid.visible = true
							grid.grid_dimensions = Vector2i(1, 1)
							grid.generate_grid()
							craft.close()
							hud.hud_all_hide()
						else:
							data.debug("The key element is missing - 'terrain'", "error")
							reset_grid_data()
							return
					else:
						data.debug("Invalid blueprint ID: " + str(id), "error")
						return
		else:
			data.debug("Invalid blueprint group: " + str(group), "error")
			return


func reset_grid_data() -> void:
	grid.node_id = 0
	grid.mode = grid.modes.NOTHING
	grid.building_group = ""
	grid.node_source = null
	grid.node_shadow = null
	grid.terrain_set = 0
	grid.node_upgrade = null
	grid.visible = false


func _on_mouse_entered():
	if visible && !disabled:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load("res://assets/sounds/ui/hover.ogg")
		audio.play()
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)


func _on_mouse_exited():
	if visible:
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)


func _on_audio_finished(node) -> void:
	node.queue_free()

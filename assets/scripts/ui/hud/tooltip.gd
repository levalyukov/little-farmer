class_name Tooltip extends Control

@onready var background: NinePatchRect = $Container/Background
@onready var container: MarginContainer = $Container
@onready var content: Label = $Container/MarginContainer/Label
const OFFSET: int = 32


func _init() -> void:
	self.visible = false


func tip(text: String = "") -> void:
	if text.is_empty():
		self.visible = false
		return

	content.text = text
	self.visible = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var screen_width: float = get_viewport_rect().size.x
		var mouse_global_pos: Vector2 = get_global_mouse_position()
		var edge: Vector2 = Vector2(mouse_global_pos.x, mouse_global_pos.y)
		var threshold: Vector2 = Vector2(background.size.x, background.size.y)

		if (edge.x > screen_width - threshold.x) && !(edge.y < threshold.y):
			self.set_position(Vector2(mouse_global_pos.x - container.size.x, mouse_global_pos.y))

		elif edge.y < threshold.y && !(edge.x > screen_width - threshold.x):
			self.set_position(Vector2(mouse_global_pos.x, mouse_global_pos.y + container.size.y + OFFSET))

		elif (edge.y < threshold.y) && (edge.x > screen_width - threshold.x):
			self.set_position(
				Vector2(mouse_global_pos.x - container.size.x, mouse_global_pos.y + container.size.y + OFFSET)
			)

		else:
			self.set_position(mouse_global_pos)

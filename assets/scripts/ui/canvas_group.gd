extends CanvasGroup

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var collision = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var cloud_canvas:CanvasGroup = get_node("/root/"+main+"/ShadowManager/CloudGroup")

const alpha = .15
const color = Color(0,0,0,alpha)

func _ready():
	z_index = 1
	if color is Color:
		self.self_modulate = color
	if cloud_canvas:
		cloud_canvas.self_modulate = color

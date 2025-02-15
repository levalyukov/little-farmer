extends CanvasGroup

@onready var main:String = GameData.main
@onready var collision = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")

const alpha = .15
const color = Color(0,0,0,alpha)

func _ready():
	z_index = 3
	if color is Color:
		self.self_modulate = color
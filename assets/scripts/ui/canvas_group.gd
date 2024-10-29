extends CanvasGroup

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var collision = get_node("/root/"+main+"/ConstructionManager/Grid/GridCollision")

const alpha = .15
const color = Color(0,0,0,alpha)

func _ready():
	if has_node("/root/"+main+"/ConstructionManager/Grid/GridCollision")\
	&& color is Color:
		self.self_modulate = color
		z_index = collision.shadow_layer
	else:
		z_index = 6
		self.self_modulate = color
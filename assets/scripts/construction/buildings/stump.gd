extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@export var sprites_caption:String = ''

func _ready():
	if self:
		var target_sprite = load('res://assets/resources/buildings/'+sprites_caption+'.png')
		var shadow_sprite = load('res://assets/resources/buildings/'+sprites_caption+'_shadow.png')
		if target_sprite:
			if target_sprite is CompressedTexture2D:
				self.texture = target_sprite
				if shadow_sprite:
					if shadow_sprite is CompressedTexture2D:
						canvas.create_shadow(
							self.name+"_shadow", 
							shadow_sprite, 
							tilemap.local_to_map(self.position),
							true
						)

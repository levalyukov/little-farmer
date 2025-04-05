extends Sprite2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")

func _ready():
	if self:
		match data.remove_suffix(self.name):
			'garden':
				if clock:
					match clock.get_season():
						'spring':
							self.texture = load('res://assets/resources/buildings/garden/obj_0.png')
							if !self.visible: self.visible = true
						'summer':
							self.texture = load('res://assets/resources/buildings/garden/obj_1.png')
							if !self.visible: self.visible = true
						'autumn':
							self.texture = load('res://assets/resources/buildings/garden/obj_2.png')
							if !self.visible: self.visible = true
						'winter':
							if self.visible: self.visible = false
			'big_garden_decor_village':
				if clock:
					match clock.get_season():
						'spring':
							self.texture = load('res://assets/resources/buildings/big_garden_village/obj_0.png')
							if !self.visible: self.visible = true
						'summer':
							self.texture = load('res://assets/resources/buildings/big_garden_village/obj_1.png')
							if !self.visible: self.visible = true
						'autumn':
							self.texture = load('res://assets/resources/buildings/big_garden_village/obj_2.png')
							if !self.visible: self.visible = true
						'winter':
							if self.visible: self.visible = false
			'microgarden':
				if clock:
					match clock.get_season():
						'spring':
							self.texture = load('res://assets/resources/buildings/garden/_obj_0.png')
							if !self.visible: self.visible = true
						'summer':
							self.texture = load('res://assets/resources/buildings/garden/_obj_1.png')
							if !self.visible: self.visible = true
						'autumn':
							self.texture = load('res://assets/resources/buildings/garden/_obj_2.png')
							if !self.visible: self.visible = true
						'winter':
							if self.visible: self.visible = false

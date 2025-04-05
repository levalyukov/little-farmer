extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D

@export var index:int = 0

func _ready() -> void:
	if self:
		if clock:
			if clock.get_season() != 'winter':
				var target_texture = load("res://assets/resources/world/water/water_lily/lily_"+str(index)+".png")
				sprite.texture = target_texture
				if !self.visible:
					self.visible = true
			else:
				if self.visible:
					self.visible = false

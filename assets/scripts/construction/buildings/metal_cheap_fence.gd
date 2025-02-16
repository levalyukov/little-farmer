extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var tradeMenu:Control = get_node("/root/"+main+"/UI/Interactive/TradeMenu")
@onready var sprite:Sprite2D = $Sprite2D

var object:Dictionary = {
	"default" = load("res://assets/resources/buildings/metal_cheap_fence/obj_0.png"),
}

func _ready():
	update()
	#	update_shadow()

func update():
	if clock:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
					else:
						data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no '" + str(season) + "' key in the 'seasons' group.", "error")
		else:
			if object.has("default"):
				if object["default"] is CompressedTexture2D:
					sprite.texture = object["default"]
				else:
					data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no 'default' key.", "error")

func update_shadow() -> void:
	if visible:
		if object.has("shadow"):
			if object["shadow"] is CompressedTexture2D:
				canvas.create_shadow("metal_cheap_fence_shadow", object["shadow"], tilemap.local_to_map(position))
			else:
				data.debug("'"+str(self.name) + "': It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")

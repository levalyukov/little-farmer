extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")

@onready var player_inventory:GridContainer = $Content/PlayerInventory/PlayerContainer/VBoxContainer/MarginContainer/GridContainer
@onready var trade_window:GridContainer =  $Content/TradeWindow/TradeWindow/VBoxContainer/ItemsContainer/GridMarginContainer/GridContainer
@onready var trade_window_header:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/HeaderContainer/Header
@onready var trade_window_target_price:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/TargetPriceContainer/TargetPrice
@onready var trade_window_button:Button = $Content/TradeWindow/TradeWindow/VBoxContainer/ButtonContainer/Button
@onready var trader_inventory:GridContainer = $Content/TraderInventory/PlayerContainer/VBoxContainer/MarginContainer/GridContainer

var all_items:Object = Items.new()
var window_visible:bool = false

func open_trade_menu() -> void:
    # Code...
    pass

func close_trade_menu() -> void:
    # Code...
    pass

func get_player_inventory() -> void:
    # Code...
    pass

func get_npc_inventory() -> void:
    # Code...
    pass

func update_trade_menu() -> void:
    # Code...
    pass

func _update_window_visible() -> void:
    visible = window_visible
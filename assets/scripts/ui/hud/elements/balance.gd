extends Control

@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/balance.png")
@onready var icon:TextureRect = $Margin/HBoxContainer/Icon/TextureRect
@onready var text:Label = $Margin/HBoxContainer2/Label/Label

const maximum:int = 999_999_999
const minimum:int = 0
var money:int = 0

func _ready():
	icon.texture = sprite

func balance_update() -> void:
	check_balance(money)
	text.text = format(money)

func set_money(amount:int = 0) -> void:
	self.money = amount
	balance_update()

func add_money(amount:int = 0) -> void:
	if amount > 0 && amount <= maximum:
		self.money += amount
		balance_update()

func remove_money(amount:int = 0) -> void:
	if amount > 0 && amount <= maximum:
		self.money -= amount
		balance_update()

func check_balance(balance) -> void:
	if balance < minimum:
		self.money = minimum
		balance_update()
	if balance > maximum:
		self.money = maximum
		balance_update()

func format(number:int) -> String:
	if number > minimum:
		if number <= maximum:
			var num_str = str(number)
			var separator = ","
			var result = ""
			var count = 0
			
			for i in range(num_str.length() - 1, -1, -1):
				result = num_str[i] + result
				count += 1
				if count % 3 == 0 and i != 0:
					result = separator + result
					
			return result
		return "999,999,999"
	return "0"
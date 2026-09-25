extends Node


func add_item(id: int, amount: int = 1) -> void:
	if !Items.items.has(id):
		printerr("Invalid item id")
		return

	if (
		PlayerControl.inventory.has(id)
		&& PlayerControl.inventory[id]["amount"] is int
		&& PlayerControl.inventory[id]["amount"] > 0
	):
		PlayerControl.inventory[id]["amount"] += amount
	else:
		PlayerControl.inventory.merge({id: {"amount": amount}})


func get_item_amount(id: int) -> int:
	return PlayerControl.inventory[id]["amount"] if PlayerControl.inventory.has(id) else 0


func subject_item(id: int, amount: int = 1) -> void:
	if !Items.items.has(id):
		printerr("Invalid item id")
		return

	if (
		PlayerControl.inventory.has(id)
		&& PlayerControl.inventory[id]["amount"] is int
		&& PlayerControl.inventory[id]["amount"] > 0
	):
		PlayerControl.inventory[id]["amount"] -= amount
	else:
		PlayerControl.inventory.erase(id)

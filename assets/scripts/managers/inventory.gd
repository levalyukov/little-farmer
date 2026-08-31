extends Node


func add_item(id: int, amount: int) -> void:
	if !Items.items.has(id):
		return

	if PlayerControl.inventory.has(id):
		PlayerControl.inventory[id]["amount"] += amount
	else:
		PlayerControl.inventory.merge({id: {"amount": amount}})


func subject_item(id: int, amount: int) -> void:
	if !Items.items.has(id):
		return

	if (
		PlayerControl.inventory.has(id)
		&& PlayerControl.inventory[id]["amount"] is int
		&& PlayerControl.inventory[id]["amount"] > 0
	):
		PlayerControl.inventory[id]["amount"] -= amount
	else:
		PlayerControl.inventory.erase(id)

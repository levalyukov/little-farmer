extends Node

var start:bool = false
var mode:bool

func loading(transfer_data:bool) -> void:
	mode = transfer_data

func gamestart(transfer_data:bool) -> void:
	start = transfer_data
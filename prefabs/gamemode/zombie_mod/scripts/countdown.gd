extends Node

const START: int = 20
var value: int = START : set = set_value

signal on_value_changed()

func set_value(new: int) -> void:
	value = new
	on_value_changed.emit()

func _ready() -> void:
	SimusNetVars.register(
		self,
		["value"]
	)

func restart() -> void:
	value = START
	

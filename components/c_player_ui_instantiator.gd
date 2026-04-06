extends Node
class_name C_PlayerUIInstantiator

@export var _scenes: Array[PackedScene] = []

func _ready() -> void:
	if SimusNet.is_network_authority(self):
		for i in _scenes:
			add_child(i.instantiate())

extends Node
class_name C_PlayerUIInstantiator

@export var _player: Player
@export var _scenes: Array[PackedScene] = []

func _ready() -> void:
	await SD_Nodes.async_for_ready(_player)
	
	if _player.is_local():
		for i in _scenes:
			add_child(i.instantiate())

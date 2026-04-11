extends Control

@export var countdown: Node

func _ready() -> void:
	$Label.text = int(countdown.value)
	countdown.on_value_changed.connect(_update)

func _update() -> void:
	$Label.text = int(countdown.value)

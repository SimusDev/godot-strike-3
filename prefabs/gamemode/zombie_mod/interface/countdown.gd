extends Control

@export var countdown: Node

@export var _audio: Array[AudioStream]

func _ready() -> void:
	$Label.text = str(countdown.value)
	countdown.on_value_changed.connect(_update)

func _update() -> void:
	$Label.text = str(countdown.value)
	$AudioStreamPlayer.stream = _audio.pick_random()
	$AudioStreamPlayer.play()

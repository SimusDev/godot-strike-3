@tool
extends Node3D
class_name C_AudioPlayer3D

@export var volume: float = 1.0
@export var max_distance: float = 0.0
@export var unit_size: int = 10.0
@export var pitch_scale: float = 1.0
@export var bus: String = "Master"

func create_player() -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.volume_linear = volume
	player.max_distance = max_distance
	player.unit_size = unit_size
	player.pitch_scale = pitch_scale
	player.bus = bus
	return player

func try_play(stream: AudioStream) -> AudioStreamPlayer3D:
	if !stream:
		return null
	
	if !Engine.is_editor_hint():
		if SimusNetConnection.is_dedicated_server():
			return null
	
	return play_anyway(stream)

func play_anyway(stream: AudioStream) -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = create_player()
	player.stream = stream
	player.finished.connect(player.queue_free)
	add_child(player)
	if Engine.is_editor_hint():
		player.owner = self
	
	player.playing = true
	return player
	

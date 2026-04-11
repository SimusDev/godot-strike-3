#s_AudioPlayer singleton
extends Node

func _ready() -> void:
	SimusNetRPC.register(
		[
			local_play_global
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func play_global(stream:AudioStream, properties:Dictionary = {}) -> void:
	local_play_global(stream, properties)
	SimusNetRPC.invoke(local_play_global, stream, properties)

func local_play_global(stream:AudioStream, properties:Dictionary = {}) -> void:
	var new_ap:AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_ap.stream = stream
	get_tree().root.add_child(new_ap)
	
	for prop in properties:
		new_ap.set(prop, properties.get(prop))
	
	new_ap.play()
	
	new_ap.finished.connect(new_ap.queue_free)

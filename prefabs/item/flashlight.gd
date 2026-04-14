extends Node3D

@onready var _audio_stream_player_3d: AudioStreamPlayer3D = $_AudioStreamPlayer3D

func _ready() -> void:
	visible = false
	
	SimusNetRPC.register(
		[
			_change_visibility,
		], SimusNetRPCConfig.new().flag_mode_authority()
	)
	
	SimusNetVars.register(
		self,
		[
			"visible"
		]
	)
	
	visible = await SimusNetVars.replicate_async(self, "visible")

func _input(event: InputEvent) -> void:
	if SimusDev.ui.has_active_interface():
		return
	
	if Input.is_action_just_pressed("flashlight"):
		if SimusNet.is_network_authority(self):
			SimusNetRPC.invoke_all(_change_visibility, !visible)

func _change_visibility(new: bool) -> void:
	visible = new
	_audio_stream_player_3d.play()
	

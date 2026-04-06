extends C_Item3D
class_name C_MeleeWeapon3D

@export var _animation_player: AnimationPlayer

@export var _animation_pickup: StringName = ""
@export var _animation_swing: StringName = ""
@export var _animation_swing_alt: StringName = ""

#var _cooldown: SD_CooldownTimer = SD_CooldownTimer.new()

func _ready() -> void:
	super()
	_play_animation(_animation_pickup)
	
	SimusNetRPC.register(
		[
			_swing_rpc,
			_swing_alt_rpc,
		], SimusNetRPCConfig.new().flag_mode_server_only().
		flag_set_channel(s_Networking.CHANNELS.SHOOTING)
	)

func _physics_process(delta: float) -> void:
	if !SimusNetConnection.is_server():
		return
	
	if active_actions.has(ACTION_USE):
		swing()
		return
	
	if active_actions.has(ACTION_USE_ALT):
		swing_alt()
	

func _play_animation(anim: StringName) -> void:
	if !_animation_player:
		return
	
	_animation_player.stop()
	_animation_player.play(anim, 0.5)

func swing() -> void:
	if !SimusNetConnection.is_server():
		return
	
	if _animation_player.is_playing():
		return
	
	SimusNetRPC.invoke_all(_swing_rpc)

func swing_alt() -> void:
	if !SimusNetConnection.is_server():
		return
	
	if _animation_player.is_playing():
		return
	
	SimusNetRPC.invoke_all(_swing_alt_rpc)

func _swing_rpc() -> void:
	_play_animation(_animation_swing)

func _swing_alt_rpc() -> void:
	_play_animation(_animation_swing_alt)

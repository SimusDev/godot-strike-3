extends C_Item3D
class_name C_FirearmWeapon3D

@export var _animation_player: AnimationPlayer

@export var _animations_pickup: Array[StringName]
@export var _animations_shoot: Array[StringName]
@export var _animations_reload: Array[StringName]

var _shoot_cooldown: SD_CooldownTimer = SD_CooldownTimer.new()

func get_object() -> R_FireArmWeapon:
	return super() as R_FireArmWeapon

func _ready() -> void:
	super()
	
	SimusNetRPC.register(
		[
			_shoot_local,
			_reload_local,
		], SimusNetRPCConfig.new()
		.flag_mode_server_only()
		.flag_set_channel(s_Networking.CHANNELS.SHOOTING)
		.flag_immediate()
	)
	
	SimusNetRPC.register(
		[
			_request_reload,
		], SimusNetRPCConfig.new()
		.flag_mode_authority()
		.flag_set_channel(s_Networking.CHANNELS.SHOOTING)
		.flag_immediate()
	)
	
	_play_animation(_animations_pickup.pick_random())

func _play_animation(anim: StringName) -> void:
	if !_animation_player:
		return
	
	_animation_player.stop()
	_animation_player.play(anim, 0.5)

func _process(delta: float) -> void:
	if !SimusNetConnection.is_server():
		return
	
	if active_actions.has(ACTION_USE):
		shoot()

func _input_local(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		SimusNetRPC.invoke_on_server(_request_reload)

func _request_reload() -> void:
	reload()

func reload() -> void:
	if SimusNetConnection.is_server():
		SimusNetRPC.invoke_all(_reload_local)

func _reload_local() -> void:
	_animation_player.play(_animations_reload.pick_random())

func shoot() -> C_FirearmWeapon3D:
	if _shoot_cooldown.is_active():
		return
	
	if SimusNetConnection.is_server():
		SimusNetRPC.invoke_all(_shoot_local)
	return self

func _shoot_local() -> void:
	_shoot_cooldown.start(get_object().cooldown)
	_animation_player.play(_animations_shoot.pick_random())

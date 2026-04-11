extends C_Item3D
class_name C_MeleeWeapon3D

@export var _animation_player: AnimationPlayer

@export var _animation_pickup: StringName = ""
@export var _animation_swing: StringName = ""
@export var _animation_swing_alt: StringName = ""

var _cooldown: SD_CooldownTimer = SD_CooldownTimer.new()

var _raycast: C_EntityRaycastFireArm

var _alt_swing: bool = false

func get_object() -> R_MeleeWeapon:
	return super() as R_MeleeWeapon

func _ready() -> void:
	super()
	
	_raycast = SD_ECS.node_find_above_by_component(self, C_EntityRaycastFireArm)
	
	if !_raycast:
		if player:
			if !player.is_local():
				return
		_logger.debug("Cant Find C_EntityRaycastFireArm above!", SD_ConsoleCategories.ERROR)
	
	_play_animation(_animation_pickup)
	
	SimusNetRPC.register(
		[
			_swing_rpc,
			_swing_alt_rpc,
		], SimusNetRPCConfig.new().flag_mode_server_only().
		flag_set_channel(s_Networking.CHANNELS.SHOOTING).flag_immediate()
	)
	
	SimusNetRPC.register(
		[
			_collided_with
		], SimusNetRPCConfig.new().flag_mode_authority().
		flag_set_channel(s_Networking.CHANNELS.SHOOTING).flag_immediate()
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
	if !SimusNetConnection.is_server() or _cooldown.is_active():
		return
	
	SimusNetRPC.invoke_all(_swing_rpc)
	_cooldown.start(get_object().cooldown)

func swing_alt() -> void:
	if !SimusNetConnection.is_server() or _cooldown.is_active():
		return
	
	SimusNetRPC.invoke_all(_swing_alt_rpc)
	_cooldown.start(get_object().cooldown_alt)

func _swing_rpc() -> void:
	_alt_swing = false
	
	if is_instance_valid(_raycast):
		_raycast.target_position.z = -get_object().swing_range
		_raycast.enabled = true
		_raycast.force_raycast_update()
		_check_collider()
		_raycast.enabled = false
	_play_model_animation_by_array(_use_animations)
	_play_animation(_animation_swing)

func _swing_alt_rpc() -> void:
	_alt_swing = true
	
	if is_instance_valid(_raycast):
		_raycast.target_position.z = -get_object().swing_range_alt
		_raycast.enabled = true
		_raycast.force_raycast_update()
		_check_collider()
		_raycast.enabled = false
	_play_model_animation_by_array(_alt_use_animations)
	_play_animation(_animation_swing_alt)

func _check_collider() -> void:
	if !is_instance_valid(_raycast):
		return
	
	if !SimusNet.is_network_authority(self):
		return
	
	if _raycast.get_collider():
		var collider: Object = _raycast.get_collider()
		if collider is C_EntityHitBox:
			SimusNetRPC.invoke_on_server(_collided_with, collider, _alt_swing)

func _collided_with(hitbox: C_EntityHitBox, is_alt: bool) -> void:
	for i in 10:
		await get_tree().physics_frame
	var damage: float = get_object().swing_damage
	if is_alt:
		damage = get_object().swing_damage_alt
	if is_instance_valid(hitbox):
		hitbox.apply_damage(damage)

extends C_Item3D
class_name C_FirearmWeapon3D

@export var _animation_player: AnimationPlayer

@export var _animations_pickup: Array[StringName]
@export var _animations_shoot: Array[StringName]
@export var _animations_reload: Array[StringName]

@export_group("VFX")
@export var muzzle_flash:GPUParticles3D

var _shoot_cooldown: SD_CooldownTimer = SD_CooldownTimer.new()

var _raycast: C_EntityRaycastFireArm

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
			_bullet_collided_with,
		], SimusNetRPCConfig.new()
		.flag_mode_authority()
		.flag_set_channel(s_Networking.CHANNELS.SHOOTING)
		.flag_immediate()
	)
	
	_raycast = SD_ECS.node_find_above_by_component(self, C_EntityRaycastFireArm)
	
	if !_raycast:
		if player:
			if !player.is_local():
				return
		_logger.debug("Cant Find C_EntityRaycastFireArm above!", SD_ConsoleCategories.ERROR)
	
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
	_play_animation(_animations_shoot.pick_random())
	
	if !_raycast:
		return
	
	if SimusNet.is_network_authority(self):
		_raycast.enabled = true
		_raycast.force_raycast_update()
		
		var collider: Object = _raycast.get_collider()
		var metadata:SD_MetadataMaterial = SD_Metadata.find_of_type(collider, SD_MetadataMaterial)
		var collide_position: Vector3 = _raycast.get_collision_point()
		var collide_normal: Vector3 = _raycast.get_collision_normal()
		
		if collider:
			if collider is C_EntityHitBox:
				SimusNetRPC.invoke_on_server(_bullet_collided_with, collider)
				
			if metadata:
				_collider_spawn_decals(collider, collide_position, collide_normal, metadata)
				_collider_spawn_sound(collider, collide_position, metadata)
		
		_raycast.enabled = false
		
		if muzzle_flash:
			muzzle_flash.emitting = true

func _collider_spawn_decals(collider:Object, collide_position:Vector3, collide_normal:Vector3, metadata:SD_MetadataMaterial) -> void:
	var decal = metadata.get_bullet_impact_decal()
	if not decal:
		return
	
	var decal_inst = decal.instantiate()
	
	collider.add_child(decal_inst)
	
	var y_axis = collide_normal
	var x_axis = Vector3.UP.cross(y_axis).normalized()
	
	if x_axis.length_squared() < 0.001:
		x_axis = Vector3.RIGHT.cross(y_axis).normalized()
	
	var z_axis = x_axis.cross(y_axis).normalized()
	
	decal_inst.global_transform.basis = Basis(x_axis, y_axis, z_axis)
	decal_inst.global_position = collide_position
	
	decal_inst.rotate_object_local(Vector3.UP, randf() * TAU)

func _collider_spawn_sound(collider:Object, collide_position:Vector3, metadata:SD_MetadataMaterial) -> void:
	var sound = metadata.get_bullet_impact_sound()
	if not sound:
		return
	
	var new_ap:AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_ap.stream = sound
	new_ap.max_distance = 25.0
	new_ap.volume_db = -10
	new_ap.finished.connect(new_ap.queue_free)
	get_tree().root.add_child(new_ap)
	new_ap.global_position = collide_position
	new_ap.play()

func _bullet_collided_with(hitbox: C_EntityHitBox) -> void:
	if is_instance_valid(hitbox):
		hitbox.apply_damage(get_object().damage)

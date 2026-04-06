extends Node3D
class_name C_Item3D

var player: Player

var _logger: SD_Logger = SD_Logger.new(self)

var active_actions: PackedStringArray = []

const ACTION_USE: String = "use"
const ACTION_USE_ALT: String = "use_alt"

func is_local() -> bool:
	return is_instance_valid(player)

func _ready() -> void:
	player = SD_ECS.node_find_above_by_script(self, Player)
	if player:
		await SD_Nodes.async_for_ready(player)
	
	SimusNetRPC.register(
		[
			_press_action_local_internal,
			_release_action_local_internal,
		], SimusNetRPCConfig.new().flag_set_channel(s_Networking.CHANNELS.ITEM)
	)
	
	SimusNetVars.register(
		self,
		[
			"active_actions"
		], SimusNetVarConfig.new().flag_reliable(s_Networking.CHANNELS.ITEM)
		
	)
	
	SimusNetVars.replicate(self, "active_actions")
	
	set_process_input(is_local())

func _input(event: InputEvent) -> void:
	if !player:
		return
	
	if !player.is_local():
		return
	
	if Input.is_action_just_pressed("item.use"):
		press_action(ACTION_USE)
	if Input.is_action_just_released("item.use"):
		release_action(ACTION_USE)
	
	if Input.is_action_just_pressed("item.use_alt"):
		press_action(ACTION_USE_ALT)
	if Input.is_action_just_released("item.use_alt"):
		release_action(ACTION_USE_ALT)

func press_action(action: String) -> void:
	SimusNetRPC.invoke_all(_press_action_local_internal, action)

func release_action(action: String) -> void:
	SimusNetRPC.invoke_all(_release_action_local_internal, action)

func _press_action_local_internal(action: String) -> void:
	if active_actions.has(action):
		return
	
	active_actions.append(action)
	_press_action_local(action)

func _release_action_local_internal(action: String) -> void:
	if !active_actions.has(action):
		return
	
	active_actions.erase(action)
	_release_action_local(action)

func _press_action_local(action: String) -> void:
	_logger.debug("action pressed %s" % action)

func _release_action_local(action: String) -> void:
	_logger.debug("action released %s" % action)

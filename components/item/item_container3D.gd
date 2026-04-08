extends Node3D
class_name C_ItemContainer3D

@export var root: Node3D
@export var type: R_ViewModel.TYPE = R_ViewModel.TYPE.VIEW
@export var _objects: Array[R_WorldObject] = []
@export var _object: R_WorldObject : set = set_object


@export_group("Optional")
@export var player: Player

var _ref: Node

var _logger := SD_Logger.new(self)

var _cooldown: SD_CooldownTimer = SD_CooldownTimer.new()

const INPUTS: Array[StringName] = [
	"slot1",
	"slot2",
	"slot3",
	"slot4",
	"slot5",
	"slot6",
	"slot7",
	"slot8",
	"slot9",
	"slot0",
]

func _ready() -> void:
	SimusNetVars.register(
		self, [
			"_object"
		], SimusNetVarConfig.new().flag_mode_server_only().
		flag_reliable(s_Networking.CHANNELS.ITEM)
		.flag_replication()
	)
	
	SimusNetRPC.register(
		[
			_request_switch_rpc,
		], SimusNetRPCConfig.new().
		flag_mode_to_server()
		.flag_require_ownership()
		.flag_set_channel(s_Networking.CHANNELS.ITEM)
	)
	
	await SD_Nodes.async_for_ready(root)
	
	var enable_input: bool = false
	if root is Player:
		player = root
	
	if player:
		await SD_Nodes.async_for_ready(player)
		enable_input = player.is_local()
		visible = player.is_local()
	else:
		hide()
	
	
	set_process_input(enable_input)

func _input(event: InputEvent) -> void:
	if SimusDev.ui.has_active_interface():
		return
	
	for i in INPUTS:
		if Input.is_action_just_pressed(i):
			request_switch(INPUTS.find(i))

func request_switch(slot: int) -> void:
	SimusNetRPC.invoke_on_server(_request_switch_rpc, slot)

func _request_switch_rpc(slot: int) -> void:
	if slot > _objects.size() - 1 or _objects.is_empty():
		return
	
	if _cooldown.is_active():
		return
	
	set_object(_objects[slot])
	_cooldown.start(0.2)

func set_object(object: R_WorldObject) -> void:
	if _object == object:
		return
	
	_object = object
	
	if !is_node_ready():
		await ready
	
	if is_instance_valid(_ref):
		_ref.queue_free()
		
		if _ref.is_inside_tree():
			await _ref.tree_exited
	
	if !is_instance_valid(object):
		return
	
	if !object.viewmodel:
		_logger.debug("%s viewmodel is null!" % object, SD_ConsoleCategories.WARNING)
		#return
	
	if object.viewmodel:
		_ref = object.viewmodel.instantiate_by_type(type)
		if is_instance_valid(_ref):
			_ref.set_multiplayer_authority(get_multiplayer_authority())
			object.set_in(_ref)
			add_child(_ref, true)
	

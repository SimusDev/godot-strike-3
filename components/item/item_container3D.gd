extends Node3D
class_name C_ItemContainer3D

@export var type: R_ViewModel.TYPE = R_ViewModel.TYPE.VIEW
@export var _objects: Array[R_WorldObject] = []

@export_group("Optional")
@export var player: Player

@export var _object: R_WorldObject : set = set_object

var _ref: Node

func _ready() -> void:
	var enable_input: bool = false
	if player:
		enable_input = player.is_local()
	
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
	
	set_process_input(enable_input)

func request_switch(slot: int) -> void:
	SimusNetRPC.invoke_on_server(_request_switch_rpc, slot)

func _request_switch_rpc(slot: int) -> void:
	if slot > _objects.size() - 1:
		return
	
	

func set_object(object: R_WorldObject) -> void:
	if _object == object:
		return
	
	if !is_node_ready():
		await ready
	
	if is_instance_valid(_ref):
		_ref.queue_free()
		
		if _ref.is_inside_tree():
			await _ref.tree_exited
	

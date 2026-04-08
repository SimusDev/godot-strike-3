extends Node
class_name C_NodeReplicator

@export var roots: Array[Node]

signal on_start_replication_finish()

var is_start_replication_finished: bool = false

@onready var _logger: SD_Logger = SD_Logger.new(self)

func _ready() -> void:
	SimusNetRPC.register(
		[
			_server_receive
		], SimusNetRPCConfig.new().
		flag_mode_to_server()
		.flag_set_channel(s_Networking.CHANNELS.NODE_REPLICATION)
	)
	
	SimusNetRPC.register(
		[
			_receive_node,
			_receive_node_single,
			_receive_node_deletion,
		], SimusNetRPCConfig.new().
		flag_mode_server_only()
		.flag_set_channel(s_Networking.CHANNELS.NODE_REPLICATION)
	)
	
	SimusNetConnection.connect_network_node_callables(
		self,
		_on_network_ready,
		_on_network_disconnect,
		_on_network_not_connected
	)
	

func _on_network_ready() -> void:
	if SimusNetConnection.is_server():
		for root in roots:
			root.child_entered_tree.connect(_on_root_child_entered_tree.bind(root))
			root.child_exiting_tree.connect(_on_root_child_exiting_tree.bind(root))
		
		return
	
	for root in roots:
		await SD_Nodes.clear_all_children(root)
	
	is_start_replication_finished = false
	SimusNetRPC.invoke_on_server(_server_receive)

func _on_network_disconnect() -> void:
	if SimusNetConnection.is_was_server():
		for root in roots:
			root.child_entered_tree.disconnect(_on_root_child_entered_tree)
			root.child_exiting_tree.disconnect(_on_root_child_exiting_tree)

func _on_network_not_connected() -> void:
	pass

func _server_receive() -> void:
	var node_count: int = 0
	
	for root in roots:
		for child in root.get_children():
			if I_ReplicatedNode.can_replicate(child):
				node_count += 1
		
		for child in root.get_children():
			if I_ReplicatedNode.can_replicate(child):
				SimusNetRPC.invoke_on_sender(_receive_node, 
				roots.find(root), 
				node_count,
				I_ReplicatedNode.new(child)
				)
			

func _receive_node(root_id: int, node_count: int, node: I_ReplicatedNode) -> void:
	var root: Node = roots.get(root_id)
	if !root:
		return
	
	root.add_child(node.get_node())
	
	if !is_start_replication_finished:
		var replicated: int = 0
		for i in roots:
			replicated += i.get_child_count()
		
		if replicated >= node_count:
			on_start_replication_finish.emit()
			is_start_replication_finished = true
			_logger.debug("All Nodes Replicated.", SD_ConsoleCategories.INFO)

func _receive_node_single(root_id: int, node: I_ReplicatedNode) -> void:
	var root: Node = roots.get(root_id)
	root.add_child(node.get_node())

func _receive_node_deletion(root_id: int, _name: String) -> void:
	var root: Node = roots.get(root_id)
	if !root:
		return
	
	var node: Node = root.get_node(_name)
	if node:
		node.queue_free()

func _on_root_child_entered_tree(node: Node, root: Node) -> void:
	await SD_Nodes.async_for_ready(node)
	await get_tree().physics_frame
	
	if I_ReplicatedNode.can_replicate(node):
		SimusNetRPC.invoke(_receive_node_single, roots.find(root), I_ReplicatedNode.new(node))

func _on_root_child_exiting_tree(node: Node, root: Node) -> void:
	await get_tree().physics_frame
	SimusNetRPC.invoke(_receive_node_deletion, root.get_path_to(node))
	

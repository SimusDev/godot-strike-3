extends RefCounted
class_name I_ReplicatedNode

var _node: Node

func _init(node: Node = null) -> void:
	_node = node

func get_node() -> Node:
	return _node

static func can_replicate(node: Node) -> bool:
	return !node.scene_file_path.is_empty()

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	buffer.pack(load(_node.scene_file_path))
	_node.name = _node.name.validate_node_name()
	buffer.pack(_node.name)
	buffer.pack(_node.get_multiplayer_authority())
	buffer.pack("transform" in _node)
	if "transform" in _node:
		buffer.pack(_node.transform)

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	var scene: PackedScene = buffer.unpack()
	var node: Node = scene.instantiate()
	node.name = buffer.unpack()
	var authority: int = buffer.unpack()
	node.set_multiplayer_authority(authority)
	var has_transform: bool = buffer.unpack()
	
	if has_transform:
		var transform: Variant = buffer.unpack()
		node.transform = transform
	
	var result: I_ReplicatedNode = I_ReplicatedNode.new(node)
	buffer.set_result(result)

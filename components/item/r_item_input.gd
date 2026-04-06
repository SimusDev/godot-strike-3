extends Resource
class_name R_ItemAction

var id: StringName

var _item: C_Item3D

func _init(_id: StringName = "") -> void:
	id = _id

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	if is_instance_valid(_item):
		buffer.pack(_item._actions.find(self))

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	pass

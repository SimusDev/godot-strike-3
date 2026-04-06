extends Resource
class_name R_User

var name: String
var peer_id: int = -1

var _is_raw_object: bool = false

func _ready() -> void:
	SimusNetIdentity.register(self)

func as_raw_object() -> R_User:
	var raw: R_User = duplicate()
	raw._is_raw_object = true
	return raw

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	buffer.pack(_is_raw_object)
	if _is_raw_object:
		buffer.pack(SimusNetIdentity.register(self).get_unique_id())
		buffer.pack(name)
		buffer.pack(peer_id)
	else:
		buffer.pack(self)

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	var is_raw_object: bool = buffer.unpack()
	if not is_raw_object:
		var user: R_User = buffer.unpack()
		buffer.set_result(user)
		return 
	
	var user: R_User = R_User.new()
	var network_id: int = buffer.unpack()
	SimusNetIdentity.register(user, network_id)
	user.name = buffer.unpack()
	user.peer_id = buffer.unpack()
	buffer.set_result(user)
	

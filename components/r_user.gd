extends Resource
class_name R_User

@export var name: String
@export var login: String
@export var password: String
@export var peer_id: int = -1

var _is_raw_object: bool = false

var _ping_server_ticks: float = 0.0
var _ping: int = 0

func get_ping() -> int:
	return _ping

@export var _network_id: int = -1

func get_multiplayer_authority() -> int:
	return peer_id

func _ready() -> void:
	SimusNetIdentity.register(self)
	
	SimusNetRPC.register(
		[
			_ping_to_server,
		], SimusNetRPCConfig.new().flag_mode_authority().
		flag_set_channel(s_Networking.CHANNELS.USERS_UNRELIABLE)
		.flag_set_unreliable()
	)
	
	SimusNetRPC.register(
		[
			_receive_ping,
		], SimusNetRPCConfig.new().flag_mode_server_only().
		flag_set_channel(s_Networking.CHANNELS.USERS_UNRELIABLE)
		.flag_set_unreliable()
	)
	
	SimusDev.get_tree().physics_frame.connect(_on_physics_frame)

func _on_physics_frame() -> void:
	_physics_process(SimusDev.get_physics_process_delta_time())

func _physics_process(delta: float) -> void:
	_ping_server_ticks += delta
	if _ping_server_ticks >= 0.5:
		_ping_server_ticks = 0
		if SimusNet.is_network_authority(self):
			SimusNetRPC.invoke_on_server(_ping_to_server, Time.get_ticks_msec())

func _ping_to_server(time: int) -> void:
	SimusNetRPC.invoke_all(_receive_ping, Time.get_ticks_msec() - time)

func _receive_ping(ms: int) -> void:
	_ping = ms

func as_raw_object() -> R_User:
	var raw: R_User = duplicate()
	raw._network_id = SimusNetIdentity.register(self).get_unique_id()
	raw._is_raw_object = true
	return raw

static func get_connected() -> Array[R_User]:
	return s_Networking.get_connected_users()

static func find_by_login(_login: String) -> R_User:
	for i in get_connected():
		if i.login == _login:
			return i
	return null

static func find_by_peer_id(id: int) -> R_User:
	for i in get_connected():
		if i.peer_id == id:
			return i
	return null

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	buffer.pack(_is_raw_object)
	if _is_raw_object:
		buffer.pack(_network_id)
		buffer.pack(name)
		buffer.pack(peer_id)
	else:
		buffer.pack(peer_id)

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	var is_raw_object: bool = buffer.unpack()
	if not is_raw_object:
		var user_id: int = buffer.unpack()
		buffer.set_result(find_by_peer_id(user_id))
		return 
	
	var user: R_User = R_User.new()
	var network_id: int = buffer.unpack()
	SimusNetIdentity.register(user, network_id)
	user.name = buffer.unpack()
	user.peer_id = buffer.unpack()
	buffer.set_result(user)
	

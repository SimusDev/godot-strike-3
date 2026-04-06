extends Node

enum CHANNELS
{
	ENTITY_ATTRIBUTES = 1,
	USERS,
	ITEM,
	SHOOTING,
	
}

signal on_handhake()

var username: String = "player"

var _connected_users: Array[R_User] = []

const DEFAULT_PORT: int = 8080

func get_connected_users() -> Array[R_User]:
	return _connected_users

func _ready() -> void:
	SimusNetRPC.register(
		[
			_receive_handshake_server,
		], SimusNetRPCConfig.new().flag_mode_to_server().flag_set_channel(CHANNELS.USERS)
	)
	
	SimusNetRPC.register(
		[
			_receive_handshake_client,
		], SimusNetRPCConfig.new().flag_mode_server_only().flag_set_channel(CHANNELS.USERS)
	)
	
	SimusNetEvents.event_connected.listen(_on_network_connected)
	SimusNetEvents.event_disconnected.listen(_on_network_disconnected)
	SimusNetEvents.event_peer_disconnected.listen(_on_peer_disconnected, true)
	
	on_handhake.connect(_on_network_handshake)

func _on_network_handshake() -> void:
	print("Handshake success.")
	print("Received %s users." % _connected_users.size())

func _on_peer_disconnected(e: SimusNetEvent) -> void:
	var peer: int = e.get_arguments()
	for user in _connected_users:
		if user.peer_id == peer:
			_connected_users.erase(user)

func _on_network_connected() -> void:
	var data: Dictionary = {
		"username": username,
	}
	
	SimusNetRPC.invoke_on_server(_receive_handshake_server, data)

func _on_network_disconnected() -> void:
	_connected_users.clear()

func _receive_handshake_server(data: Dictionary) -> void:
	var peer: int = SimusNetRemote.sender_id
	var user: R_User = R_User.new()
	user.name = data.username
	user.peer_id = peer
	_connected_users.append(user)
	user._ready()
	
	var users_to_send: Array[R_User] = []
	
	for i in _connected_users:
		users_to_send.append(i.as_raw_object())
	
	if SimusNetConnection.is_server() and peer == SimusNet.SERVER_ID:
		on_handhake.emit()
		return
	
	SimusNetRPC.invoke_on_sender(_receive_handshake_client, users_to_send)

func _receive_handshake_client(connected_users: Array[R_User]) -> void:
	_connected_users = connected_users
	for i in _connected_users:
		i._ready()
	
	on_handhake.emit()

extends Node

enum CHANNELS
{
	ENTITY_ATTRIBUTES = 1,
	NODE_REPLICATION,
	USERS,
	ITEM,
	SHOOTING,
	
}

signal on_handhake()

var username: String = "player"

var _connected_users: Array[R_User] = []

const DEFAULT_PORT: int = 8080

@onready var _logger: SD_Logger = SD_Logger.new(self)

signal on_user_connected(user: R_User)
signal on_user_disconnected(user: R_User)

func get_connected_users() -> Array[R_User]:
	return _connected_users

func find_user_by_id(id:int) -> R_User:
	for user in get_connected_users():
		if user.peer_id == id:
			return user
	
	return null

func _ready() -> void:
	SimusNetRPC.register(
		[
			_receive_handshake_server,
		], SimusNetRPCConfig.new().flag_mode_to_server().flag_set_channel(CHANNELS.USERS)
	)
	
	SimusNetRPC.register(
		[
			_receive_handshake_client,
			_receive_user,
			_receive_user_deletion,
		], SimusNetRPCConfig.new().flag_mode_server_only().flag_set_channel(CHANNELS.USERS)
	)
	
	SimusNetEvents.event_connected.listen(_on_network_connected)
	SimusNetEvents.event_disconnected.listen(_on_network_disconnected)
	SimusNetEvents.event_peer_disconnected.listen(_on_peer_disconnected, true)
	
	on_handhake.connect(_on_network_handshake)

func _on_network_handshake() -> void:
	print("Handshake success.")
	print("Received %s users." % _connected_users.size())
	get_tree().change_scene_to_file("res://scenes/gameobjects_loading.tscn")

func _on_peer_disconnected(e: SimusNetEvent) -> void:
	if SimusNetConnection.is_server():
		var peer: int = e.get_arguments()
		SimusNetRPC.invoke_all(_receive_user_deletion, peer)
	

func _on_network_connected() -> void:
	var data: Dictionary = {
		"username": username,
	}
	
	SimusNetRPC.invoke_on_server(_receive_handshake_server, data)

func _on_network_disconnected() -> void:
	_connected_users.clear()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _receive_handshake_server(data: Dictionary) -> void:
	var peer: int = SimusNetRemote.sender_id
	var user: R_User = R_User.new()
	user.name = data.username
	user.peer_id = peer
	
	var users_to_send: Array[R_User] = []
	
	for i in _connected_users:
		users_to_send.append(i.as_raw_object())
	
	_receive_user(user)
	SimusNetRPC.invoke_except(_receive_user, [peer], user)
	
	if SimusNetConnection.is_server() and peer == SimusNet.SERVER_ID:
		on_handhake.emit()
		return
	
	SimusNetRPC.invoke_on_sender(_receive_handshake_client, users_to_send)

func _receive_handshake_client(connected_users: Array[R_User]) -> void:
	_connected_users = connected_users
	for i in _connected_users:
		i._ready()
	
	on_handhake.emit()

func _receive_user(user: R_User) -> void:
	_connected_users.append(user)
	user._ready()
	on_user_connected.emit(user)
	_logger.debug("%s connected." % user.name, SD_ConsoleCategories.WARNING)

func _receive_user_deletion(peer: int) -> void:
	for user in _connected_users:
		if user.peer_id == peer:
			_connected_users.erase(user)
			on_user_disconnected.emit(user)
			_logger.debug("%s disconnected." % user.name, SD_ConsoleCategories.WARNING)

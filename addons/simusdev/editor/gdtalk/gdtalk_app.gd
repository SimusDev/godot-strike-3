extends Control

var _network: ENetConnection = ENetConnection.new()

@onready var _ip: LineEdit = $VBoxContainer/_IP

const PORT: int = 7779

func _process(delta: float) -> void:
	var packet_event: Array = _network.service()
	if packet_event.is_empty():
		return
	
	var event: ENetConnection.EventType = packet_event[0]

func _on_server_pressed() -> void:
	var err: Error = _network.create_host()
	if err == OK:
		_connected()
	else:
		printerr("Failed to create ENetConnection!")

func _on_connect_pressed() -> void:
	var peer: ENetPacketPeer = _network.connect_to_host(_ip.text, PORT)

func _connected() -> void:
	pass

func _exit_tree() -> void:
	_network.destroy()

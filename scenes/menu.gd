extends Control

@onready var username: LineEdit = $VBoxContainer/Username
@onready var ip: LineEdit = $VBoxContainer/IP

func _on_host_pressed() -> void:
	s_Networking.username = username.text
	SimusNetConnectionENet.create_server(s_Networking.DEFAULT_PORT)

func _on_connect_pressed() -> void:
	s_Networking.username = username.text
	SimusNetConnectionENet.create_client(ip.text, s_Networking.DEFAULT_PORT)

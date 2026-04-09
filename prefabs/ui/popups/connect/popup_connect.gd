extends Control

@export var server_item:PackedScene

@export_group("References")
@export var server_listener:SimusNetServerListener
@export var container:Container

@onready var ip_line: LineEdit = $Content/IP
@onready var port_line: LineEdit = $Content/Port
@onready var connect_btn: Button = $Content/ConnectBtn

func _ready() -> void:
	server_listener.server_discovered.connect(_on_server_discovered)
	connect_btn.pressed.connect(_on_connect_btn_pressed)

func _on_connect_btn_pressed() -> void:
	if !port_line.text.is_valid_int():
		return
	SimusNetConnectionENet.create_client(ip_line.text, int(port_line.text))

func _on_server_discovered(server_info: Dictionary) -> void:
	if not server_item:
		return
	
	_add_server_item(server_info)

func _on_server_removed(ip: String) -> void:
	pass

func _add_server_item(server_info: Dictionary) -> void:
	if not is_instance_valid(container):
		return
	
	
	var new_inst = server_item.instantiate()
	new_inst.set("server_listener", server_listener)
	new_inst.set("server_info", server_info)
	container.add_child(new_inst)

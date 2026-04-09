@tool
extends Control

var server_info:Dictionary
var server_listener:SimusNetServerListener

@onready var panel: Panel = $Panel
@onready var button: Button = $Button

@onready var server_icon: TextureRect = $ServerIcon
@onready var server_name: Label = $ServerName
@onready var server_description: RichTextLabel = $ServerDescription


@export var color1: Color = Color(0.176, 0.176, 0.176, 1.0):
	set(value):
		color1 = value
		set_listed_color()

@export var color2: Color = Color(0.126, 0.126, 0.126, 1.0):
	set(value):
		color2 = value
		set_listed_color()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOVED_IN_PARENT:
		set_listed_color()

func _ready() -> void:
	if server_listener:
		server_listener.server_removed.connect(_on_server_removed)
	set_listed_color()

	button.pressed.connect(_on_btn_pressed)
	_update()

func _update() -> void:
	server_name.text = server_info.get("name", "Unknown Server")
	server_description.text = server_info.get("description", "")
	
	
	if server_info.has("texture"):
		server_icon.texture = server_info["texture"]

func _on_btn_pressed() -> void:
	SimusNetConnectionENet.create_client(server_info.get("ip", ""), server_info.get("port", 8080))

func _on_server_removed(ip: String) -> void:
	if ip == server_info.get("ip", ""):
		queue_free()

func set_listed_color() -> void:
	_set_listed_color.call_deferred()

func _set_listed_color() -> void:
	if not is_inside_tree():
		return
	
	var target_color = color1
	
	if get_index() % 2 != 0:
		target_color = color2
	
	panel.self_modulate = target_color

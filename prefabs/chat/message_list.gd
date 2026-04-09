extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var sd_ui_interface_menu: SD_UIInterfaceMenu



func _ready() -> void:
	rich_text_label.text = s_ServerChat.total_text
	
	s_ServerChat.message_received.connect(_on_message_received)
	
	visibility_changed.connect(_on_visibility_changed)
	
	sd_ui_interface_menu.opened.connect(_on_ui_opened)
	sd_ui_interface_menu.closed.connect(_on_ui_closed)

func _on_ui_opened() -> void:
	animation_player.play("RESET")
	show()
	
	print("sex")

func _on_ui_closed() -> void:
	animation_player.play("hide")

func _on_visibility_changed() -> void:
	if visible:
		animation_player.play("on_show")

func _on_text_submitted(new_text:String) -> void:
	s_ServerChat.send_message(new_text)

func _on_message_received(msg_text:String) -> void:
	rich_text_label.append_text(msg_text + "\n")
	
	if not visible:
		show()
		
		if sd_ui_interface_menu.is_closed():
			animation_player.play("hide")
		

extends LineEdit

@onready var sd_ui_interface_menu: SD_UIInterfaceMenu = $"../SD_UIInterfaceMenu"

func _ready() -> void:
	sd_ui_interface_menu.opened.connect(_on_ui_opened)
	text_submitted.connect(_on_text_submitted)

func _on_ui_opened() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	grab_focus()

func _on_text_submitted(new_text:String) -> void:
	text = ""
	s_ServerChat.send_message(new_text)

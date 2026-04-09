extends Control

@onready var username: LineEdit = $Popups/Main/Popup/Content/Username
@onready var back_button: Button = $BackButton

@onready var popups: Control = $Popups

var current_popup:String = "Main"

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	switch_popup_by_name("Main")

func switch_popup(popup: Control) -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		popups,
		"position:y",
		-popup.position.y,
		0.8
	)
	
	current_popup = popup.name
	_handle_back_btn()

func _handle_back_btn() -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	var target_pos:float = 0.0
	
	if current_popup == "Main":
		target_pos = -back_button.size.x
	
	tween.tween_property(
		back_button,
		"position:x",
		target_pos,
		0.8
	)

func switch_popup_by_name(popup_name:String) -> void:
	var popup = popups.get_node_or_null(popup_name)
	if not popup:
		return
	
	switch_popup(popup)

func _on_host_pressed() -> void:
	s_Networking.username = username.text
	SimusNetConnectionENet.create_server(s_Networking.DEFAULT_PORT)
	pass

func _on_connect_pressed() -> void:
	switch_popup_by_name("Connect")
	#s_Networking.username = username.text
	#SimusNetConnectionENet.create_client(ip.text, s_Networking.DEFAULT_PORT)

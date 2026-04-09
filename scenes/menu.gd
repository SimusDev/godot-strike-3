extends Control

@onready var username: LineEdit = $Popups/Main/VBoxContainer/Username
@onready var ip: LineEdit = $Popups/Main/VBoxContainer/IP

@onready var popups: Control = $Popups

func switch_popup(popup: Control) -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		popups,
		"position",
		-popup.position,
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

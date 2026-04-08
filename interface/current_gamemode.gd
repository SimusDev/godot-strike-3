extends Control

@onready var _label: Label = $_Label

var _prev_level: C_Level3D = null

func _ready() -> void:
	if SimusNetConnection.is_dedicated_server():
		queue_free()
		return
	
	_on_level_changed()
	C_Level3D.on_current_changed.published.connect(_on_level_changed)

func _on_level_changed() -> void:
	if is_instance_valid(_prev_level):
		_prev_level.on_gamemode_changed.disconnect(_update_gamemode)
	
	_prev_level = C_Level3D.get_current()
	_update_gamemode(C_Level3D.get_current())
	if C_Level3D.get_current():
		C_Level3D.get_current().on_gamemode_changed.connect(_update_gamemode.bind(C_Level3D.get_current()))
	

func _update_gamemode(level: C_Level3D) -> void:
	if !level:
		hide()
		return
	
	if !level.gamemode:
		hide()
		return
	
	_label.text = level.gamemode.get_unique_id()
	show()

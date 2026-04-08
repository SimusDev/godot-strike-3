extends Node3D

@export var _weapon: C_FirearmWeapon3D
@export var _texture: Texture

@export var fov: float = 40.0
@export var fov_min: float = 40.0

var _current_fov: float = 0

func _ready() -> void:
	await SD_Nodes.async_for_ready(_weapon)
	set_process_input(_weapon.is_local())
	
	if !_weapon.is_local():
		return
	
	_update()
	_weapon.on_zoom_changed.connect(_update)

func _update() -> void:
	if !_weapon.is_zooming:
		if _texture:
			UI_WeaponZoom.set_visibility(false, _texture)
			_weapon.show()
			
		_set_fov(_weapon.entity_eyes.default_camera_fov, false)
	else:
		UI_WeaponZoom.set_visibility(true, _texture)
		_weapon.hide()
		_set_fov(fov)
	
	set_process_input(_weapon.is_zooming)

func _set_fov(value: float, clamp: bool = true) -> void:
	if clamp:
		value = clamp(value, fov_min, fov)
	_current_fov = value
	_weapon.entity_eyes.set_camera_fov(value)

func _exit_tree() -> void:
	if _weapon.is_local():
		_weapon.is_zooming = false
		_update()

func _input(event: InputEvent) -> void:
	if SimusDev.ui.has_active_interface():
		return
	
	if Input.is_action_just_pressed("zoom_in"):
		_set_fov(_current_fov * 0.7)
	
	if Input.is_action_just_pressed("zoom_out"):
		_set_fov(_current_fov * 1.3)

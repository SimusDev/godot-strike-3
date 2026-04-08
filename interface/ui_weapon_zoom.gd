extends CanvasLayer
class_name UI_WeaponZoom

static var _instance: UI_WeaponZoom

@onready var _texture: TextureRect = $_Texture

func _enter_tree() -> void:
	_instance = self
	hide()

static func set_visibility(value: bool, texture: Texture) -> UI_WeaponZoom:
	_instance.visible = value
	_instance._texture.texture = texture
	return _instance

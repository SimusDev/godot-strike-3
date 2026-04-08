extends Control

@onready var _label: Label = $_Label

func _ready() -> void:
	var player: Player = Player.get_local()
	if player:
		var attributes = SD_ECS.find_children_by_script(player, C_CharacterAttributes)
		if attributes.is_empty():
			return
		
		var attribute: C_CharacterAttributes = attributes[0]
		_update(attribute)
		attribute.on_money_changed.connect(_update.bind(attribute))
		

func _update(attribute: C_CharacterAttributes) -> void:
	_label.text = "%s $" % str(attribute.money)

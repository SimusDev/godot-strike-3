extends Control

@onready var _label: Label = $_Label

func _ready() -> void:
	var player: Player = Player.get_local()
	if player:
		var healths = SD_ECS.find_children_by_script(player, C_Health)
		if healths.is_empty():
			return
		
		var health: C_Health = healths[0]
		_update(health)
		health.on_value_changed.connect(_update.bind(health))
		

func _update(health: C_Health) -> void:
	_label.text = "%s HP" % str(health.value)

extends Button

var object: R_WorldObject

func _ready() -> void:
	if !is_instance_valid(object):
		return
	
	$Panel/Label.text = object.get_unique_id()
	$TextureRect.texture = object.icon


func _on_pressed() -> void:
	var player: Player = Player.get_local()
	if is_instance_valid(player):
		var level: C_Level3D = C_Level3D.find_above(player)
		if level:
			level.request_spawn(object)

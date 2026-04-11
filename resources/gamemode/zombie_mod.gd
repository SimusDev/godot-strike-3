extends R_GameMode

func _switched(level: C_Level3D) -> void:
	var zm_scene: PackedScene = load("res://prefabs/gamemode/zombie_mod/zombie_mod.tscn")
	var zm: Node = zm_scene.instantiate()
	zm.name = "ZombieMod"
	level.set_meta("ZombieMod", zm)
	level.add_child(zm)

func _unswitched(level: C_Level3D) -> void:
	var zm: Node = level.get_meta("ZombieMod")
	if zm:
		zm.queue_free()

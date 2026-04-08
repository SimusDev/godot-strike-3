extends Control

func _ready() -> void:
	await s_GameObjects.load_all()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://game.tscn")

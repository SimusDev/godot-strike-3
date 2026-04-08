extends Control

func _ready() -> void:
	await s_GameObjects.load_all()
	await get_tree().process_frame
	WorkerThreadPool.add_task(_load_scene_threaded)

func _load_scene_threaded() -> void:
	var scene: PackedScene = load("res://game.tscn")
	get_tree().change_scene_to_packed.call_deferred(scene)
	

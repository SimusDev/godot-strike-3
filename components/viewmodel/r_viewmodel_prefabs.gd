extends R_ViewModel
class_name R_ViewModelPrefabs

@export var world: PackedScene
@export var player: PackedScene
@export var view: PackedScene

func ___instantiate(scene: PackedScene, type: String) -> Node:
	if scene:
		return scene.instantiate()
	printerr(resource_path, ": %s prefab is null!" % type)
	return null

func instantiate_world() -> Node:
	return ___instantiate(world, "world")

func instantiate_player() -> Node:
	return ___instantiate(player, "player")

func instantiate_view() -> Node:
	return ___instantiate(view, "view")

extends Resource
class_name R_ViewModel

enum TYPE {
	WORLD,
	PLAYER,
	VIEW,
}

func instantiate_world() -> Node:
	return null

func instantiate_player() -> Node:
	return null

func instantiate_view() -> Node:
	return null

func instantiate_by_type(type: TYPE) -> Node:
	match type:
		TYPE.WORLD:
			return instantiate_world()
		TYPE.PLAYER:
			return instantiate_player()
		TYPE.VIEW:
			return instantiate_view()
	return null

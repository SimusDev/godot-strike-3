extends Resource
class_name R_WorldObject

func generate_unique_id() -> StringName:
	var id: StringName = resource_path.replace(s_GameObjects.PATH, "").replacen("/", ".").get_basename()
	if id.begins_with("."):
		id = id.erase(0)
	return id 

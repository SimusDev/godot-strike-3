extends Resource
class_name R_GameResource

const META: StringName = &"R_GameResource"

func generate_unique_id() -> StringName:
	var id: StringName = resource_path.replace(s_GameObjects.PATH, "").replacen("/", ".").get_basename()
	if id.begins_with("."):
		id = id.erase(0)
	return id 

func _ready() -> void:
	pass

func set_in(object: Object) -> R_GameResource:
	object.set_meta(META, self)
	return self

static func find_in(object: Object) -> R_GameResource:
	if object.has_meta(META):
		return object.get_meta(META)
	return null

static func find_above(from: Node) -> R_GameResource:
	if from == SimusDev.get_tree().root:
		return null
	
	var team: R_GameResource = find_in(from)
	if team:
		return team
	
	return find_above(from.get_parent())

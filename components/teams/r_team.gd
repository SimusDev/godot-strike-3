extends Resource
class_name R_Team

const META: StringName = "R_Team"

@export var name: StringName = ""
@export var color: Color = Color.WHITE

func set_in(object: Object) -> R_Team:
	object.set_meta(META, self)
	return self

static func find_in(object: Object) -> R_Team:
	if object.has_meta(META):
		return object.get_meta(META)
	return null

static func find_above(from: Node) -> R_Team:
	if from == SimusDev.get_tree().root:
		return null
	
	var team: R_Team = find_in(from)
	if team:
		return team
	
	return find_above(from.get_parent())

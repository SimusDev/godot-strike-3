extends Resource
class_name C_ObjectComponent

var is_ready: bool = false

signal on_ready()

func _ready_internal() -> void:
	if !is_ready:
		_ready()
		is_ready = true
		on_ready.emit()

func _ready() -> void:
	pass

func _destroy() -> void:
	pass

func is_serializable() -> bool:
	return true

func serialize(networked: bool) -> Array:
	var result: Array = []
	
	if networked:
		result.append(SimusNetSerializer.parse_resource(get_script()))
		result.append(SimusNetNodeSceneReplicator.serialize_object_network_parameters(self))
	else:
		result.append(get_script().resource_path)
	
	return result

static func deserialize(data: Array, networked: bool) -> C_ObjectComponent:
	var comp: C_ObjectComponent
	
	if networked:
		comp = SimusNetDeserializer.parse_resource(data.pop_front()).duplicate()
		SimusNetNodeSceneReplicator.deserialize_object_network_parameters_to(comp, data.pop_front())
	else:
		comp = load(data.pop_front()).duplicate()
	
	return comp

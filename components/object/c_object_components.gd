extends Resource
class_name C_ObjectComponents

@export var _list: Array[C_ObjectComponent] = []

var _list_duplicated: Array[C_ObjectComponent] = []

signal on_added(component: C_ObjectComponent)
signal on_removed(component: C_ObjectComponent)

func get_ECS() -> Array:
	return _list

func get_list() -> Array[C_ObjectComponent]:
	return _list_duplicated

func add(component: C_ObjectComponent) -> C_ObjectComponents:
	if _list.has(component):
		return self
	
	_list.append(component)
	_list_duplicated.append(component)
	on_added.emit(component)
	_component_ready(component)
	component._ready_internal()
	
	return self

func find_by_script(script: Script) -> Array[Object]:
	return SD_ECS.find_components_by_script(self, [script])

func find_first_by_script(script: Script) -> Variant:
	return SD_ECS.find_first_component_by_script(self, [script])

func remove(component: C_ObjectComponent) -> C_ObjectComponents:
	if !_list.has(component):
		return self
	
	_list.erase(component)
	_list_duplicated.erase(component)
	on_removed.emit(component)
	component._destroy()
	
	return self

func initialize() -> C_ObjectComponents:
	var comps: C_ObjectComponents = duplicate()
	
	var list: Array[C_ObjectComponent] = []
	for c in comps._list:
		list.append(c.duplicate())
	
	comps._list = list
	comps._list_duplicated = list.duplicate()
	return comps

func ready() -> C_ObjectComponents:
	for c in _list:
		_component_ready(c)
		c._ready_internal()
	
	return self

func _component_ready(component: C_ObjectComponent) -> void:
	pass

func serialize_network_paremeters() -> Dictionary:
	var result: Dictionary = {}
	for comp in _list:
		var p: Dictionary = SimusNetNodeSceneReplicator.serialize_object_network_parameters(comp)
		if p.is_empty():
			continue
		result.set(_list.find(comp), p)
	return result

func deserialize_network_parameters(data: Dictionary) -> C_ObjectComponents:
	for comp_id: int in data:
		var comp: C_ObjectComponent = _list.get(comp_id)
		if comp:
			SimusNetNodeSceneReplicator.deserialize_object_network_parameters_to(comp, data[comp_id])
	return self

func serialize(networked: bool) -> Dictionary:
	var data: Dictionary = {}
	var comps: Array = data.get_or_add("c", [])
	for c in _list:
		if c.is_serializable():
			comps.append(c.serialize(networked))
	
	return data

static func deserialize(data: Dictionary, networked: bool, script: Script = C_ObjectComponents) -> C_ObjectComponents:
	var comps: C_ObjectComponents = script.new()
	var serialized_comps: Array = data.c
	
	for c in serialized_comps:
		var deserialized_comp: C_ObjectComponent = C_ObjectComponent.deserialize(c, networked)
		comps._list.append(deserialized_comp)
		comps._list_duplicated.append(deserialized_comp)
	
	var init: C_ObjectComponents = comps.initialize()
	return init

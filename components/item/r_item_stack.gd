extends R_WorldObject
class_name R_ItemStack

@export var _object: R_WorldObject : get = get_object

@export var components: C_ItemComponents
@export var components_networked: C_ItemComponents

func get_object() -> R_WorldObject:
	if !is_instance_valid(_object):
		_object = self
	return _object

func _ready() -> void:
	SimusNetIdentity.register(self)
	
	if !components:
		components = C_ItemComponents.new()
	
	components._item_weak_ref = weakref(self)
	components = components.initialize()
	
	if !components_networked:
		components_networked = C_ItemComponents.new()
	
	components_networked._item_weak_ref = weakref(self)
	components_networked = components_networked.initialize()

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	buffer.pack(get_object().get_unique_id())
	buffer.pack(SimusNetIdentity.register(self).get_unique_id())
	
	if components_networked:
		var networked_components_size: int = components_networked.get_list().size()
		buffer.pack(networked_components_size)
		
		for i in networked_components_size:
			var component: C_ItemComponent = components_networked.get_list().get(i)
			var net_id: int = SimusNetIdentity.register(component).get_unique_id()
			buffer.pack(net_id)

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	var item_id: String = buffer.unpack()
	var object: R_WorldObject = s_GameObjects._loaded[item_id]
	var item: R_ItemStack = object.duplicate()
	item._object = object
	
	var network_id: int = buffer.unpack()
	SimusNetIdentity.register(item, network_id)
	
	item._ready()
	
	var components_size: int = buffer.unpack()
	if item.components_networked:
		for id: int in components_size:
			var net_id: int = buffer.unpack()
			var component: C_ItemComponent = item.components_networked.get_list().get(id)
			if component:
				SimusNetIdentity.register(component, net_id)
	
	buffer.set_result(item)

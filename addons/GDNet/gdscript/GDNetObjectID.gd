extends RefCounted
class_name GDNetObjectID

var _hash_id: int = -1 :
	set(value):
		GDNet.storage._append_object_id_by_hash_id(self)

var _unique_id: int = -1 :
	set(value):
		GDNet.storage._append_object_id_by_unique_id(self)

var _owner_weak_ref: WeakRef = WeakRef.new()

const META: StringName = &"GDNetObjectID"

func get_owner() -> Object:
	return _owner_weak_ref.get_ref()

func get_hash_id() -> int:
	return _hash_id

func get_unique_id() -> int:
	return _unique_id

func _start_initialize() -> void:
	pass

static func try_find_in(object: Object) -> GDNetObjectID:
	if object.has_meta(META):
		var id: GDNetObjectID = object.get_meta(META)
		if is_instance_valid(id):
			if is_instance_valid(id.get_owner()):
				if id.get_owner() == object:
					return id
	return null

static func register(owner: Object) -> GDNetObjectID:
	var id: GDNetObjectID = try_find_in(owner)
	if id:
		return id
	
	if owner is Resource:
		if !owner.resource_path.is_empty():
			return register_with_hash_id(owner, owner.resource_path)
	
	id._owner_weak_ref = weakref(owner)
	owner.set_meta(META, id)
	
	
	
	id._start_initialize()
	return id

static func register_with_network_id(owner: Object, net_id: int) -> GDNetObjectID:
	var id: GDNetObjectID = try_find_in(owner)
	if id:
		return id
	id._owner_weak_ref = weakref(owner)
	owner.set_meta(META, id)
	id._start_initialize()
	return id

static func register_with_hash_id(owner: Object, hash_id: Variant) -> GDNetObjectID:
	var id: GDNetObjectID = try_find_in(owner)
	if id:
		return id
	id._owner_weak_ref = weakref(owner)
	owner.set_meta(META, id)
	id._start_initialize()
	return id

class_name R_ViewModelResources extends R_ViewModel

@export var world:R_ViewModelResource
@export var player:R_ViewModelResource
@export var view:R_ViewModelResource

func ___instantiate(resource:R_ViewModelResource, type: String) -> Node:
	if !resource:
		return
	
	if !resource.prefab:
		return
	
	var inst = resource.prefab.instantiate()
	if inst is Node3D:
		inst.tree_entered.connect(func(): 
			_set_instance_transform(inst, resource)
		)
		return inst as Node3D
	
	return null

func instantiate_world() -> Node:
	return ___instantiate(world, "world")

func instantiate_player() -> Node:
	return ___instantiate(player, "player")

func instantiate_view() -> Node:
	return ___instantiate(view, "view")

func _set_instance_transform(instance:Node, resource:R_ViewModelResource) -> void:
	if not instance.is_inside_tree():
		return
	
	
	if instance is Node3D:
		instance.scale = resource.scale
		
		if resource.is_global_transform:
			instance.global_position = resource.position
			instance.global_rotation = resource.rotation_degrees
		else:
			instance.position = resource.position
			instance.rotation = resource.rotation_degrees
			
			print("Res: %s, Rot: %s" % [resource.rotation_degrees, instance.rotation_degrees])

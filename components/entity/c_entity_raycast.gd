@tool
extends RayCast3D
class_name C_EntityRaycast

@export var _entity: Node3D

func get_entity() -> Node3D:
	return _entity

func clear_collision_masks() -> C_EntityRaycast:
	for layer in C_Collisions.MAX_LAYERS:
		set_collision_mask_value(layer + 1, false)
	return self

func _ready() -> void:
	collide_with_areas = true
	collide_with_bodies = true
	clear_collision_masks()
	set_collision_mask_value(C_Collisions.LAYERS.WORLD, true)
	set_collision_mask_value(C_Collisions.LAYERS.INTERACTION, true)
	set_collision_mask_value(C_Collisions.LAYERS.HITBOX, true)
	
	if _entity is CollisionObject3D:
		add_exception(_entity)
	
	if !Engine.is_editor_hint():
		if not SimusNet.is_network_authority(self):
			if !SimusNetConnection.is_server():
				enabled = false
				queue_free()
				return
		
		SD_ECS.append_to(_entity, self)
	
	_setup_hitboxes()

func _setup_hitboxes() -> void:
	await get_tree().process_frame
	
	for hitbox: C_EntityHitBox in SD_ECS.find_children_by_script(_entity, C_EntityHitBox):
		add_exception(hitbox)

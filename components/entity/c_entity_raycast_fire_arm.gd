@tool
extends C_EntityRaycast
class_name C_EntityRaycastFireArm

const LENGTH: float = 250

func _ready() -> void:
	super()
	
	collide_with_areas = true
	collide_with_bodies = true
	clear_collision_masks()
	set_collision_mask_value(C_Collisions.LAYERS.WORLD, true)
	set_collision_mask_value(C_Collisions.LAYERS.HITBOX, true)
	target_position.z = -LENGTH
	enabled = false

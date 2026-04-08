@tool
extends Area3D
class_name C_EntityHitBox

@export var _actor: Node3D

@export var damage_multiplier: float = 1.0

func get_actor() -> Node3D:
	if !is_instance_valid(_actor):
		return null
	return _actor

func _setup_actor() -> void:
	if !get_actor():
		await get_tree().process_frame
		var entity_eyes: C_EntityEyes = SD_ECS.node_find_above_by_component(self, C_EntityEyes)
		if entity_eyes:
			_actor = entity_eyes.get_entity()
	
	if get_actor():
		SD_ECS.append_to(get_actor(), self)

func apply_damage(points: float) -> C_EntityHitBox:
	if !get_actor():
		return
	
	var healths: Array[Node] = SD_ECS.find_children_by_script(get_actor(), C_Health)
	for health: C_Health in healths:
		health.value -= points * damage_multiplier
	
	return self

func _ready() -> void:
	monitoring = false
	C_Collisions.clear_body_collisions(self)
	C_Collisions.set_body_collision(self, C_Collisions.LAYERS.HITBOX)
	priority = C_Collisions.PRIORITIES.HITBOX
	
	if Engine.is_editor_hint():
		return
	
	_setup_actor()

class_name C_EntitySpineIK extends FABRIK3D

@export var entity_eyes:C_EntityEyes
@export var y_position_max:float = 1.6
@export var y_position_min:float = 1.6

func _process(delta: float) -> void:
	if not entity_eyes:
		return
	
	var step = 180.0 / y_position_max
	
	position.y = entity_eyes.get_camera().rotation_degrees.x / step

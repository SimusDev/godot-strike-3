@tool
extends C_EntityRaycast
class_name C_EntityRaycastInteraction

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		return
	
	SimusNetRPC.register(
		[
			_interact_server,
		], SimusNetRPCConfig.new().flag_mode_authority().
		flag_set_channel(s_Networking.CHANNELS.INVENTORY)
	)
	
	await SD_Nodes.async_for_ready(_entity)
	var input_enabled: bool = false
	if _entity is Player:
		input_enabled = _entity.is_local()
	
	set_process_input(input_enabled)

func _input(event: InputEvent) -> void:
	if SimusDev.ui.has_active_interface():
		return
	
	if Input.is_action_just_pressed("interact"):
		try_interact()

func try_interact() -> void:
	SimusNetRPC.invoke_on_server(_interact_server)

func _interact_server() -> void:
	if get_collider():
		var object: Object = get_collider()
		if object is Node:
			object.propagate_call("_interacted_server", [self])

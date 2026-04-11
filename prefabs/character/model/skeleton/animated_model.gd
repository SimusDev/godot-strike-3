@tool
class_name C_AnimatedModel3D extends W_AnimatedModel3D

@export var movement:W_FPCSourceLikeMovement
@export var item_state_machine:SD_NodeStateMachine

var actor_velocity
var blend_position

var state_machine_playback:AnimationNodeStateMachinePlayback

var item_state_machine_playback:AnimationNodeStateMachinePlayback


func _ready() -> void:
	#tree.active = true
	movement.state_machine.state_enter.connect(_on_state_enter)
	movement.state_machine.state_exit.connect(_on_state_exit)
	
	item_state_machine.state_enter.connect(_on_item_state_enter)
	
	state_machine_playback = tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
	item_state_machine_playback = tree.get("parameters/ItemStateMachine/playback") as AnimationNodeStateMachinePlayback
	visible = !is_multiplayer_authority()

func _on_state_enter(state:SD_State) -> void:
	state_machine_playback.travel(state.name)

func _on_state_exit(state:SD_State):
	pass

func _on_item_state_enter(state:SD_State) -> void:
	if state is C_ItemState:
		tree.set("parameters/WeaponBlend/blend_amount", state.blend)
		if state.name == "none":
			return
		
		item_state_machine_playback.travel(state.name)

func set_oneshot_animation_speed(value:float = 1.0, oneshot_name:StringName = "OneShotAnimationSpeedScale") -> void:
	tree.set("parameters/%s/scale" % oneshot_name, value)

func play_tree_oneshot_by_name(
	anim_name:StringName,
	speed_scale:float = 1.0,
	animation_node_name:StringName = "OneShotAnimation",
	oneshot_node_name:StringName = "OneShot"
		) -> void:
			
		if not anim_name:
			return
		if not library.has_animation(anim_name):
			return
		
		set_oneshot_animation_speed(speed_scale)
		
		var lib_name:StringName = library.resource_name
		if lib_name.is_empty():
			lib_name = library.resource_path.get_file().get_basename()
		
		var tree_root = (tree.tree_root as AnimationNodeBlendTree)
		var animation_node:AnimationNodeAnimation = tree_root.get_node(animation_node_name)
		animation_node.animation = "%s/%s" % [lib_name, anim_name]
		
		tree.set("parameters/%s/request" % oneshot_node_name,
		AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE
		)

func stop_tree_oneshot(oneshot_node_name:StringName = "OneShot") -> void:
	tree.set("parameters/%s/request" % oneshot_node_name, AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_ABORT)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	actor_velocity = movement.actor.velocity.normalized() * movement.actor.transform.basis
	blend_position = Vector2(actor_velocity.x, -actor_velocity.z)

	tree.set("parameters/StateMachine/%s/blend_position" % state_machine_playback.get_current_node(), blend_position)

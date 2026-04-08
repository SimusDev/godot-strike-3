@tool
extends W_AnimatedModel3D

@export var movement:W_FPCSourceLikeMovement

var actor_velocity
var blend_position

var state_machine_playback:AnimationNodeStateMachinePlayback

func _ready() -> void:
	#tree.active = true
	movement.state_machine.state_enter.connect(_on_state_enter)
	movement.state_machine.state_exit.connect(_on_state_exit)
	state_machine_playback = tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
	visible = !is_multiplayer_authority()

func _on_state_enter(state:SD_State):
	state_machine_playback.travel(state.name)

func _on_state_exit(state:SD_State):
	pass

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	actor_velocity = movement.actor.velocity.normalized() * movement.actor.transform.basis
	blend_position = Vector2(actor_velocity.x, -actor_velocity.z)

	tree.set("parameters/StateMachine/%s/blend_position" % state_machine_playback.get_current_node(), blend_position)

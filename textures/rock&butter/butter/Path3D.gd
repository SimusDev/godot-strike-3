@tool
extends Path3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$PathFollow3D/Node3D/butt/AnimationPlayer.play("play")

const m := 0.01
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	$PathFollow3D.progress_ratio += m * delta

class_name W_BulletTracer extends Node3D

@export var target_pos:Vector3 = Vector3.ZERO
@export var speed:float = 575.0
@export var tracer_length:float = 75.0

@export var life_time:float = 15.0

@export var default_mesh:Mesh = preload("res://resources/mesh/bullet_tracer.tres")

@onready var spawn_time = Time.get_ticks_msec()

var mesh_inst:MeshInstance3D


func _ready() -> void:
	mesh_inst = get_node_or_null("MeshInstance3D")
	if not mesh_inst:
		mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = default_mesh
		add_child(mesh_inst)
		
		if mesh_inst.mesh is RibbonTrailMesh:
			mesh_inst.position.z = -mesh_inst.mesh.section_length
			
		mesh_inst.rotation_degrees.x = -90
	
	
	get_tree().create_timer(life_time).timeout.connect(queue_free)

func _process(delta: float) -> void:
	var diff = target_pos - global_position
	var add = (diff.normalized() * speed) * delta
	add = add.limit_length(diff.length())
	
	global_position += add
	
	if global_position.distance_to(target_pos) < 0.1:
		queue_free()

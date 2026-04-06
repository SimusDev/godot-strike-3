class_name SD_MetadataMaterial extends SD_Metadata

@export_group("Physics")
@export var resistance:float = 1.0

@export_group("VFX")
@export var bullet_impact_particles:PackedScene
@export_subgroup("Decal")
@export var bullet_impact_decal:PackedScene
@export var melee_impact_decal:PackedScene

@export_group("Sound")
@export var impact_sounds:Array[AudioStream] = [

]

@export var bullet_impact_sounds:Array[AudioStream] = [

]

@export var break_sounds:Array[AudioStream] =  [
	
]

@export var footstep_sounds:Array[AudioStream] = []

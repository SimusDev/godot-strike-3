class_name SD_MetadataMaterial extends SD_Metadata

@export_group("Physics")
@export var resistance:float = 1.0

@export_group("VFX")
@export var bullet_impact_particles:Array[PackedScene]
@export_subgroup("Decal")
@export var bullet_impact_decals:Array[PackedScene]
@export var melee_impact_decals:Array[PackedScene]

func get_bullet_impact_decal() -> PackedScene:
	if bullet_impact_decals.is_empty():
		return null
	return bullet_impact_decals.pick_random()

func get_melee_impact_decal() -> PackedScene:
	if melee_impact_decals.is_empty():
		return null
	return melee_impact_decals.pick_random()


@export_group("Sound")
@export var impact_sounds:Array[AudioStream] = [

]

@export var bullet_impact_sounds:Array[AudioStream] = [

]
func get_bullet_impact_sound() -> AudioStream:
	if bullet_impact_sounds.is_empty():
		return null
	
	return bullet_impact_sounds.pick_random()

@export var break_sounds:Array[AudioStream] =  [
	
]

@export var footstep_sounds:Array[AudioStream] = []

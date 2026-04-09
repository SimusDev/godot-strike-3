class_name W_MuzzleFlash extends GPUParticles3D

var light:OmniLight3D

func _ready() -> void:
	light = get_node_or_null("OmniLight3D")
	if not light:
		light = OmniLight3D.new()
		light.range = 2.0
		light.light_color = Color(1.0, 0.863, 0.0)
		add_child(light)
	
	

func flash() -> void:
	emitting = true
	
	if light:
		light.show()
		await get_tree().create_timer(0.05).timeout
		light.hide()

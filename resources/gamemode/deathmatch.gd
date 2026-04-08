extends R_GameMode

func _switched(level: C_Level3D) -> void:
	C_Health.on_died.listen(_on_health_died, true)

func _on_health_died(event: SD_Event) -> void:
	var health: C_Health = event.get_arguments()
	var player: Player = SD_ECS.node_find_above_by_script(health, Player)
	if player:
		if SimusNetConnection.is_server():
			health.reset_value()
			player.respawn()

func _unswitched(level: C_Level3D) -> void:
	C_Health.on_died.unlisten(_on_health_died)

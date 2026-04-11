extends Node

@onready var logger: SD_Logger = SD_Logger.new("ZombieMod")

var level: C_Level3D

var count_down: int = 20

func _ready() -> void:
	level = C_Level3D.find_above(self)
	level.on_player_spawned.connect(_process_player)
	
	restart()

func _process_player(player: Player) -> void:
	#var inventory: C_Inventory = SD_ECS.find_first_component_by_script(player, [C_Inventory])
	#if inventory:
		#inventory.clear()
	
	player.respawn()

func restart() -> void:
	count_down = 20
	await get_tree().create_timer(1).timeout
	
	logger.debug("Zombie Mod Started with %s players." % [level.get_players().size()])
	for player in level.get_players():
		_process_player(player)
	

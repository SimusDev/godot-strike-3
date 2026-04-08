extends R_GameResource
class_name R_GameMode

static var _switch_command: SD_ConsoleCommand

static var list: Array[R_GameMode] = []

func _ready() -> void:
	_switch_command = SD_ConsoleCommand.get_or_create("gamemode")
	_switch_command.executed.connect(_on_switch_executed)

func _registered() -> void:
	list.append(self)

func _unregistered() -> void:
	list.erase(self)

static func _on_switch_executed() -> void:
	if !SimusNetConnection.is_server():
		SimusDev.console.write_error("Only server can change gamemode.")
		return
	
	if list.is_empty():
		SimusDev.console.write_warning("No game modes were found.")
		return
	
	var player: Player = Player.get_local()
	if player:
		var level: C_Level3D = C_Level3D.find_above(player)
		if level:
			var gamemode: R_GameMode
			
			for i in list:
				if i.get_unique_id() == _switch_command.get_value_as_string():
					gamemode = i
			
			if gamemode:
				level.gamemode = gamemode
				SimusDev.console.write_info("GameMode changed to %s" % gamemode.resource_path.get_file())
				
			else:
				SimusDev.console.write_error("Cant find %s gamemode." % _switch_command.get_value_as_string())
				var available_gamemodes: Array[String] = []
				for i in list:
					available_gamemodes.append(i.get_unique_id())
				SimusDev.console.write_info("Available gamemodes: %s" % available_gamemodes)
			
			return
		
	
	SimusDev.console.write_error("cant find level instance!")

func _switched_internal(level: C_Level3D) -> void:
	_switched(level)

func _unswitched_internal(level: C_Level3D) -> void:
	_unswitched(level)

func _switched(level: C_Level3D) -> void:
	pass

func _unswitched(level: C_Level3D) -> void:
	pass

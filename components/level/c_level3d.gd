@static_unload
extends Node3D
class_name C_Level3D

var _replicator: C_NodeReplicator

var _sections: Node3D
var _sections_local: Node3D

var _spawnpoints: Array[C_SpawnPoint3D] = []

func get_spawnpoints() -> Array[C_SpawnPoint3D]:
	return _spawnpoints

@export var gamemode: R_GameMode : set = set_gamemode

signal on_gamemode_changed()

static var _current: C_Level3D

static var on_current_changed: SD_Event = SD_Event.new()

var _players: Array[Player] = []

signal on_player_spawned(player: Player)
signal on_player_despawned(player: Player)

func get_players() -> Array[Player]:
	return _players

static func set_current(level: C_Level3D) -> void:
	_current = level
	on_current_changed.publish()

static func get_current() -> C_Level3D:
	if !is_instance_valid(_current):
		return null
	return _current

func get_replicator() -> C_NodeReplicator:
	return _replicator

func set_gamemode(new: R_GameMode) -> C_Level3D:
	if gamemode == new:
		return
	
	if is_instance_valid(gamemode):
		gamemode._unswitched_internal(self)
	
	if gamemode:
		
		new._switched_internal(self)
	
	gamemode = new
	on_gamemode_changed.emit()
	
	return self

func _ready() -> void:
	_sections = Node3D.new()
	_sections_local = Node3D.new()
	_sections.name = "Sections"
	_sections_local.name = "LocalSections"
	add_child(_sections)
	add_child(_sections_local)
	
	_replicator = C_NodeReplicator.new()
	_replicator.name = "Replicator"
	
	var sections: Array[String] = []
	for i in s_GameObjects.get_loaded_resources():
		var section_id: String = ""
		
		var script: Script = i.get_script()
		if script:
			section_id = script.get_global_name().to_camel_case().validate_node_name()
		
		if section_id.is_empty() or sections.has(section_id):
			continue
		
		sections.append(section_id)
	
	sections.sort()
	
	for id: String in sections:
		var section_node: Node3D = Node3D.new()
		section_node.name = id
		var section_node_local: Node3D = Node3D.new()
		section_node_local.name = id
		
		_sections.add_child(section_node)
		_sections_local.add_child(section_node_local)
		
		_replicator.roots.append(section_node)
	
	await _network_init()
	
	add_child(_replicator)
	
	if gamemode:
		gamemode._switched(self)

func _network_init() -> void:
	SimusNetVars.register(
		self,
		[
			"gamemode"
		], SimusNetVarConfig.new().flag_mode_server_only().
		flag_reliable(s_Networking.CHANNELS.NODE_REPLICATION)
		.flag_replication(false)
	)
	
	gamemode = await SimusNetVars.replicate_async(self, "gamemode")

static func find_above(from: Node) -> C_Level3D:
	return SD_ECS.node_find_above_by_script(from, C_Level3D)

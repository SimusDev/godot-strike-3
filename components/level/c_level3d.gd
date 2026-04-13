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
	
	SimusNetRPC.register(
		[
			_request_spawn_rpc,
		], SimusNetRPCConfig.new().flag_mode_to_server()
		.flag_set_channel(s_Networking.CHANNELS.NODE_REPLICATION)
	)
	
	gamemode = await SimusNetVars.replicate_async(self, "gamemode")

func request_spawn(object: R_WorldObject) -> C_Level3D:
	if Player.get_local():
		SimusNetRPC.invoke_on_server(_request_spawn_rpc, object)
	return self

func _request_spawn_rpc(object: R_WorldObject) -> void:
	if !is_instance_valid(object):
		return
	
	var picked_player: Player
	for i in get_players():
		if i.get_multiplayer_authority() == SimusNetRemote.sender_id:
			picked_player = i
	
	if !is_instance_valid(picked_player):
		return
	
	var raycast: C_EntityRaycastInteraction = SD_ECS.find_first_component_by_script(picked_player, [C_EntityRaycastInteraction])
	if !raycast:
		return
	
	var node: Node = spawn(object)
	if is_instance_valid(node):
		if node is Node3D:
			node.global_position = raycast.global_position

func spawn(object: R_WorldObject) -> Node:
	if !is_instance_valid(object):
		return
	
	if !object.viewmodel:
		push_error("%s viewmodel property is null" % object.resource_path)
		return
	
	var instance: Node = object.viewmodel.instantiate_world()
	if is_instance_valid(instance):
		var section_id: String = object.get_script().get_global_name().to_camel_case().validate_node_name()
		_sections.get_node(section_id).add_child(instance)
	else:
		push_error("%s instantiated object is null" % object.resource_path)
	return instance

static func find_above(from: Node) -> C_Level3D:
	return SD_ECS.node_find_above_by_script(from, C_Level3D)

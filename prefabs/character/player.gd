extends CharacterBody3D
class_name Player

static var _local: Player

static var list: Array[Player] = []

static func get_local() -> Player:
	if is_instance_valid(_local):
		return _local
	return null

func _enter_tree() -> void:
	if !is_node_ready():
		await ready
	
	C_Level3D.find_above(self)._players.append(self)
	list.append(self)

func _exit_tree() -> void:
	C_Level3D.find_above(self)._players.erase(self)
	list.erase(self)

func is_local() -> bool:
	return self == get_local()

func _ready() -> void:
	if SimusNet.is_network_authority(self):
		_local = self
	
	SimusNetVars.register(
		self,
		["velocity"],
		SimusNetVarConfig.new().flag_mode_authority().flag_tickrate(32.0).flag_replication()
	)
	
	SimusNetRPC.register(
		[
			_respawn_rpc
		], SimusNetRPCConfig.new().flag_mode_server_only()
	)
	
	var level: C_Level3D = C_Level3D.find_above(self)
	if level:
		C_Level3D.set_current(level)

func respawn() -> Player:
	if SimusNetConnection.is_server():
		SimusNetRPC.invoke_all(_respawn_rpc)
	return self

func _respawn_rpc() -> void:
	var level: C_Level3D = C_Level3D.find_above(self)
	if level:
		var point: C_SpawnPoint3D = level.get_spawnpoints().pick_random()
		if point:
			global_transform = point.global_transform
	

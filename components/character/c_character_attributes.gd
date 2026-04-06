extends Node
class_name C_CharacterAttributes

@export var team: R_Team

func _ready() -> void:
	SimusNetVars.register(
		self,
		[
			"team"
		], SimusNetVarConfig.new().flag_mode_server_only().
		flag_reliable(s_Networking.CHANNELS.ENTITY_ATTRIBUTES)
		.flag_replication()
	)

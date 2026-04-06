extends Node
class_name C_Health

@export var value: float = 100.0 : set = set_value

signal on_value_changed()

func set_value(new: float) -> void:
	value = new
	on_value_changed.emit()

func _ready() -> void:
	SimusNetVars.register(
		self,
		["value"],
		SimusNetVarConfig.new().flag_mode_server_only().
		flag_reliable(s_Networking.CHANNELS.ENTITY_ATTRIBUTES)
		.flag_replication()
	)

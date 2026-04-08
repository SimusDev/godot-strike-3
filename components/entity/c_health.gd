extends Node
class_name C_Health

@export var value: float = 100.0 : set = set_value

signal on_value_changed()

static var on_died: SD_Event = SD_Event.new().set_debug(false)

var _is_died: bool = false

func is_died() -> bool:
	return _is_died

func is_alive() -> bool:
	return !_is_died

func set_value(new: float) -> void:
	value = new
	on_value_changed.emit()
	
	if value > 0:
		_is_died = false
	
	if value < 0:
		value = 0.0
	
	if _is_died:
		return
	
	if value <= 0:
		_is_died = true
		on_died.publish(self)

var _default_value: float = 0.0

func _ready() -> void:
	_default_value = value
	
	SimusNetVars.register(
		self,
		["value"],
		SimusNetVarConfig.new().flag_mode_server_only().
		flag_reliable(s_Networking.CHANNELS.ENTITY_ATTRIBUTES)
		.flag_replication()
	)

func reset_value() -> C_Health:
	value = _default_value
	return self

extends Node

const START: int = 20
var value: int = START : set = set_value

signal on_value_changed()

var _timer: Timer

func set_value(new: int) -> void:
	value = new
	on_value_changed.emit()

func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)
	
	SimusNetVars.register(
		self,
		["value"],
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication()
	)
	
	process_mode = Node.PROCESS_MODE_DISABLED
	_timer.timeout.connect(_on_tick)

func _on_tick() -> void:
	if SimusNetConnection.is_server():
		if value > 0:
			value -= 1
	
func restart() -> void:
	if SimusNetConnection.is_server():
		_timer.start()
		value = START
		process_mode = Node.PROCESS_MODE_INHERIT
	

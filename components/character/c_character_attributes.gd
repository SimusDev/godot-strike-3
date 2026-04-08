extends Node
class_name C_CharacterAttributes

@export var team: R_Team

@export var money: int = 0 : set = set_money, get = get_money

signal on_money_changed()

func set_money(new: int) -> C_CharacterAttributes:
	money = new
	if money < 0:
		money = 0
	on_money_changed.emit()
	return self

func get_money() -> int:
	return money

func _ready() -> void:
	SimusNetVars.register(
		self,
		[
			"team",
			"money",
		], SimusNetVarConfig.new().flag_mode_server_only().
		flag_reliable(s_Networking.CHANNELS.ENTITY_ATTRIBUTES)
		.flag_replication()
	)

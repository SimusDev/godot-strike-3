extends R_ItemStack
class_name R_FireArmWeapon

@export var automatic: bool = true
@export var cooldown: float = 0.1
@export var damage: float = 30.0
@export var bullets: int = 8
@export var bullets_max: int = 8
@export var ammo: int = 8
@export var reload_time: float = 3.0

func _ready() -> void:
	super()
	
	SimusNetVars.register(
		self,
		[
			"bullets",
			"ammo",
		], SimusNetVarConfig.new().flag_mode_server_only()
		.flag_reliable(s_Networking.CHANNELS.ITEM)
	)

func _network_serialize(buffer: SimusNetCustomSerialization) -> void:
	buffer.pack(bullets)
	buffer.pack(ammo)

func _network_deserialize(buffer: SimusNetCustomSerialization) -> void:
	bullets = buffer.unpack()
	ammo = buffer.unpack()

extends Node3D
class_name C_Shop

@export var _items: Array[R_ShopItem] = []

const PURCHASE_SOUND1: AudioStream = preload("res://audio/sfx/item/gun/ak47_draw.mp3")

var _audio_player: C_AudioPlayer3D

func _ready() -> void:
	_audio_player = C_AudioPlayer3D.new()
	_audio_player.max_distance = 16.0
	add_child(_audio_player)
	
	SimusNetRPC.register(
		[
			_open_interface,
			_play_sound,
		], SimusNetRPCConfig.new().flag_mode_server_only()
	)
	
	SimusNetRPC.register(
		[
			_request_buy_rpc,
		], SimusNetRPCConfig.new().flag_mode_to_server()
	)
	
	SimusNetVars.register(
		self,
		[
			"_items"
		]
	)

func synchronize() -> Array[R_ShopItem]:
	if SimusNetConnection.is_server():
		return _items
	
	return await SimusNetVars.replicate_async(self, "_items")

func _interacted_server(ray: C_EntityRaycastInteraction) -> void:
	if ray.get_entity() is Player:
		SimusNetRPC.invoke_on(ray.get_entity().get_multiplayer_authority(), _open_interface)

func _open_interface() -> void:
	UI_ShopInterface.set_shop(self)

func request_buy(item_id: int) -> void:
	SimusNetRPC.invoke_on_server(_request_buy_rpc, item_id)

func _request_buy_rpc(item_id: int) -> void:
	if _items.is_empty() or item_id > _items.size() - 1:
		return
	
	var picked_player: Player
	var level: C_Level3D = C_Level3D.find_above(self)
	for player in level.get_players():
		if player.get_multiplayer_authority() == SimusNetRemote.sender_id:
			picked_player = player
			break
	
	if !is_instance_valid(picked_player):
		return
	
	var item: R_ShopItem = _items.get(item_id)
	if !is_instance_valid(item):
		return
	
	if item.can_purchase(picked_player):
		item._purchased(picked_player)
		SimusNetRPC.invoke_all(_play_sound, PURCHASE_SOUND1)

func _play_sound(audio: AudioStream) -> void:
	_audio_player.try_play(audio)

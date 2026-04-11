extends Node
class_name C_Inventory

@export var entity: Node
@export var _items: Array[R_ItemStack] = []

signal on_synchronized()

var is_network_ready: bool = false

func _ready() -> void:
	
	_initialize_network()
	_initialize_items()
	
	SD_ECS.append_to(entity, self)
	await SD_Nodes.async_for_ready(entity)
	
	#if entity is Player:
		#if entity.is_local():
			#queue_free()
			#return
		
	synchronize()

func get_item_by_network_id(id: int) -> R_ItemStack:
	for i in _items:
		if i.network_id == id:
			return i
	return null

func _initialize_network() -> void:
	SimusNetRPC.register(
		[
			_send
		], SimusNetRPCConfig.new().flag_mode_to_server()
		.flag_set_channel(s_Networking.CHANNELS.INVENTORY)
	)
	
	SimusNetRPC.register(
		[
			_receive
		], SimusNetRPCConfig.new().flag_mode_server_only()
		.flag_set_channel(s_Networking.CHANNELS.INVENTORY)
	)

func _initialize_items() -> void:
	if !SimusNetConnection.is_server():
		_items.clear()
	else:
		var copied: Array[R_ItemStack] = []
		for i in _items:
			copied.append(i.duplicate())
		
		_items = copied
		
		for i in _items:
			i._ready()
	
	

func for_async_network_ready() -> void:
	if !is_network_ready:
		await on_synchronized

func synchronize() -> void:
	is_network_ready = false
	
	if SimusNetConnection.is_server():
		is_network_ready = true
		return
	
	SimusNetRPC.invoke_on_server(_send)

func _send() -> void:
	var raw_items: Array[R_ItemStack] = []
	for i in _items:
		var d := i.duplicate()
		d._inventory = null
		raw_items.append(d)
	
	SimusNetRPC.invoke_on_sender(_receive, raw_items)

func _receive(raw_items: Array[R_ItemStack]) -> void:
	_items = raw_items
	for i in _items:
		i._ready()
	on_synchronized.emit()

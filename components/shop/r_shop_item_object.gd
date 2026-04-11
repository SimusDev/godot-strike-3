extends R_ShopItem
class_name R_ShopItemObject

@export var _object: R_WorldObject

func _ready() -> void:
	super()

func get_item_name() -> String:
	return _object.get_unique_id()

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	super(buffer)
	buffer.pack(_object.get_unique_id())

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	super(buffer)
	var item: R_ShopItemObject = buffer.get_result()
	item._object = s_GameObjects._loaded[buffer.unpack()]

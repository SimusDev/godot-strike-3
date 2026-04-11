extends Resource
class_name R_ShopItem

@export var cost: int = 0

func _ready() -> void:
	pass

func get_item_name() -> String:
	return "item.name"

func can_purchase(entity: Node) -> bool:
	var attributes: Array[Node] = SD_ECS.find_children_by_script(entity, C_CharacterAttributes)
	for attribute: C_CharacterAttributes in attributes:
		if attribute.money >= cost:
			return true
	return false

func _purchased(entity: Node) -> void:
	var attributes: Array[Node] = SD_ECS.find_children_by_script(entity, C_CharacterAttributes)
	for attribute: C_CharacterAttributes in attributes:
		attribute.money -= cost

func simusnet_serialize(buffer: SimusNetCustomSerialization) -> void:
	buffer.pack(get_script())
	buffer.pack(cost)

static func simusnet_deserialize(buffer: SimusNetCustomSerialization) -> void:
	var item: R_ShopItem = buffer.unpack().new()
	item.cost = buffer.unpack()
	buffer.set_result(item)

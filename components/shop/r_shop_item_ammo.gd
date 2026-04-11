extends R_ShopItem
class_name R_ShopItemAmmo

func get_item_name() -> String:
	return "weapon.ammo"

func can_purchase(entity: Node) -> bool:
	var result: bool = super(entity)
	return result

func _purchased(entity: Node) -> void:
	super(entity)
	
	var inventory: C_Inventory = SD_ECS.find_first_component_by_script(entity, [C_Inventory])
	if !inventory:
		return
	
	for item in inventory.get_items():
		if item is R_FireArmWeapon:
			item.ammo += item.bullets_max
	

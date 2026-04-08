extends C_ObjectComponent
class_name C_ItemComponent

var _item_weak_ref: WeakRef = WeakRef.new()

func get_item() -> R_ItemStack:
	return _item_weak_ref.get_ref()

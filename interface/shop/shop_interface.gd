extends Control
class_name UI_ShopInterface

static var _instance: UI_ShopInterface

var _items: Array[R_ShopItem] = []

@onready var _item_interface: ItemList = $Panel/_ItemInterface

var _shop: C_Shop

func _enter_tree() -> void:
	_instance = self
	hide()

func _on_visible(shop: C_Shop) -> void:
	if !is_instance_valid(shop):
		return
	
	_shop = shop
	
	_item_interface.clear()
	_items = await shop.synchronize()
	
	for i in _items:
		_item_interface.add_item(i.get_item_name() + " - " + str(i.cost) + "$")

func _input(event: InputEvent) -> void:
	if !is_visible_in_tree():
		return
	
	if Input.is_action_just_pressed("interface.close"):
		hide()

static func set_shop(shop: C_Shop) -> UI_ShopInterface:
	_instance.show()
	_instance._on_visible(shop)
	return _instance

func _on_buy_pressed() -> void:
	if !is_instance_valid(_shop):
		return
	
	for selected: int in _item_interface.get_selected_items():
		_shop.request_buy(selected)

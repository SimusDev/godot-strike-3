extends Object
class_name GDNetTestSerializable

var my_var: int = 78

func gdnet_serialize(buffer: GDNetBuffer) -> void:
	buffer.write(my_var)

static func gdnet_deserialize(buffer: GDNetBuffer) -> GDNetTestSerializable:
	var object := GDNetTestSerializable.new()
	object.my_var = buffer.read()
	return object

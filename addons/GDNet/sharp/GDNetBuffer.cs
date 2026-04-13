using Godot;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;

[GlobalClass, Icon("")]
public partial class GDNetBuffer : RefCounted
{
	private enum DataType : byte
	{
		NULL = 0x01,
		
		BOOL_TRUE,
		BOOL_FALSE,
		
		VAR,

		INT8,
		INT16,
		INT32,
		INT64,

		FLOAT,
		DOUBLE,
		STRING,
		VECTOR2,
		VECTOR3,

		BYTE_ARRAY_EMPTY,
		BYTE_ARRAY_U8,
		BYTE_ARRAY_U16,
		BYTE_ARRAY_U32,

		ARRAY_SIMPLE,
		ARRAY_COMPLEX,
		ARRAY_START,
		ARRAY_END,

		DICTIONARY_VAR,
		DICTIONARY_BUFFER,
		DICT_START,
		DICT_END,

		RESOURCE,
		FULL_OBJECT,
		CUSTOM,

		NODE_REFERENCE,

	}

	private enum FullObjectType : byte
	{
		OBJECT = 0x01,
		NODE,
		RESOURCE,
		REFCOUNTED,
		OTHER,
	}

	private StreamPeerBuffer _stream = new StreamPeerBuffer();

	private Dictionary<Variant.Type, Action<Variant>> _write_methods;
	private Dictionary<DataType, Func<Variant>> _read_methods;

	public GDNetBuffer()
	{
		_write_methods = new Dictionary<Variant.Type, Action<Variant>>
		{
			{ Variant.Type.Nil, v => write_null()},
			{ Variant.Type.Bool, v => write_bool(v.As<bool>()) },
			{ Variant.Type.Int, v => write_int(v.As<int>()) },
			{ Variant.Type.String, v => write_string(v.As<string>()) },
			{ Variant.Type.Vector3, v => write_vector3(v.As<Vector3>()) },
			{ Variant.Type.Vector2, v => write_vector2(v.As<Vector2>()) },
			{ Variant.Type.Float, v => write_float(v.As<float>()) },
			{ Variant.Type.PackedByteArray, v => write_bytes(v.As<byte[]>()) },
			{ Variant.Type.Array, v => write_array_simple(v.As<Godot.Collections.Array>()) },
			{ Variant.Type.Object, v => write_object_auto(v.As<GodotObject>()) },
		};

		_read_methods = new Dictionary<DataType, Func<Variant>>
		{
			{ DataType.NULL, () => read_null() },
			{ DataType.INT8, () => read_int8() },
			{ DataType.INT16, () => read_int16() },
			{ DataType.INT32, () => read_int32() },
			{ DataType.INT64, () => read_int64() },
			{ DataType.BOOL_TRUE, () => read_bool() },
			{ DataType.BOOL_FALSE, () => read_bool() },
			{ DataType.VAR, () => read_var() },
			{ DataType.STRING, () => read_string() },
			{ DataType.VECTOR3, () => read_vector3() },
			{ DataType.VECTOR2, () => read_vector2() },
			{ DataType.FLOAT, () => read_float() },
			{ DataType.DOUBLE, () => read_float() },
			{ DataType.BYTE_ARRAY_EMPTY, () => read_bytes() },
			{ DataType.BYTE_ARRAY_U8, () => read_bytes() },
			{ DataType.BYTE_ARRAY_U16, () => read_bytes() },
			{ DataType.BYTE_ARRAY_U32, () => read_bytes() },
			{ DataType.ARRAY_SIMPLE, () => read_array_simple() },
			{ DataType.ARRAY_COMPLEX, () => read_array_complex() },
			{ DataType.RESOURCE, () => read_resource() },
			{ DataType.FULL_OBJECT, () => read_full_object() },
			{ DataType.CUSTOM, () => read_custom_object() },
			{ DataType.NODE_REFERENCE, () => read_node_ref() },
		};
	}

	// ============================================
	// PUBLIC API
	// ============================================

	public Godot.Collections.Array to_array()
	{
		var result = new Godot.Collections.Array();
		int rememberedPos = get_position();
		seek(0);

		while (_stream.GetAvailableBytes() > 0)
		{
			result.Add(read());
		}

		seek(rememberedPos);
		return result;
	}

	public GDNetBuffer write(Variant value)
	{
		if (_write_methods.TryGetValue(value.VariantType, out var method))
		{
			method(value);
		}
		else
		{
			//GD.PushError($"Unsupported type for auto-write: {value.VariantType}");
			write_var(value);
		}

		return this;
	}

	public Variant read()
	{
		var type = _read_type();
		_stream.Seek(_stream.GetPosition() - 1);

		if (_read_methods.TryGetValue(type, out var method))
		{
			return method();
		}

		GD.PushError($"Unknown type for auto-read: {type}");
		return default;
	}

	public GDNetBuffer write_var(Variant var)
	{
		_write_type(DataType.VAR);
		_stream.PutVar(var);
		return this;
	}

	public Variant read_var()
	{
		DataType type = _read_type();

		if (type == DataType.VAR)
		{
			return _stream.GetVar();
		}

		_assert(false, $"Expected VAR, got {type}");

		return default;
	}

	public GDNetBuffer set_bytes(byte[] data)
	{
		_stream.DataArray = data;
		return this;
	}

	public byte[] get_bytes()
	{
		return _stream.DataArray;
	}

	public int get_available_bytes()
	{
		return _stream.GetAvailableBytes();
	}

	public GDNetBuffer seek(int position)
	{
		_stream.Seek(position);
		return this;
	}

	public GDNetBuffer clear()
	{
		_stream.Clear();
		seek(0);
		return this;
	}

	public int get_position()
	{
		return _stream.GetPosition();
	}

	public int get_bytes_size()
	{
		return _stream.GetSize();
	}

	// ============================================
	// WRITE METHODS
	// ============================================

	private void _write_type(DataType type)
	{
		_stream.PutU8((byte)type);
	}

	private DataType _read_type()
	{
		return (DataType)_stream.GetU8();
	}

	public GDNetBuffer write_null()
	{
		_write_type(DataType.NULL);
		return this;
	}

	public Variant read_null()
	{
		var type = _read_type();
		return default;
	}

	public GDNetBuffer write_bool(bool value)
	{
		_write_type(value ? DataType.BOOL_TRUE : DataType.BOOL_FALSE);
		return this;
	}

	public bool read_bool()
	{
		var type = _read_type();
		return type == DataType.BOOL_TRUE;
	}

	public GDNetBuffer write_int8(sbyte value)
	{
		_write_type(DataType.INT8);
		_stream.Put8(value);
		return this;
	}

	public sbyte read_int8()
	{
		var type = _read_type();
		_assert(type == DataType.INT8, $"Expected INT8, got {type}");
		return _stream.Get8();
	}

	public GDNetBuffer write_int16(short value)
	{
		_write_type(DataType.INT16);
		_stream.Put16(value);
		return this;
	}

	public short read_int16()
	{
		var type = _read_type();
		_assert(type == DataType.INT16, $"Expected INT16, got {type}");
		return _stream.Get16();
	}

	public GDNetBuffer write_int32(int value)
	{
		_write_type(DataType.INT32);
		_stream.Put32(value);
		return this;
	}

	public int read_int32()
	{
		var type = _read_type();
		_assert(type == DataType.INT32, $"Expected INT32, got {type}");
		return _stream.Get32();
	}

	public GDNetBuffer write_int64(long value)
	{
		_write_type(DataType.INT64);
		_stream.Put64(value);
		return this;
	}

	public long read_int64()
	{
		var type = _read_type();
		_assert(type == DataType.INT64, $"Expected INT64, got {type}");
		return _stream.Get64();
	}

	public GDNetBuffer write_int(long value)
	{
		if (value >= -128 && value <= 127)
			write_int8((sbyte)value);
		else if (value >= -32768 && value <= 32767)
			write_int16((short)value);
		else if (value >= -2147483648 && value <= 2147483647)
			write_int32((int)value);
		else
			write_int64(value);

		return this;
	}

	public long read_int()
	{
		var type = _read_type();
		_stream.Seek(_stream.GetPosition() - 1);

		if (_read_methods.TryGetValue(type, out var method))
		{
			return method().As<long>();
		}

		return 0;
	}

	public GDNetBuffer write_bytes(byte[] value)
	{
		int length = value.Length;

		if (length >= 65535)
		{
			_write_type(DataType.BYTE_ARRAY_U32);
			_stream.PutU32((uint)length);
			_stream.PutData(value);
			return this;
		}

		if (length >= 255)
		{
			_write_type(DataType.BYTE_ARRAY_U16);
			_stream.PutU16((ushort)length);
			_stream.PutData(value);
			return this;
		}

		if (length > 0)
		{
			_write_type(DataType.BYTE_ARRAY_U8);
			_stream.PutU8((byte)length);
			_stream.PutData(value);
			return this;
		}

		_write_type(DataType.BYTE_ARRAY_EMPTY);
		return this;
	}

	public byte[] read_bytes()
	{
		var type = _read_type();

		if (type == DataType.BYTE_ARRAY_EMPTY)
			return new byte[0];

		if (type == DataType.BYTE_ARRAY_U8)
		{
			int length = _stream.GetU8();
			return (byte[])_stream.GetData(length)[1];
		}

		if (type == DataType.BYTE_ARRAY_U16)
		{
			int length = _stream.GetU16();
			return (byte[])_stream.GetData(length)[1];
		}

		if (type == DataType.BYTE_ARRAY_U32)
		{
			int length = (int)_stream.GetU32();
			return (byte[])_stream.GetData(length)[1];
		}

		_assert(false, $"Expected BYTE_ARRAY, got {type}");
		return new byte[0];
	}

	public GDNetBuffer write_string(string value)
	{
		_write_type(DataType.STRING);
		byte[] bytes = Encoding.UTF8.GetBytes(value);
		write_bytes(bytes);
		return this;
	}

	public string read_string()
	{
		var type = _read_type();
		_assert(type == DataType.STRING, $"Expected STRING, got {type}");
		byte[] bytes = read_bytes();
		return Encoding.UTF8.GetString(bytes);
	}

	public GDNetBuffer write_vector3(Vector3 value)
	{
		_write_type(DataType.VECTOR3);
		_stream.PutFloat(value.X);
		_stream.PutFloat(value.Y);
		_stream.PutFloat(value.Z);
		return this;
	}

	public Vector3 read_vector3()
	{
		var type = _read_type();
		_assert(type == DataType.VECTOR3, $"Expected VECTOR3, got {type}");
		return new Vector3(_stream.GetFloat(), _stream.GetFloat(), _stream.GetFloat());
	}

	public GDNetBuffer write_vector2(Vector2 value)
	{
		_write_type(DataType.VECTOR2);
		_stream.PutFloat(value.X);
		_stream.PutFloat(value.Y);
		return this;
	}

	public Vector2 read_vector2()
	{
		var type = _read_type();
		_assert(type == DataType.VECTOR2, $"Expected VECTOR2, got {type}");
		return new Vector2(_stream.GetFloat(), _stream.GetFloat());
	}

	public GDNetBuffer write_float(float value)
	{
		if (value >= -3.40282347e38 && value <= 3.40282347e38)
		{
			_write_type(DataType.FLOAT);
			_stream.PutFloat(value);
		}
		else
		{
			_write_type(DataType.DOUBLE);
			_stream.PutDouble(value);
		}

		return this;
	}

	public float read_float()
	{
		var type = _read_type();

		if (type == DataType.FLOAT)
			return _stream.GetFloat();
		if (type == DataType.DOUBLE)
			return (float)_stream.GetDouble();

		_assert(false, $"Expected FLOAT or DOUBLE, got {type}");
		return 0f;
	}

	public GDNetBuffer write_array_simple(Godot.Collections.Array array)
	{
		_write_type(DataType.ARRAY_SIMPLE);
		_stream.PutVar(array);
		return this;
	}

	public Godot.Collections.Array read_array_simple()
	{
		var type = _read_type();
		_assert(type == DataType.ARRAY_SIMPLE, $"Expected ARRAY, got {type}");
		return _stream.GetVar().As<Godot.Collections.Array>();
	}

	private void _write_array_complex_internal(GDNetBuffer buffer, Godot.Collections.Array array)
	{
		foreach (var value in array)
		{
			if (value.VariantType == Variant.Type.Array)
			{
				buffer.write((byte)DataType.ARRAY_START);
				_write_array_complex_internal(buffer, value.As<Godot.Collections.Array>());
				buffer.write((byte)DataType.ARRAY_END);
				continue;
			}

			if (value.VariantType == Variant.Type.Dictionary)
			{
				// TODO: dictionary serialization
				buffer.write((byte)DataType.DICT_START);
				buffer.write((byte)DataType.DICT_END);
				continue;
			}

			buffer.write(value);
		}
	}

	public GDNetBuffer write_array_complex(Godot.Collections.Array array)
	{
		_write_type(DataType.ARRAY_COMPLEX);

		var buffer = new GDNetBuffer();

		// Write number of elements for recovery
		buffer.write_int(array.Count);

		_write_array_complex_internal(buffer, array);

		write_bytes(buffer.get_bytes());
		return this;
	}

	public Godot.Collections.Array read_array_complex()
	{
		var type = _read_type();
		_assert(type == DataType.ARRAY_COMPLEX, $"Expected ARRAY_COMPLEX, got {type}");

		var buffer = new GDNetBuffer();
		byte[] bytes = read_bytes();
		buffer.set_bytes(bytes);

		// Read number of elements
		int size = (int)buffer.read_int();

		var result = new Godot.Collections.Array();
		for (int i = 0; i < size; i++)
		{
			result.Add(_read_array_element(buffer));
		}

		return result;
	}

	private Variant _read_array_element(GDNetBuffer buffer)
	{
		var value = buffer.read();

		// Check if this is an array start marker
		if (value.VariantType == Variant.Type.Int && value.As<int>() == (int)DataType.ARRAY_START)
		{
			var subArray = new Godot.Collections.Array();
			while (true)
			{
				var elem = _read_array_element(buffer);
				if (elem.VariantType == Variant.Type.Int && elem.As<int>() == (int)DataType.ARRAY_END)
					break;
				subArray.Add(elem);
			}
			return subArray;
		}

		if (value.VariantType == Variant.Type.Int && value.As<int>() == (int)DataType.DICT_START)
		{
			// TODO: read dictionary
			return new Godot.Collections.Dictionary();
		}

		return value;
	}

	public GDNetBuffer write_object_auto(GodotObject obj)
	{
		if (!IsInstanceValid(obj))
		{
			write_null();
			return this;
		}

		if (_is_object_has_custom_serialization(obj))
		{
			write_custom_object(obj);
			return this;
		}

		if (obj is Node)
		{
			Node node = (Node)obj;
			if (node.IsInsideTree())
			{

				return write_node_ref(node);
			}

		}

		if (obj is Resource)
		{
			return write_resource((Resource)obj);
		}

		return write_full_object(obj);
	}

	public GDNetBuffer write_node_ref(Node node)
	{
		_write_type(DataType.NODE_REFERENCE);
		write_string(node.GetPath().ToString());
		return this;
	}

	public Node read_node_ref()
	{
		DataType type = _read_type();

		if (type == DataType.NODE_REFERENCE)
		{
			string path = read_string();
			return GDNetSingleton.get_instance().GetNode(path);
		}

		_assert(false, $"Expected NODE_REFERENCE, got {type}");

		return default;
	}

	public GDNetBuffer write_resource(Resource resource)
	{
		long hash_id = -1;

		if (!(resource.ResourcePath == ""))
		{
			string uid = ResourceUid.PathToUid(resource.ResourcePath);
			hash_id = ResourceUid.TextToId(uid);
		}

		if (hash_id == -1)
		{
			return write_full_object(resource);
		}

		_write_type(DataType.RESOURCE);
		write_int(hash_id);

		return this;
	}

	public Resource read_resource()
	{
		DataType type = _read_type();

		switch (type)
		{
			case DataType.RESOURCE:
				long hash_id = read_int();
				string path_uid = ResourceUid.GetIdPath(hash_id);
				return GD.Load(path_uid);

			case DataType.FULL_OBJECT:
				seek(get_position() - 1);
				return (Resource)read_full_object();
			default:
				
				return null;
		}

		return null;
	}

	public GDNetBuffer write_full_object(GodotObject obj)
	{

		_write_type(DataType.FULL_OBJECT);

		FullObjectType type = FullObjectType.OTHER;

		if (obj is GodotObject)
		{
			type = FullObjectType.OBJECT;
		}

		if (obj is RefCounted)
		{
			type = FullObjectType.REFCOUNTED;
		}

		if (obj is Resource)
		{
			type = FullObjectType.RESOURCE;
		}

		if (obj is Node)
		{
			type = FullObjectType.NODE;
		}

		_stream.PutU8((byte)type);

		if (type == FullObjectType.OTHER)
			write_string(obj.GetClass());

		Variant script = obj.GetScript();
		bool has_script = script.VariantType != Variant.Type.Nil;

		write_bool(has_script);

		if (has_script)
		{
			write_resource((Resource)script);
		}

		return this; 
	}

	public GodotObject read_full_object()
	{
		DataType type = _read_type();

		_assert(type == DataType.FULL_OBJECT, $"Expected FULL_OBJECT, got {type}");

		FullObjectType full_object_type = (FullObjectType)_stream.GetU8();

		GodotObject obj = null;

		switch (full_object_type)
		{
			case FullObjectType.OBJECT:
				obj = new GodotObject();
				break;
			case FullObjectType.REFCOUNTED:
				obj = new RefCounted();
				break;
			case FullObjectType.RESOURCE:
				obj = new Resource();
				break;
			case FullObjectType.NODE:
				obj = new Node();
				break;
			case FullObjectType.OTHER:
				obj = (GodotObject)ClassDB.Instantiate(read_string());
				break;

		}

		bool has_script = read_bool();

		if (has_script)
		{ 
			Resource script = read_resource();
			obj.SetScript(script);
		}


		return obj;
	}

	public GDNetBuffer write_custom_object(GodotObject obj)
	{
		_write_type(DataType.CUSTOM);
		write_resource((Resource)obj.GetScript());

		GDNetBuffer buffer = new();
		obj.Call(METHOD_CUSTOM_SERIALIZE, buffer);

		write_bytes(buffer.get_bytes());
		return this;
	}

	public GodotObject read_custom_object()
	{
		DataType type = _read_type();
		_assert(type == DataType.CUSTOM, $"Expected CUSTOM, got {type}");

		if (type == DataType.CUSTOM)
		{
			Resource script = read_resource();
			byte[] bytes = read_bytes();
			GDNetBuffer buffer = new();
			buffer.set_bytes(bytes);
			return (GodotObject)script.Call(METHOD_CUSTOM_DESERIALIZE, buffer);

		}

		return null;
	}

	// ============================================
	// PRIVATE HELPERS
	// ============================================

	const string METHOD_CUSTOM_SERIALIZE = "gdnet_serialize";
	const string METHOD_CUSTOM_DESERIALIZE = "gdnet_deserialize";

	private bool _is_object_has_custom_serialization(GodotObject obj)
	{
		return obj.HasMethod(METHOD_CUSTOM_SERIALIZE) && obj.HasMethod(METHOD_CUSTOM_DESERIALIZE);
	}

	private void _assert(bool condition, string message)
	{
		if (!condition)
		{
			GD.PushError(message);
		}
	}
}

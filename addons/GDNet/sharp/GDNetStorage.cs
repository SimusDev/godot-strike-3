using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class GDNetStorage : Node
{

	public Dictionary<uint, RefCounted> _object_id_by_unique_id = new();
	public Dictionary<long, RefCounted> _object_id_by_hash_id = new();


	public void _initialize()
	{

	}

	public void _append_object_id_by_unique_id(RefCounted obj)
	{
		uint net_id = (uint)obj.Call("get_unique_id");
		_object_id_by_unique_id.Remove(net_id);
		_object_id_by_unique_id[net_id] = obj;
	}

	public void _append_object_id_by_hash_id(RefCounted obj)
	{
		long hash_id = (long)obj.Call("get_hash_id");
		_object_id_by_hash_id.Remove(hash_id);
		_object_id_by_hash_id[hash_id] = obj;
	}


}

using Godot;
using System;

[GlobalClass]
public partial class GDNetSingleton : Node
{

	private static GDNetSingleton _instance;

	public static GDNetSingleton get_instance() => _instance;

	public override void _EnterTree()
	{
		_instance = this;
	}

	[Export] public GDNetConnection connection;
	[Export] public GDNetStorage storage;

	public override void _Ready()
	{
		connection._initialize();
		storage._initialize();

	}



}

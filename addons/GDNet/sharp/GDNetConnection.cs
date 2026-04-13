using Godot;
using Godot.Collections;
using System;

[GlobalClass]
public partial class GDNetConnection : Node
{
	[Signal] public delegate void on_status_changedEventHandler(Status status);

	public enum Status : int
	{
		NotConnected = STATUS_NOT_CONNECTED,
		Connecting = STATUS_CONNECTING,
		Connected = STATUS_CONNECTED,
		Disconnected = STATUS_DISCONNECTED,
	}

	public const int STATUS_NOT_CONNECTED = 0;
	public const int STATUS_CONNECTING = 1;
	public const int STATUS_CONNECTED = 2;
	public const int STATUS_DISCONNECTED = 3;

	private Status _status = Status.NotConnected;

	private bool _dedicated_server = false;

	public int get_status()
	{
		return (int)_status;
	}

	private void _set_status(Status status)
	{
		if (_status == status) return;
		_status = status;
		EmitSignal(SignalName.on_status_changed, get_status());
	}

	private static GDNetConnection _instance;
	private bool _is_active = false;

	public void subscribe_on_status_changed_event(Callable callable)
	{
		Connect(SignalName.on_status_changed, callable);
	}

	public void unsubscribe_on_status_changed_event(Callable callable)
	{
		Disconnect(SignalName.on_status_changed, callable);
	}

	public override void _EnterTree()
	{
		_instance = this;
	}

	public void _initialize()
	{

	}

	public override void _Process(double delta)
	{
		// TODO Переработать эту хуйню

		if (_is_active)
		{
			if (!IsInstanceValid(get_peer()))
			{
				_is_active = false;
				_set_status(Status.Disconnected);
				_set_status(Status.NotConnected);
			}

			else
			{
				if (get_peer() is OfflineMultiplayerPeer)
				{
					_is_active = false;
					_set_status(Status.Disconnected);
					_set_status(Status.NotConnected);
				}
			}

		}

		else
		{
			if (IsInstanceValid(get_peer()))
			{
				if (!(get_peer() is OfflineMultiplayerPeer))
				{
					if (get_peer().GetConnectionStatus() == MultiplayerPeer.ConnectionStatus.Connected)
					{
						_is_active = true;
						_set_status(Status.Connecting);
						_set_status(Status.Connected);
					}

				}
			}
		}
	}

	public static GDNetConnection get_instance()
	{
		return (GDNetConnection)_instance;
	}

	public static MultiplayerPeer get_peer()
	{
		return get_high_level_api().MultiplayerPeer;
	}

	public static bool is_active()
	{
		return _instance._is_active;
	}

	public static SceneMultiplayer get_high_level_api()
	{
		return (SceneMultiplayer)_instance.Multiplayer;
	}
	
	public static bool is_server()
	{
		return get_high_level_api().IsServer();
	}
	
	public static GDNetConnection set_dedicated_server(bool value)
	{
		_instance._dedicated_server = value;
		return _instance;
	}

	public static bool is_dedicated_server()
	{
		return _instance._dedicated_server && is_server();
	}

	public static bool is_client()
	{
		return !_instance._dedicated_server;
	}

}

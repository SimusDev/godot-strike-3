using Godot;
using Godot.NativeInterop;
using System.Collections.Generic;

[GlobalClass]
public partial class GDNetTransport : RefCounted
{
	private bool _initialized = false;

	private SceneTree _tree;
	private SceneMultiplayer _multiplayer_api;

	private GDNetTransportConfig _config;

	private float _tick_time = 0.0f;

	private Dictionary<string, Dictionary<object, object>> _pending_packets = new();

	private StreamPeerBuffer _buffer = new();

	public enum PacketHeader
	{
		UNCOMPRESSED = 0x01,
		UNCOMPRESSED_BATCH = 0x02,
		DEFLATE = 0x03,
		DEFLATE_BATCH = 0x04,
		ZSTD = 0x04,
		ZSTD_BATCH = 0x05,

	}

	public GDNetTransport initialize(SceneTree tree, SceneMultiplayer multiplayer, GDNetTransportConfig config)
	{
		_tree = tree;
		_multiplayer_api = multiplayer;

		_config = config;

		tree.ProcessFrame += _process_frame;

		_initialized = true;
		
		return this;
	}

	private void _process_frame()
	{
		double delta = _tree.Root.GetProcessDeltaTime();
	}

	public void send_packet(int peer, byte[] bytes, MultiplayerPeer.TransferModeEnum mode, int channel, bool immediate)
	{

	}

	private void _send_raw(int peer, byte[] bytes, MultiplayerPeer.TransferModeEnum mode, int channel, PacketHeader header)
	{
		
	}

	public void flush()
	{
		
	}
}

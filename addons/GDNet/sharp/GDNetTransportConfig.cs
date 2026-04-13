using Godot;

[GlobalClass]
public partial class GDNetTransportConfig : Resource
{
	[Export] bool compression_enabled = true;
	[Export] int compression_threshold_deflate = 1024;
	[Export] int compression_threshold_zstd = 4096;
	[Export] float flush_tickrate = 60.0f;
}

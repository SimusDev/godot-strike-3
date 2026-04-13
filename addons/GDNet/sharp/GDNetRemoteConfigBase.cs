using Godot;

[GlobalClass]
public partial class GDNetRemoteConfigBase : Resource
{
	[Export] public MultiplayerPeer.TransferModeEnum transfer_mode = MultiplayerPeer.TransferModeEnum.Reliable;
	[Export] public bool require_authority = true;




}

using Godot;

[GlobalClass]
public partial class GDNetStringHash : RefCounted
{
	public static ulong hash64(string input, string salt = "GDNet")
	{
		string combined = input + salt;

		// Используем GD.Hash для получения 32-битного хэша
		uint h1 = (uint)GD.Hash(combined);
		uint h2 = (uint)GD.Hash(combined + "_salt");

		return ((ulong)h1 << 32) | h2;
	}
}

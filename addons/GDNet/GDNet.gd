@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("GDNet", "res://addons/GDNet/singleton/GDNetSingleton.tscn")

func _disable_plugin() -> void:
	remove_autoload_singleton("GDNet")

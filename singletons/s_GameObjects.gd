extends Node

@export var _loaded: Dictionary[StringName, Resource] = {}

var _is_loaded: bool = false

const PATH: String = "res://resources"

signal on_all_loaded()

@onready var logger: SD_Logger = SD_Logger.new("GameObjects")

func load_all() -> void:
	_is_loaded = false
	WorkerThreadPool.add_task(_load_threaded)
	
	if _is_loaded:
		return
	
	await on_all_loaded

func _load_threaded() -> void:
	_loaded.clear()
	
	for file in SD_FileSystem.get_all_files_with_extension_from_directory(
		PATH, SD_FileExtensions.EC_RESOURCE,
	):
		var resource: Resource = load(file)
		if resource is R_WorldObject:
			var id: StringName = resource.generate_unique_id()
			_loaded.set(id, resource)
	
	_load_finish.call_deferred()

func _load_finish() -> void:
	for id in _loaded:
		logger.debug("Loaded %s, %s" % [id, _loaded[id]])
	_is_loaded = true
	on_all_loaded.emit()

class_name SD_MetadataMaterial extends Resource

@export_group("Physics")
@export var resistance:float = 1.0

@export_group("VFX")
@export var bullet_impact_particles:PackedScene
@export_subgroup("Decal")
@export var bullet_impact_decal:PackedScene
@export var melee_impact_decal:PackedScene

@export_group("Sound")
@export var impact_sounds:Array[AudioStream] = [

]

@export var bullet_impact_sounds:Array[AudioStream] = [

]

@export var break_sounds:Array[AudioStream] =  [
	
]

@export var footstep_sounds:Array[AudioStream] = []

static func find_in(node:Node, find_in_parents:bool = true) -> SD_MetadataMaterial:
	if node.has_meta("SD_MetadataMaterial"):
		return node.get_meta("SD_MetadataMaterial")
	elif find_in_parents:
		var found:SD_MetadataMaterial = null
		var parents:Array[Node] = []
		var current_parent = node.get_parent()
		
		while current_parent != null:
			if current_parent.has_meta("SD_MetadataMaterial"):
				var meta = current_parent.get_meta("SD_MetadataMaterial")
				if meta is SD_MetadataMaterial:
					found = meta
			parents.append(current_parent)
			current_parent = current_parent.get_parent()
		return found
	return null

static func safe_find_in(node:Node, find_in_parents:bool = true) -> SD_MetadataMaterial:
	var found:SD_MetadataMaterial = find_in(node, find_in_parents)
	if not found:
		return SD_MetadataMaterial.new()
	return found


class SD_MetadataButton extends EditorProperty:
	var picker = EditorResourcePicker.new()

	func _init():
		# Настраиваем пикер под наш тип ресурса
		picker.base_type = "SD_MetadataMaterial"
		picker.resource_changed.connect(_on_resource_changed)
		
		# Делаем кнопку компактной и красивой
		label = "SD Metadata" # Текст слева в инспекторе
		add_child(picker)
		set_bottom_editor(picker)

	func _on_resource_changed(resource: Resource):
		var obj = get_edited_object()
		if obj:
			if resource == null:
				# Если пользователь нажал "Clear" в пикере — удаляем мету
				if obj.has_meta("SD_MetadataMaterial"):
					obj.remove_meta("SD_MetadataMaterial")
			else:
				# Устанавливаем выбранный ресурс в метаданные
				obj.set_meta("SD_MetadataMaterial", resource)
			
			# Обновляем инспектор, чтобы поле Meta обновилось визуально
			obj.notify_property_list_changed()

	func _update_property():
		# Синхронизируем состояние пикера, если мета изменилась извне
		var obj = get_edited_object()
		var meta = obj.get_meta("SD_MetadataMaterial") if obj.has_meta("SD_MetadataMaterial") else null
		if meta is Resource:
			picker.edited_resource = meta


class SD_MetadataButtonInspectorPlugin extends EditorInspectorPlugin:
	func _can_handle(object):
		return object is Node
	
	func _parse_property(object, type, name, hint, hint_string, usage_flags, wide):
		if name == "script":
			add_custom_control(SD_MetadataButton.new())
		return false

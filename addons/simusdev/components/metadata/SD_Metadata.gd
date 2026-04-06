class_name SD_Metadata extends Resource

static func find_in(node:Node, find_in_parents:bool = true) -> SD_Metadata:
	if node.has_meta("SD_Metadata"):
		return node.get_meta("SD_Metadata")
	elif find_in_parents:
		var found:SD_MetadataMaterial = null
		var parents:Array[Node] = []
		var current_parent = node.get_parent()
		
		while current_parent != null:
			if current_parent.has_meta("SD_Metadata"):
				var meta = current_parent.get_meta("SD_Metadata")
				if meta is SD_MetadataMaterial:
					found = meta
			parents.append(current_parent)
			current_parent = current_parent.get_parent()
		return found
	return null

static func safe_find_in(node:Node, find_in_parents:bool = true) -> SD_Metadata:
	var found:SD_Metadata = find_in(node, find_in_parents)
	if not found:
		return SD_Metadata.new()
	return found


class SD_MetadataButton extends EditorProperty:
	var picker = EditorResourcePicker.new()

	func _init():
		picker.base_type = "SD_Metadata"
		picker.resource_changed.connect(_on_resource_changed)
		
		label = "SD Metadata"
		add_child(picker)
		set_bottom_editor(picker)

	func _on_resource_changed(resource: Resource):
		var obj = get_edited_object()
		if not obj: return
		
		if resource == null:
			if obj.has_meta("SD_Metadata"):
				obj.remove_meta("SD_Metadata")
		else:
			obj.set_meta("SD_Metadata", resource)
		
		obj.notify_property_list_changed()

	func _update_property():
		var obj = get_edited_object()
		if not obj: return
		
		var meta = obj.get_meta("SD_Metadata") if obj.has_meta("SD_Metadata") else null
		if meta is SD_Metadata:
			picker.edited_resource = meta
		else:
			picker.edited_resource = null


class SD_MetadataButtonInspectorPlugin extends EditorInspectorPlugin:
	func _can_handle(object):
		return object is Node
	
	func _parse_property(object, type, name, hint, hint_string, usage_flags, wide):
		if name == "script":
			add_custom_control(SD_MetadataButton.new())
		return false

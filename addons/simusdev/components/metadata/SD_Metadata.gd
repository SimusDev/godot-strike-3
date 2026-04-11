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


static func find_of_type(node: Node, type: GDScript, find_in_parents: bool = true) -> SD_Metadata:
	if not is_instance_valid(node):
		return null
	
	var list = _get_meta_list(node)
	for meta in list:
		if is_instance_of(meta, type):
			return meta
			
	if find_in_parents and node.get_parent():
		return find_of_type(node.get_parent(), type, true)
	return null

static func _get_meta_list(node: Node) -> Array:
	if not is_instance_valid(node):
		return []
	if node.has_meta("SD_Metadata_List"):
		return node.get_meta("SD_Metadata_List")
	return []


#class SD_MetadataButton extends EditorProperty:
	#var container = VBoxContainer.new()
#
	#func _init():
		#label = "SD Metadata"
		#add_child(container)
		#set_bottom_editor(container)
		#_update_view()
#
	#func _update_view():
		#for child in container.get_children():
			#child.queue_free()
		#
		#var obj = get_edited_object()
		#if not obj: return
		#
		#var list = obj.get_meta("SD_Metadata_List") if obj.has_meta("SD_Metadata_List") else []
		#
		#for i in range(list.size()):
			#_create_picker_row(list[i], i)
			#
		#var add_btn = Button.new()
		#add_btn.text = "Add New Metadata"
		#add_btn.icon = EditorInterface.get_editor_theme().get_icon("Add", "EditorIcons")
		#add_btn.pressed.connect(_add_new_picker)
		#container.add_child(add_btn)
#
	#func _update_property():
		#_update_view()
#
	#func _create_picker_row(res: Resource, index: int):
		#var row = HBoxContainer.new()
		#var picker = EditorResourcePicker.new()
		#picker.base_type = "SD_Metadata"
		#picker.edited_resource = res
		#picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#picker.resource_changed.connect(func(new_res): _on_resource_changed(new_res, index))
		#
		#var del_btn = Button.new()
		#del_btn.icon = EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons")
		#del_btn.pressed.connect(func(): _remove_resource(index))
		#
		#row.add_child(picker)
		#row.add_child(del_btn)
		#container.add_child(row)
#
	#func _add_new_picker():
		#var obj = get_edited_object()
		#var list = obj.get_meta("SD_Metadata_List") if obj.has_meta("SD_Metadata_List") else []
		#var new_list = list.duplicate()
		#new_list.append(null)
		#obj.set_meta("SD_Metadata_List", new_list)
		#
		#obj.notify_property_list_changed()
#
	#func _on_resource_changed(resource: Resource, index: int):
		#var obj = get_edited_object()
		#var list = obj.get_meta("SD_Metadata_List").duplicate()
		#list[index] = resource
		#obj.set_meta("SD_Metadata_List", list)
		#obj.notify_property_list_changed()
#
	#func _remove_resource(index: int):
		#var obj = get_edited_object()
		#var list = obj.get_meta("SD_Metadata_List").duplicate()
		#list.remove_at(index)
		#
		#if list.is_empty():
			#obj.remove_meta("SD_Metadata_List")
		#else:
			#obj.set_meta("SD_Metadata_List", list)
		#
		#obj.notify_property_list_changed()
#
#class SD_MetadataButtonInspectorPlugin extends EditorInspectorPlugin:
	#func _can_handle(object):
		#return object is Node
	#
	#func _parse_end(object: Object) -> void:
		#add_custom_control(SD_MetadataButton.new())

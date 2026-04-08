extends Node3D
class_name C_Level3D

var _replicator: C_NodeReplicator

var _sections: Node3D
var _sections_local: Node3D

func _ready() -> void:
	_sections = Node3D.new()
	_sections_local = Node3D.new()
	_sections.name = "Sections"
	_sections_local.name = "LocalSections"
	add_child(_sections)
	add_child(_sections_local)
	
	_replicator = C_NodeReplicator.new()
	_replicator.name = "Replicator"
	
	var sections: Array[String] = []
	for i in s_GameObjects.get_loaded_resources():
		var section_id: String = ""
		
		var script: Script = i.get_script()
		if script:
			section_id = script.get_global_name().to_camel_case().validate_node_name()
		
		if section_id.is_empty() or sections.has(section_id):
			continue
		
		sections.append(section_id)
	
	sections.sort()
	
	print(sections)
	for id: String in sections:
		var section_node: Node3D = Node3D.new()
		section_node.name = id
		var section_node_local: Node3D = Node3D.new()
		section_node_local.name = id
		
		_sections.add_child(section_node)
		_sections_local.add_child(section_node_local)
		
		_replicator.roots.append(section_node)
	
	add_child(_replicator)

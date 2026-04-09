class_name SimusNetServerListener extends Node

signal server_discovered(server_info: Dictionary)
signal server_removed(ip: String)

var simusnet_settings: SimusNetSettings
var _udp_server: UDPServer = UDPServer.new()
var _servers: Dictionary = {} 
var _tick_timer: Timer
var _cleanup_timer: Timer

var should_listen: bool = true
var listening: bool = true

func _ready():
	simusnet_settings = SimusNetSettings.get_or_create()
	
	if SimusNetConnection.is_dedicated_server():
		return

	var port = simusnet_settings.server_info.broadcasting_port
	
	while _udp_server.listen(port) != OK:
		push_warning("[SimusNetServerListener] Error listening port")
		await get_tree().create_timer(1.0).timeout

	_tick_timer = _create_timer(simusnet_settings.server_info.listener_listening_interval, _tick)
	_cleanup_timer = _create_timer(simusnet_settings.server_info.listener_cleanup_interval, _cleanup)

func _create_timer(wait_time, callback) -> Timer:
	var t = Timer.new()
	t.wait_time = wait_time
	t.timeout.connect(callback)
	add_child(t)
	t.start()
	return t

func _tick() -> void:
	if not (listening and should_listen): return
	
	_udp_server.poll()
	
	while _udp_server.is_connection_available():
		var peer = _udp_server.take_connection()
		var packet_data = peer.get_packet()
		var packet_ip = peer.get_packet_ip()
		
		var deserialized = bytes_to_var(packet_data)
		if not deserialized is Dictionary: continue
		
		_process_server_packet(packet_ip, deserialized)

func _process_server_packet(ip: String, data: Dictionary):
	if data.has("image_data") and DisplayServer.get_name() != "headless":
		var img = Image.new()
		if img.load_jpg_from_buffer(data["image_data"]) == OK:
			data["texture"] = ImageTexture.create_from_image(img)
	
	var now = Time.get_unix_time_from_system()
	data["ip"] = ip
	data["last_seen"] = now
	
	if not _servers.has(ip):
		_servers[ip] = data
		server_discovered.emit(data)
		SimusDev.console.write_info("[SimusNetServerListener] Server found: %s" % ip)
	else:
		_servers[ip].merge(data, true)

func _cleanup():
	var now = Time.get_unix_time_from_system()
	var timeout = simusnet_settings.server_info.listener_server_timeout
	
	for ip in _servers.keys():
		if now - _servers[ip].get("last_seen", 0) > timeout:
			_servers.erase(ip)
			server_removed.emit(ip)

func _exit_tree():
	_udp_server.stop()

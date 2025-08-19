extends Node

var IpAddress: String = "localhost"
var BroadcastAddress: String = "255.255.255.255"

const ServerPort: int = 42069
const BroadcastPort: int = 42070
const BroadcastListenPort: int = 42071

var broadcaster: PacketPeerUDP
var broadcast_timer: Timer
var broadcast_emission_interval: int = 1
var current_broadcast_emission: PackedByteArray

var peer: ENetMultiplayerPeer
## Useful to debug multiple instances in the same machine as using the local ip
## only works when testing different devices on the same LAN.
var use_localhost: bool = true


func _enter_tree() -> void:
	IpAddress = get_local_ip()
	BroadcastAddress = get_broadcast_address(IpAddress)


func start_server(port: int =  ServerPort, max_players: int = 32) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = peer


func start_client(ip: String = IpAddress, port: int = ServerPort) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer


func start_broadcast() -> void:
	_create_broadcast_timer()
		
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(BroadcastAddress, BroadcastListenPort)
	var binded_port_error: Error =  broadcaster.bind(BroadcastPort, "0.0.0.0")
	
	if binded_port_error == OK:
		print("LocalNetworkHandler: Broadcast port %d binded with success " % BroadcastPort)
		
	broadcast_timer.start(broadcast_emission_interval)
		

func end() -> void:
	end_broadcast()
	multiplayer.multiplayer_peer = null


func end_broadcast() -> void:
	if is_instance_valid(broadcast_timer):
		broadcast_timer.stop()
	
	if broadcaster:
		broadcaster.close()


func get_local_ip() -> String:
	var addreses: PackedStringArray = IP.get_local_addresses()
	var valid_addreses: Array[String] = []

	for ip_address: String in addreses:
		if ip_address.begins_with("192.168.") \
				or ip_address.begins_with("10.") \
				or ip_address.begins_with("172."):
				
					valid_addreses.append(ip_address)
	## When sorted, 192.168 ips are first in the valid addresses
	valid_addreses.sort_custom(func(_a, b): return not b.begins_with("192.168"))
	
	return "localhost" if valid_addreses.is_empty() or use_localhost else valid_addreses.front()


func get_broadcast_address(local_ip: String) -> String:
	if local_ip.begins_with("192.168."):
		return "192.168.1.255"
	elif local_ip.begins_with("10."):
		return "10.255.255.255"
	elif local_ip.begins_with("172."):
		return "172.20.255.255"
	else:
		return "127.0.0.1" if use_localhost else "255.255.255.255"
	

func _create_broadcast_timer() -> void:
	if not is_instance_valid(broadcast_timer):
		broadcast_timer = Timer.new()
		broadcast_timer.name = "LocalNetworkHandlerBroadcastTimer"
		broadcast_timer.process_callback = Timer.TIMER_PROCESS_IDLE
		broadcast_timer.autostart = false
		broadcast_timer.one_shot = false
		add_child(broadcast_timer)
		broadcast_timer.timeout.connect(on_broadcast_timer_timeout)


func set_current_broadcast_emission(packet: PackedByteArray) -> void:
	if packet.size() > 0:
		current_broadcast_emission = packet
	
	
func on_broadcast_timer_timeout() -> void:
	if current_broadcast_emission and current_broadcast_emission.size() > 0 and broadcaster:
		broadcaster.put_packet(current_broadcast_emission)


func _exit_tree() -> void:
	end()

extends Node2D


func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_guy_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_on_guy_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connect")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_disconnect")
	
	if get_tree().is_network_server():
		_on_connect()


func _on_guy_connected(their_id):
	if their_id != 1:
		var our_id = get_tree().get_network_unique_id()
		rpc_id(their_id, "spawn_player", our_id)


func _on_guy_disconnected(their_id):
	find_player(their_id).queue_free()


func _on_connect():
	var our_id = get_tree().get_network_unique_id()
	rpc("spawn_player", our_id)


func _on_disconnect():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/menu.tscn")


remotesync func spawn_player(master_id):
	var node = preload("res://entities/player.tscn").instance()
	
	node.name = str(master_id)
	node.set_network_master(master_id)
	
	$Players.add_child(node)


func find_player(their_id):
	return $Players.get_node(str(their_id))

extends Control


const MAX_CLIENTS = 32

const DEFAULT_PORT = 13723


func _ready():
	var hostButton = $Center/HBox/HostBox/HostButton
	hostButton.connect("pressed", self, "_on_HostButton_pressed")
	
	var joinButton = $Center/HBox/JoinBox/JoinButton
	joinButton.connect("pressed", self, "_on_JoinButton_pressed")


func _on_HostButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	
	var port = get_text_or_default($Center/HBox/HostBox/PortEdit, DEFAULT_PORT)
	
	if OK == peer.create_server(port, MAX_CLIENTS):
		proceed(peer)


func _on_JoinButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	
	var address = get_text_or_default($Center/HBox/JoinBox/AddressEdit, "127.0.0.1")
	var port = get_text_or_default($Center/HBox/JoinBox/PortEdit, DEFAULT_PORT)
	
	if OK == peer.create_client(address, port):
		proceed(peer)


func get_text_or_default(text_field, default):
	var port = text_field.text
	return default if port == "" else int(port)


func proceed(peer):
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game.tscn")
	get_tree().network_peer = peer

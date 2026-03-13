extends Node

var playerScenePath = preload("res://Player/player.tscn")
var leashScenePath = preload("res://Leash/leash.tscn")
var isHost = false
var mapSeed = randi()
var map: Node2D
var main: Node2D

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_disconnected
signal player_spawned(peer_id, player_info)
signal player_despawned
signal player_registered
signal player_score_updated
signal data_loaded

const PORT = 3131
const DEFAULT_SERVER_IP = "localhost"

var spawnedPlayers = {}
var connectedPlayers = []
var syncedPlayers = []

var player_info = {"name": ""}

@onready var game = get_node("/root/Game")
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		print(error)
		print("there was an error joining, returning false")
		return false
	multiplayer.multiplayer_peer = peer
	return true

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	player_connected.emit(1, player_info)
	isHost = true
	game.start_game()
	
func _on_player_connected(_id):
	# not implemented
	return
	
func _on_player_disconnected(_id):
	# not implemented
	return
	
func _on_connected_ok():
	game.start_game()
	var peer_id = multiplayer.get_unique_id()
	connectedPlayers.append(peer_id)
	player_connected.emit(peer_id)
	load_main_game()
	
func load_main_game():
	player_loaded.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	main = game.get_node("Level/Main")
	set_process(false)

func _on_connected_fail():
	# not implemented
	return
	
func _on_server_disconnected():
	# not implemented
	return

@rpc("call_local" ,"any_peer", "reliable")
func _register_character(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	spawnedPlayers[new_player_id] = new_player_info
	player_spawned.emit(new_player_id, new_player_info)
	player_registered.emit()

func requestSpawn(playerName, id, characterFile):
	player_info["name"] = playerName
	player_info["body"] = characterFile
	player_info["score"] = 0
	player_info["id"] = id
	spawnedPlayers[id] = player_info
	_register_character.rpc(player_info)
	spawnPlayer.rpc_id(1, playerName, id, characterFile)

@rpc("any_peer", "call_local", "reliable")
func spawnPlayer(playerName, id, characterFile):
	var newPlayer := playerScenePath.instantiate()
	newPlayer.playerName = playerName
	newPlayer.characterFile = characterFile
	newPlayer.name = str(id)
	var playersNode := main.get_node("Players")
	playersNode.add_child(newPlayer)
	newPlayer.sendPos.rpc(Vector2(0, 0))
	if (characterFile == "dog"):
		var leash: Leash = Leash.createLeash(playersNode.get_child(0), newPlayer)
		main.get_node("Leashes").add_child(leash)

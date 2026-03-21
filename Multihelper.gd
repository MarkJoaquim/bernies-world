extends Node

var personScenePath = preload("res://Player/Person/person.tscn")
var dogScenePath = preload("res://Player/Dog/dog.tscn")
var leashScenePath = preload("res://Leash/leash.tscn")
var isHost = false
var mapSeed = randi()
var map: Node
var main: Node

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

func _on_player_connected(id):
	connectedPlayers.append(id)
	if multiplayer.is_server():
		sync_player_list.rpc_id(id, spawnedPlayers, connectedPlayers)

@rpc("authority", "call_remote", "reliable")
func sync_player_list(players: Dictionary, connected: Array) -> void:
	spawnedPlayers = players
	connectedPlayers = connected
	for id in players:
		player_spawned.emit(id, players[id])

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

func requestSpawn(playerName, id, type, linkedPlayerId = null):
	player_info["name"] = playerName
	player_info["type"] = type
	player_info["score"] = 0
	player_info["id"] = id
	spawnedPlayers[id] = player_info
	_register_character.rpc(player_info)
	spawnPlayer.rpc_id(1, playerName, id, type, linkedPlayerId)

@rpc("any_peer", "call_local", "reliable")
func spawnPlayer(playerName, id, type, linkedPlayerId = null):
	var newPlayer: Player = (dogScenePath if type == "dog" else personScenePath).instantiate()
	newPlayer.player_name = playerName
	newPlayer.name = str(id)
	var playersNode := game.get_node_or_null("Level/Main/Players")
	playersNode.add_child(newPlayer)
	newPlayer.position = Vector3(0, 1, 0)
	newPlayer.sendPos.rpc(Vector3(0, 1, 0))
	if linkedPlayerId and multiplayer.is_server():
		spawnLeash.rpc(id, linkedPlayerId, type)

@rpc("authority", "call_local", "reliable")
func spawnLeash(playerId: int, linkedPlayerId: int, type: String) -> void:
	var playersNode := game.get_node_or_null("Level/Main/Players")
	var person: Person
	var dog: Dog
	if type == "dog":
		dog = playersNode.get_node_or_null(str(playerId)) as Dog
		person = playersNode.get_node_or_null(str(linkedPlayerId)) as Person
	else:
		person = playersNode.get_node_or_null(str(playerId)) as Person
		dog = playersNode.get_node_or_null(str(linkedPlayerId)) as Dog
	if not person or not dog:
		return
	game.get_node("Level/Main/Leashes").add_child(Leash.createLeash(person, dog))

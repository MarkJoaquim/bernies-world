extends Control

@onready var characterSelectScene := preload("res://UI/CharacterSelect/character_select.tscn")
@onready var lobbyOptionScene: = preload("res://UI/MainMenu/LobbyOption/lobby_option.tscn")
@onready var game = get_node("/root/Game")

func _ready() -> void:
	MultiplayerClient.lobby_list_update.connect(_update_lobbies)
	MultiplayerClient.connected.connect(_on_ws_connected)
	MultiplayerClient.lobby_joined.connect(_join_lobby)
	MultiplayerClient.start("markeep.ddns.net")

func _on_start_button_pressed():
	Multihelper.player_connected.connect(_on_connected, CONNECT_ONE_SHOT)
	Multihelper.create_game()

func _on_join_button_pressed() -> void:
	Multihelper.player_connected.connect(_on_connected, CONNECT_ONE_SHOT)
	Multihelper.join_game()

func _on_connected(_peer_id: int) -> void:
	add_sibling(characterSelectScene.instantiate())
	queue_free()

func _on_ws_connected(_peer_id: int, mesh: bool) -> void:
	MultiplayerClient.list_lobbies()

func _lobby_joined(_peer_id: int) -> void:
	add_sibling(characterSelectScene.instantiate())
	queue_free()

func _update_lobbies(lobbies: Array) -> void:
	for lobby in lobbies:
		var lobby_option := lobbyOptionScene.instantiate()
		lobby_option.find_child("LobbyName").text = lobby.lobby_name
		lobby_option.lobby_name = lobby.lobby_name
		lobby_option.player_count = lobby.player_count
		lobby_option.joinLobby.connect(_join_lobby)
		$VBoxContainer/LobbyList.add_child(lobby_option)

func _join_lobby(lobby_name: String) -> void:
	add_sibling(characterSelectScene.instantiate())
	queue_free()
	

func _on_create_lobby_button_pressed() -> void:
	var new_lobby_name = $VBoxContainer/CreateRoom/LobbyName.text
	MultiplayerClient.create_lobby(new_lobby_name)


func _on_refresh_lobby_list_pressed() -> void:
	MultiplayerClient.list_lobbies()

class_name LobbyOption extends Control

var lobby_name: String
var player_count: int

signal joinLobby(name)


func _on_join_button_pressed() -> void:
	MultiplayerClient.join_lobby(lobby_name)

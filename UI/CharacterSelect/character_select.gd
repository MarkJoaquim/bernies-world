extends Control

var player_select_option_scene = preload("res://UI/CharacterSelect/PlayerSelectOption/player_select_option.tscn")

func _ready() -> void:
	# Populate any players already registered before this screen opened
	for id in Multihelper.spawnedPlayers:
		_add_player_entry(id, Multihelper.spawnedPlayers[id])

	Multihelper.player_spawned.connect(_on_player_spawned)
	Multihelper.player_disconnected.connect(_on_player_disconnected)


func _on_player_spawned(peer_id: int, player_info: Dictionary) -> void:
	_add_player_entry(peer_id, player_info)


func _on_player_disconnected(peer_id: int) -> void:
	var entry = %PlayerList.get_node_or_null(str(peer_id))
	if entry:
		entry.queue_free()


func _add_player_entry(peer_id: int, player_info: Dictionary) -> void:
	if %PlayerList.get_node_or_null(str(peer_id)):
		return
	var option := player_select_option_scene.instantiate()
	option.set_player_info(player_info)
	option.name = str(peer_id)
	%PlayerList.add_child(option)


func _on_spawn_button_pressed() -> void:
	Multihelper.requestSpawn(%NameInput.text, multiplayer.get_unique_id(), "person")
	queue_free()


func _on_dog_button_pressed() -> void:
	Multihelper.requestSpawn(%NameInput.text, multiplayer.get_unique_id(), "dog")
	queue_free()

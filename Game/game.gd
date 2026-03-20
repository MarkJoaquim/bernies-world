extends Node3D

func _ready() -> void:
	MultiplayerClient.lobby_joined.connect(start_game)

func start_game(_lobby_name: String = "") -> void:
	# Hide the UI and unpause to start the game.
	get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Main/main.tscn"))


# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = %Level
	#for c in level.get_children():
		#level.remove_child(c)
		#c.queue_free()
	# Add new level.
	var main = scene.instantiate()
	level.add_child(main)
	Multihelper.main = main
